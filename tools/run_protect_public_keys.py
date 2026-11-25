#!/usr/bin/env python3
"""Qualify how protected envelopes select public and private fixture keys."""

import argparse
from dataclasses import dataclass, replace
import hashlib
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile

import run_icarus
import run_protect_author_digests as author
import run_protect_block_boundaries as boundaries
import run_protect_cipher_methods as cipher
import run_protect_digests as digests
import run_protect_encryption as protect
import run_protect_licenses as licenses
import run_slang
import suite_results


PROFILE = "protect-public-keys"
CHECKER = "tools/run_protect_public_keys.py"
DATA = "ch34/test_protect_data_public_key_matches_owner_and_name"
DIGEST = "ch34/test_protect_digest_public_key_inherits_data_identity"
EXCHANGE = "ch34/test_protect_exchange_public_key_matches_owner_and_name"
ADJACENT = "ch34/test_protect_public_key_roles_remain_separate_between_envelopes"
CASES = {DATA: "public data=3d,18", DIGEST: "public digest=79", EXCHANGE: "public exchange=b2",
         ADJACENT: "public adjacent=64,af"}
DIAGNOSTIC_REQUIREMENTS = {
    "SV2023-34.5.12.2-EXTRACT-NAME-SELECT",
    "SV2023-34.5.25.2-EXTRACT-KEY-NAME",
}
DIAGNOSTIC_ANCHOR = "def unknown_name_at_selector("
EAST, WEST = b"Fixture East", b"Fixture West"
ASSEMBLY, BACKUP = b"assembly", b"backup"
REFERENCE_AGENT = b"Fixture reference encryptor"
RSA_OPTIONS = ("-pkeyopt", "rsa_padding_mode:oaep", "-pkeyopt", "rsa_oaep_md:sha1",
               "-pkeyopt", "rsa_mgf1_md:sha1")


@dataclass(frozen=True)
class Fields:
    owner: bytes
    name: bytes
    method: bytes
    public: bytes
    block: bytes


DATA_FIELDS = Fields(b"data_keyowner", b"data_keyname", b"data_method", b"data_public_key", b"data_block")
DIGEST_FIELDS = Fields(b"digest_keyowner", b"digest_keyname", b"digest_key_method",
                       b"digest_public_key", b"digest_block")
KEY_FIELDS = Fields(b"key_keyowner", b"key_keyname", b"key_method", b"key_public_key", b"key_block")


@dataclass(frozen=True)
class KeyPair:
    private: Path
    public_der: bytes


@dataclass(frozen=True)
class Selection:
    owner: bytes
    name: bytes | None
    method: bytes
    public_der: bytes | None = None


class UnknownName(ValueError):
    def __init__(self, fields: Fields, owner: bytes, name: bytes):
        super().__init__(f"{fields.name.decode()}: {name.decode()} is unknown for {owner.decode()}")
        self.keyword, self.owner, self.name = fields.name, owner, name


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(author.checker_digest().encode())
    digest.update(licenses.checker_digest().encode())
    return digest.hexdigest()


def read_selection(text: bytes, fields: Fields, fallback: Selection | None = None) -> Selection:
    metadata = protect.fields(text)
    blocks = {directive.strip() for directive in protect.DIRECTIVE.findall(text)}
    inherited = fallback or Selection(b"", None, b"")
    public = author.payload(text, fields.public).decoded if fields.public in blocks else inherited.public_der
    return Selection(metadata.get(fields.owner, inherited.owner), metadata.get(fields.name, inherited.name),
                     metadata.get(fields.method, inherited.method), public)


def selection_text(request: Selection, fields: Fields, mode: bytes) -> bytes:
    text = author.method_line(fields.owner, request.owner) + author.method_line(fields.method, request.method)
    if request.name is not None:
        text += author.method_line(fields.name, request.name)
    if request.public_der is not None:
        text += digests.encoded_block(fields.public, request.public_der, mode)
    return text


def named_pair(request: Selection, fields: Fields, keys: dict) -> KeyPair | None:
    if request.method != b"rsa":
        raise ValueError("expected an RSA selection for the fixture")
    if request.name is None:
        return None
    pair = keys.get((request.owner, request.name))
    if pair is None:
        raise UnknownName(fields, request.owner, request.name)
    if request.public_der is not None and request.public_der != pair.public_der:
        raise ValueError("named and embedded public keys differ")
    return pair


def encryption_key(request: Selection, fields: Fields, keys: dict) -> bytes:
    pair = named_pair(request, fields, keys)
    if pair is not None:
        return pair.public_der
    if request.public_der is None:
        raise ValueError("no public key selected")
    return request.public_der


def decryption_key(request: Selection, fields: Fields, keys: dict) -> KeyPair:
    pair = named_pair(request, fields, keys)
    if pair is not None:
        return pair
    matches = [key for (owner, _), key in keys.items()
               if owner == request.owner and key.public_der == request.public_der]
    if len(matches) != 1:
        raise ValueError("public key has no uniquely registered private key for this owner")
    return matches[0]


def encipher(openssl: str, work: Path, public_der: bytes, plain: bytes) -> bytes:
    public = work / "selected.der"
    public.write_bytes(public_der)
    return protect.invoke([openssl, "pkeyutl", "-encrypt", "-pubin", "-keyform", "DER",
                           "-inkey", str(public), *RSA_OPTIONS], plain)


def decipher(openssl: str, pair: KeyPair, protected: bytes) -> bytes:
    return protect.invoke([openssl, "pkeyutl", "-decrypt", "-inkey", str(pair.private), *RSA_OPTIONS],
                          protected)


def seal(openssl: str, work: Path, request: bytes, fields: Fields, keys: dict,
         plain: bytes, mode: bytes, fallback: Selection | None = None) -> bytes:
    selection = read_selection(request, fields, fallback)
    encrypted = encipher(openssl, work, encryption_key(selection, fields, keys), plain)
    return selection_text(selection, fields, mode) + digests.encoded_block(fields.block, encrypted, mode)


def open_selected(openssl: str, wire: bytes, fields: Fields, keys: dict,
                  libraries: dict[str, str], feature: str = "allow") -> bytes:
    selection = read_selection(wire, fields)
    pair = decryption_key(selection, fields, keys)
    policy = {"library": "dec", "entry": "check", "feature": feature}
    returned = licenses.authorize(policy, libraries, [])
    if returned != licenses.GRANTED["decrypt"]:
        raise PermissionError("decryption license denied")
    return decipher(openssl, pair, author.payload(wire, fields.block).decoded)


def unknown_name_at_selector(text: bytes, fields: Fields, keys: dict, owner: bytes, name: bytes) -> bool:
    try:
        encryption_key(read_selection(text, fields), fields, keys)
    except UnknownName as error:
        return (error.keyword, error.owner, error.name) == (fields.name, owner, name)
    return False


def selection_controls(openssl: str, work: Path, primary: Selection, fields: Fields, keys: dict,
                       mode: bytes, plain: bytes, libraries: dict[str, str]) -> tuple[dict, bytes]:
    combined = replace(primary, public_der=keys[(primary.owner, primary.name)].public_der)
    other_owner = WEST if primary.owner == EAST else EAST
    named_other = replace(primary, owner=other_owner)
    public_only = Selection(EAST, None, primary.method, keys[(EAST, BACKUP)].public_der)
    combined_request = selection_text(combined, fields, mode)
    combined_wire = seal(openssl, work, combined_request, fields, keys, plain, mode)
    named_wire = seal(openssl, work, selection_text(named_other, fields, mode), fields, keys, plain, mode)
    public_wire = seal(openssl, work, selection_text(public_only, fields, mode), fields, keys, plain, mode)
    wrong_der = replace(combined, public_der=keys[(other_owner, primary.name)].public_der)
    mismatched_text = selection_text(wrong_der, fields, mode)
    misowned = replace(public_only, owner=WEST)
    unknown = Selection(WEST, BACKUP, primary.method, keys[(EAST, BACKUP)].public_der)
    no_such_key = Selection(primary.owner, b"unregistered", primary.method)
    decoded_public = author.payload(combined_wire, fields.public)
    line = author.PRAGMA + fields.public + b"\n"
    separated_public = combined_request.replace(line, line + b"\n", 1)
    unreadable_ciphertext = combined_wire[:combined_wire.index(author.PRAGMA + fields.block)]
    try:
        open_selected(openssl, unreadable_ciphertext, fields, keys, libraries, feature="deny")
    except PermissionError:
        denied = True
    except ValueError:
        denied = False
    else:
        denied = False
    result = {
        "combined_owner_and_name": open_selected(openssl, combined_wire, fields, keys, libraries) == plain,
        "same_name_different_owner": open_selected(openssl, named_wire, fields, keys, libraries) == plain,
        "public_only": open_selected(openssl, public_wire, fields, keys, libraries) == plain,
        "next_line_public_encoding": decoded_public.encoding[b"enctype"] == mode
                                     and decoded_public.decoded == combined.public_der,
        "blank_line_before_public_key_rejected": author.rejected(
            lambda: seal(openssl, work, separated_public, fields, keys, plain, mode)),
        "owner_name_and_method_visible": read_selection(combined_wire, fields) == combined,
        "name_and_public_mismatch_rejected": author.rejected(
            lambda: seal(openssl, work, mismatched_text, fields, keys, plain, mode)),
        "private_key_wrong_owner_rejected": author.rejected(lambda: decipher(
            openssl, keys[(other_owner, primary.name)], author.payload(combined_wire, fields.block).decoded)),
        "public_key_unknown_to_owner_rejected": author.rejected(
            lambda: decryption_key(misowned, fields, keys)),
        "unknown_name_for_owner": unknown_name_at_selector(selection_text(unknown, fields, mode),
                                                           fields, keys, WEST, BACKUP),
        "unknown_name_in_registry": unknown_name_at_selector(selection_text(no_such_key, fields, mode),
                                                              fields, keys, primary.owner, b"unregistered"),
        "license_denied_with_known_key": denied,
    }
    return result, combined_wire


def include_public_key(source: bytes, fields: Fields, keys: dict) -> Selection:
    request = read_selection(source, fields)
    return replace(request, public_der=keys[(request.owner, request.name)].public_der)


def adjacent_controls(openssl: str, work: Path, layout: protect.Layout, keys: dict,
                      libraries: dict[str, str]) -> tuple[dict, tuple[bytes, ...]]:
    first, second = (part.strip(b"\r\n") for part in layout.bodies)
    before, between = layout.clear[:2]
    first_mode = protect.fields(before)[b"enctype"]
    second_mode = protect.fields(between)[b"enctype"]
    data = include_public_key(before, DATA_FIELDS, keys)
    digest = include_public_key(before, DIGEST_FIELDS, keys)
    exchange = include_public_key(between, KEY_FIELDS, keys)
    method = protect.fields(between)[b"data_method"]
    data_key = secrets.token_bytes(protect.CIPHERS[method][1])
    digest_bytes = hashlib.new(protect.fields(before)[b"digest_method"].decode(), first).digest()

    records = (
        (seal(openssl, work, selection_text(data, DATA_FIELDS, first_mode),
              DATA_FIELDS, keys, first, first_mode)
         + seal(openssl, work, selection_text(digest, DIGEST_FIELDS, first_mode),
                DIGEST_FIELDS, keys, digest_bytes, first_mode)),
        (seal(openssl, work, selection_text(exchange, KEY_FIELDS, second_mode),
              KEY_FIELDS, keys, data_key, second_mode)
         + digests.encoded_block(b"data_block", boundaries.seal(openssl, method, data_key, second), second_mode)),
    )
    wire = b"".join(author.PRAGMA + b"begin_protected\n" + record + author.PRAGMA + b"end_protected\n"
                    for record in records)
    direct, wrapped = protect.split(wire, protect.OUTPUT_BEGIN, protect.OUTPUT_END).bodies
    recovered_first = open_selected(openssl, direct, DATA_FIELDS, keys, libraries)
    recovered_digest = open_selected(openssl, direct, DIGEST_FIELDS, keys, libraries)
    recovered_key = open_selected(openssl, wrapped, KEY_FIELDS, keys, libraries)
    recovered_second = protect.decrypt_body(openssl, method, recovered_key,
                                            author.payload(wrapped, b"data_block").decoded)
    observed = tuple(read_selection(record, fields) for record, fields in
                     ((direct, DATA_FIELDS), (direct, DIGEST_FIELDS), (wrapped, KEY_FIELDS)))
    checks = {
        "first_body_and_digest_match": recovered_first == first and recovered_digest == digest_bytes,
        "second_body_requires_exchange_key": recovered_key == data_key and recovered_second == second,
        "each_owner_name_and_key_preserved": observed == (data, digest, exchange)
                                             and len({selection.public_der for selection in observed}) == 3,
        "public_keys_keep_local_encodings": (
            author.payload(direct, DATA_FIELDS.public).encoding[b"enctype"] == first_mode
            and author.payload(direct, DIGEST_FIELDS.public).encoding[b"enctype"] == first_mode
            and author.payload(wrapped, KEY_FIELDS.public).encoding[b"enctype"] == second_mode
            and first_mode != second_mode
        ),
        "exchange_key_cannot_open_first_data_or_digest": all(author.rejected(
            lambda: decipher(openssl, decryption_key(exchange, KEY_FIELDS, keys),
                             author.payload(direct, field).decoded))
            for field in (DATA_FIELDS.block, DIGEST_FIELDS.block)),
        "prior_data_and_digest_keys_cannot_open_second_key_block": all(author.rejected(
            lambda: decipher(openssl, decryption_key(selection, fields, keys),
                             author.payload(wrapped, KEY_FIELDS.block).decoded))
            for selection, fields in ((data, DATA_FIELDS), (digest, DIGEST_FIELDS))),
    }
    return checks, (recovered_first, recovered_second)


def reference_controls(openssl: str, work: Path, case: str, fixture: Path, keys: dict,
                       libraries: dict[str, str], icarus_bin: Path) -> dict:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    if case == ADJACENT:
        result, recovered_bodies = adjacent_controls(openssl, work, layout, keys, libraries)
        restored = work / fixture.name
        restored.write_bytes(b"".join(clear + b"\n" + body + b"\n"
                                     for clear, body in zip(layout.clear, recovered_bodies)) + layout.clear[-1])
        result["recovered_hdl_matches"] = run_icarus.run(restored, icarus_bin)[0]
        return result
    body, = (part.strip(b"\r\n") for part in layout.bodies)
    settings = protect.fields(source)
    mode = settings[b"enctype"]
    if case == DATA:
        result, wire = selection_controls(openssl, work, read_selection(source, DATA_FIELDS),
                                          DATA_FIELDS, keys, mode, body, libraries)
        recovered = open_selected(openssl, wire, DATA_FIELDS, keys, libraries)
        result["third_party_data_key_supplier"] = (
            read_selection(wire, DATA_FIELDS).owner not in {settings[b"author"], REFERENCE_AGENT}
            and recovered == body
        )
    elif case == DIGEST:
        data = include_public_key(source, DATA_FIELDS, keys)
        data_request = selection_text(data, DATA_FIELDS, mode)
        data_wire = seal(openssl, work, data_request, DATA_FIELDS, keys, body, mode)
        recovered = open_selected(openssl, data_wire, DATA_FIELDS, keys, libraries)
        expected = hashlib.new(settings[b"digest_method"].decode(), recovered).digest()
        explicit = read_selection(source, DIGEST_FIELDS)
        result, digest_wire = selection_controls(openssl, work, explicit, DIGEST_FIELDS,
                                                 keys, mode, expected, libraries)
        inherited_wire = seal(openssl, work, data_request, DIGEST_FIELDS, keys, expected, mode, fallback=data)
        result["inherited_data_public_key"] = (
            read_selection(inherited_wire, DIGEST_FIELDS) == data
            and open_selected(openssl, inherited_wire, DIGEST_FIELDS, keys, libraries) == expected
        )
        # The name selects West but the inherited DER still belongs to East.
        without_public = selection_text(explicit, DIGEST_FIELDS, mode)
        result["inherited_public_and_explicit_name_mismatch"] = author.rejected(
            lambda: seal(openssl, work, without_public, DIGEST_FIELDS, keys, expected, mode, fallback=data))
        result["independent_data_and_digest_suppliers"] = (
            read_selection(data_wire, DATA_FIELDS).owner == EAST
            and read_selection(digest_wire, DIGEST_FIELDS).owner == WEST
            and read_selection(digest_wire, DIGEST_FIELDS).owner not in {settings[b"author"], REFERENCE_AGENT}
            and open_selected(openssl, digest_wire, DIGEST_FIELDS, keys, libraries) == expected
        )
    else:
        method = settings[b"data_method"]
        data_key = secrets.token_bytes(protect.CIPHERS[method][1])
        result, key_wire = selection_controls(openssl, work, read_selection(source, KEY_FIELDS),
                                              KEY_FIELDS, keys, mode, data_key, libraries)
        data_wire = digests.encoded_block(b"data_block", boundaries.seal(openssl, method, data_key, body), mode)
        envelope = key_wire + data_wire
        recovered_key = open_selected(openssl, envelope, KEY_FIELDS, keys, libraries)
        recovered = protect.decrypt_body(openssl, method, recovered_key, author.payload(envelope, b"data_block").decoded)
        result["key_block_recovers_body_key"] = recovered_key == data_key and recovered == body
    restored = work / fixture.name
    restored.write_bytes(layout.clear[0] + b"\n" + recovered + b"\n" + layout.clear[1])
    result["recovered_hdl_matches"] = run_icarus.run(restored, icarus_bin)[0]
    return result


def native_observations(python: str, openssl: str, work: Path, case: str, source: bytes,
                        keys: dict, cli_keys: tuple[Path, Path]) -> dict:
    begin = author.PRAGMA + b"begin\n"
    plans = {DATA: ((DATA_FIELDS,),), DIGEST: ((DIGEST_FIELDS,),), EXCHANGE: ((KEY_FIELDS,),),
             ADJACENT: ((DATA_FIELDS, DIGEST_FIELDS), (KEY_FIELDS,))}[case]
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    groups = []
    for clear, roles in zip(layout.clear, plans):
        mode = protect.fields(clear)[b"enctype"]
        group = []
        for fields in roles:
            request = read_selection(clear, fields)
            pair = keys[(request.owner, request.name)]
            encoded = digests.encoded_block(fields.public, pair.public_der, mode)
            group.append((author.PRAGMA + fields.public, pair, encoded))
        groups.append(group)
    cli_private, cli_public = cli_keys
    variant, output = work / "native.sv", work / "native.out.sv"
    observations = {}
    for name in ("before_begin", "inside_begin"):
        first, *following_parts = source.split(begin)
        if len(following_parts) != len(groups):
            raise ValueError("unexpected number of native insertion points")
        segments = [first]
        for group, following in zip(groups, following_parts):
            key_text = b"".join(encoded for _, _, encoded in group)
            segments += [key_text + begin if name == "before_begin" else begin + key_text, following]
        modified = b"".join(segments)
        variant.write_bytes(modified)
        output.unlink(missing_ok=True)
        try:
            run = cipher.run_encryptor(python, variant, cli_public, output)
            if run.returncode != 0 or not output.is_file():
                observations[name] = {"outcome": "rejected_or_no_output", "exit": run.returncode}
                continue
            emitted = output.read_bytes()
            layout, recovered = boundaries.recovered_ranges(openssl, cli_private, emitted)
            if len(layout.bodies) != len(groups):
                raise ValueError("unexpected output envelope count")
        except (ValueError, KeyError, subprocess.TimeoutExpired):
            observations[name] = {"outcome": "invalid_or_unreadable_output"}
            continue
        original = protect.split(modified, protect.SOURCE_BEGIN, protect.SOURCE_END).bodies
        all_selectors = [(statement, pair, index)
                         for index, group in enumerate(groups) for statement, pair, _ in group]
        present = [statement in layout.bodies[index] for statement, _, index in all_selectors]
        methods = {protect.fields(envelope).get(b"data_method", b"").decode("ascii") for envelope in layout.bodies}
        wrapped = [protect.parse_blocks(envelope)[b"key_block"] for envelope in layout.bodies]
        observations[name] = {
            "outcome": ("envelope_selector_present" if all(present) else
                        "some_envelope_selectors_missing" if any(present) else "envelope_selector_omitted"),
            "body_recovered_using_cli_recipient": all(protect.keeps_body(body, contents)
                                                    for body, contents in zip(original, recovered)),
            "selector_in_recovered_body": all(statement in recovered[index] for statement, _, index in all_selectors),
            "selector_in_clear_surroundings": all(statement in layout.clear[index]
                                                 for statement, _, index in all_selectors),
            "author_private_key_cannot_unwrap_cli_recipient": all(
                author.rejected(lambda: protect.unwrap_session_key(openssl, pair.private, wrapped[index]))
                for _, pair, index in all_selectors
            ),
            "emitted_data_method": next(iter(methods)) if len(methods) == 1 else None,
            "emitted_digest_blocks": sum(d.strip() == b"digest_block" for envelope in layout.bodies
                                         for d in protect.DIRECTIVE.findall(envelope)),
            "envelope_count": len(layout.bodies),
        }
    return observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, openssl = shutil.which(args.python), shutil.which(args.openssl)
    if python is None or openssl is None or not (args.iverilog_bin / "iverilog").is_file():
        parser.error("Python, OpenSSL or Icarus is unavailable")
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    fingerprints = suite_results.fingerprints(list(fixtures.values()))
    checker, tool = checker_digest(), protect.tool_info(python)
    tests = {}
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        libraries = {name: str(path) for name, path in licenses.build_libraries(work).items()}
        keys = {}
        for index, identity in enumerate(((EAST, ASSEMBLY), (EAST, BACKUP), (WEST, ASSEMBLY))):
            private, public = protect.exchange_key(openssl, work, f"registered-{index}")
            keys[identity] = KeyPair(private, protect.invoke(
                [openssl, "pkey", "-pubin", "-in", str(public), "-outform", "DER"]))
        cli_keys = protect.exchange_key(openssl, work, "ordinary-cli")
        for case, fixture in fixtures.items():
            controls = reference_controls(openssl, work, case, fixture, keys, libraries, args.iverilog_bin)
            tests[case] = {
                "inputs_sha256": fingerprints[case], "reference_controls": controls,
                "native": native_observations(python, openssl, work, case, fixture.read_bytes(), keys, cli_keys),
            }
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or test input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
        "openssl": protect.invoke([openssl, "version"]).decode().strip(),
        "icarus": protect.invoke([str(args.iverilog_bin / "iverilog"), "-V"]).decode().splitlines()[0],
        "tests": tests,
    })
    failed = False
    for case, row in tests.items():
        controls = row["reference_controls"]
        print(f"{case}: {sum(controls.values())}/{len(controls)} reference controls match")
        for placement, result in row["native"].items():
            print(f"  {placement}: {result['outcome']}")
        failed |= (not all(controls.values())
                   or any(item["outcome"] != "envelope_selector_present" for item in row["native"].values()))
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())

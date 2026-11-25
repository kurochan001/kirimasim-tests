#!/usr/bin/env python3
"""Check alternative protect key blocks and the body data they must share."""

import argparse
from dataclasses import dataclass, replace
import hashlib
from pathlib import Path
import re
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
import run_protect_public_keys as public
import run_slang
import suite_results


PROFILE = "protect-multiple-recipients"
CHECKER = "tools/run_protect_multiple_recipients.py"
SHARED = "ch34/test_protect_recipients_wrap_the_same_body_key"
CHANGED = "ch34/test_protect_recipients_reject_changed_body_key_metadata"
CASES = {SHARED: "recipient shared=36,49", CHANGED: "recipient metadata=a6"}
DIAGNOSTIC_REQUIREMENTS = {"SV2023-34.5.27.2-EXTRACT-MULTIPLE-KEY-BLOCKS"}
DIAGNOSTIC_ANCHOR = "def rejected_before_key_block_generation("
ALTERNATE = b"// Alternate exchange recipient\n"
KEY_OWNER_LINE = re.compile(rb"^" + protect.PRAGMA + rb"key_keyowner[ \t]*=", re.M)
DATA_FIELDS = (("owner", b"data_keyowner"), ("name", b"data_keyname"),
               ("method", b"data_method"), ("key", b"data_decrypt_key"))


@dataclass(frozen=True)
class BodyKey:
    owner: bytes
    name: bytes
    method: bytes
    key: bytes


@dataclass(frozen=True)
class Recipient:
    selector: public.Selection
    encoding: bytes
    data: BodyKey


@dataclass(frozen=True)
class ExchangeKey:
    method: bytes
    material: public.KeyPair | bytes

    @property
    def identity(self) -> bytes:
        if isinstance(self.material, public.KeyPair):
            return self.material.public_der
        return self.material


class ChangedBodyKey(ValueError):
    def __init__(self, index: int, keyword: bytes):
        super().__init__(f"recipient {index} changes {keyword.decode()}")
        self.index = index
        self.keyword = keyword


def checker_digest() -> str:
    content = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    content.update(public.checker_digest().encode())
    return content.hexdigest()


def registry(entries: list[tuple[tuple[bytes, bytes], ExchangeKey]]) -> dict:
    keys = {}
    identities = set()
    for (owner, name), key in entries:
        if (owner, name) in keys:
            raise ValueError("duplicate exchange key name for this owner")
        fingerprint = (owner, key.identity)
        if fingerprint in identities:
            raise ValueError("duplicate exchange key material for this owner")
        keys[owner, name] = key
        identities.add(fingerprint)
    return keys


def select_exchange_key(selection: public.Selection, keys: dict) -> ExchangeKey:
    if selection.name is not None:
        key = keys.get((selection.owner, selection.name))
    else:
        matches = [entry for (owner, _), entry in keys.items() if owner == selection.owner
                   and isinstance(entry.material, public.KeyPair)
                   and entry.identity == selection.public_der]
        key = matches[0] if len(matches) == 1 else None
    if key is None:
        raise ValueError("no exchange key for the requested owner and selector")
    if key.method != selection.method:
        raise ValueError("key_method disagrees with the registered method")
    if selection.public_der is not None and (
        not isinstance(key.material, public.KeyPair) or key.identity != selection.public_der
    ):
        raise ValueError("embedded public key does not match the registered exchange key")
    return key


def body_headers(data: BodyKey) -> bytes:
    return b"".join(author.method_line(keyword, getattr(data, attribute))
                    for attribute, keyword in DATA_FIELDS[:-1])


def body_key_text(data: BodyKey, mode: bytes) -> bytes:
    return body_headers(data) + digests.encoded_block(author.DATA_KEY, data.key, mode)


def read_body_key(text: bytes) -> BodyKey:
    headers = protect.fields(text)
    secret = author.payload(text, author.DATA_KEY).decoded
    return BodyKey(headers[b"data_keyowner"], headers[b"data_keyname"], headers[b"data_method"], secret)


def shared_data(requests: tuple[Recipient, ...]) -> BodyKey:
    if len(requests) < 2:
        raise ValueError("the fixture needs at least two recipient requests")
    expected = requests[0].data
    for index, request in enumerate(requests[1:], start=2):
        for field, keyword in DATA_FIELDS:
            if getattr(request.data, field) != getattr(expected, field):
                raise ChangedBodyKey(index, keyword)
    return expected


def wrap_one(openssl: str, work: Path, request: Recipient, keys: dict) -> bytes:
    key = select_exchange_key(request.selector, keys)
    clear = body_key_text(request.data, request.encoding)
    if isinstance(key.material, public.KeyPair):
        encrypted = public.encipher(openssl, work, key.material.public_der, clear)
    else:
        encrypted = boundaries.seal(openssl, key.method, key.material, clear)
    return (public.selection_text(request.selector, public.KEY_FIELDS, request.encoding)
            + digests.encoded_block(b"key_block", encrypted, request.encoding))


def pack_signed(openssl: str, work: Path, requests: tuple[Recipient, ...], keys: dict,
                body: bytes, signer: Path, signature: Path) -> bytes:
    data = shared_data(requests)
    signed = body_key_text(data, b"base64") + body
    protect.invoke([openssl, "dgst", "-sha256", "-verify", str(signer), "-signature", str(signature)], signed)
    wrapped = b"".join(wrap_one(openssl, work, request, keys) for request in requests)
    ciphertext = boundaries.seal(openssl, data.method, data.key, body)
    return (author.PRAGMA + b"begin_protected\n" + wrapped
            + digests.encoded_block(b"data_block", ciphertext, requests[0].encoding)
            + author.PRAGMA + b"end_protected\n")


def open_key_block(openssl: str, record: bytes, keys: dict) -> tuple[BodyKey, bytes]:
    selection = public.read_selection(record, public.KEY_FIELDS)
    key = select_exchange_key(selection, keys)
    ciphertext = author.payload(record, b"key_block").decoded
    if isinstance(key.material, public.KeyPair):
        clear = public.decipher(openssl, key.material, ciphertext)
    else:
        clear = protect.decrypt_body(openssl, selection.method, key.material, ciphertext)
    return read_body_key(clear), clear


def rejected_before_key_block_generation(openssl: str, work: Path, requests: tuple[Recipient, ...],
                                         keys: dict, body: bytes, signer: Path, signature: Path,
                                         keyword: bytes) -> bool:
    try:
        pack_signed(openssl, work, requests, keys, body, signer, signature)
    except ChangedBodyKey as error:
        return (error.index, error.keyword) == (2, keyword)
    return False


def reference_checks(openssl: str, fixture: Path, work: Path, icarus_bin: Path,
                     public_only: bool) -> tuple[dict, bytes]:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    initial, alternate = layout.clear[0].split(ALTERNATE)
    body, = (part.strip(b"\r\n") for part in layout.bodies)
    metadata = protect.fields(initial)
    method = metadata[b"data_method"]
    data = BodyKey(metadata[b"data_keyowner"], metadata[b"data_keyname"], method,
                   secrets.token_bytes(protect.CIPHERS[method][1]))
    rsa_private, rsa_public = author.rsa_recipient(openssl, work)
    rsa_der = protect.invoke([openssl, "pkey", "-pubin", "-in", str(rsa_public), "-outform", "DER"])
    materials = {
        b"rsa": ExchangeKey(b"rsa", public.KeyPair(rsa_private, rsa_der)),
        b"aes128-cbc": ExchangeKey(b"aes128-cbc", secrets.token_bytes(16)),
    }
    entries, requests = [], []
    for directives in (initial, alternate):
        selection = public.read_selection(directives, public.KEY_FIELDS)
        key = materials[selection.method]
        entries.append(((selection.owner, selection.name), key))
        if selection.method == b"rsa":
            selection = replace(selection, public_der=rsa_der, name=None if public_only else selection.name)
        requests.append(Recipient(selection, protect.fields(directives)[b"enctype"], data))
    requests = tuple(requests)
    keys = registry(entries)
    signer_private, signer = protect.exchange_key(openssl, work, "fixture-author")
    signature = work / "author.sig"
    signature.write_bytes(protect.invoke([openssl, "dgst", "-sha256", "-sign", str(signer_private)],
                                         body_key_text(data, b"base64") + body))
    wire = pack_signed(openssl, work, requests, keys, body, signer, signature)
    envelope, = protect.split(wire, protect.OUTPUT_BEGIN, protect.OUTPUT_END).bodies
    starts = [match.start() for match in KEY_OWNER_LINE.finditer(envelope)]
    if len(starts) != len(requests):
        raise ValueError("one exchange owner directive is required per key block")
    records = tuple(envelope[start:finish] for start, finish in zip(starts, starts[1:] + [len(envelope)]))
    opened = tuple(open_key_block(openssl, part, keys) for part in records)
    ciphertext = author.payload(envelope, b"data_block").decoded
    recovered = [protect.decrypt_body(openssl, info.method, info.key, ciphertext) for info, _ in opened]
    restored = work / fixture.name
    restored.write_bytes(layout.clear[0] + b"\n" + recovered[0] + b"\n" + layout.clear[1])

    # The ordinary named-key case selects an already registered data key.
    ordinary_store = {(data.owner, data.name): data.key}
    ordinary = body_headers(data) + digests.encoded_block(b"data_block", ciphertext, b"base64")
    ordinary_fields = protect.fields(ordinary)
    ordinary_key = ordinary_store[ordinary_fields[b"data_keyowner"], ordinary_fields[b"data_keyname"]]
    checks = {
        "two_recipients_restore_one_body": recovered == [body, body],
        "same_unwrapped_data_metadata": all(info == data for info, _ in opened),
        "recipient_block_payloads_differ": (
            author.payload(records[0], b"key_block").decoded != author.payload(records[1], b"key_block").decoded),
        "new_descriptor_for_each_wrapped_block": all(
            author.payload(record, b"key_block").encoding[b"enctype"] == request.encoding
            and author.payload(clear, author.DATA_KEY).encoding[b"enctype"] == request.encoding
            for record, (_, clear), request in zip(records, opened, requests)
        ),
        "exchange_owners_and_methods_preserved": all(
            public.read_selection(record, public.KEY_FIELDS) == request.selector
            for record, request in zip(records, requests)
        ),
        "independent_exchange_suppliers": all(
            request.selector.owner not in {data.owner, metadata[b"author"], public.REFERENCE_AGENT}
            for request in requests
        ),
        "duplicate_name_under_same_owner_rejected": author.rejected(lambda: registry([*entries, entries[0]])),
        "duplicate_material_under_same_owner_rejected": author.rejected(
            lambda: registry([*entries, ((entries[0][0][0], b"alias"), entries[0][1])]),
        ),
        "changed_exchange_owner_cannot_select_private_key": all(author.rejected(
            lambda: open_key_block(openssl, record.replace(
                author.method_line(b"key_keyowner", request.selector.owner),
                author.method_line(b"key_keyowner", b"Unregistered Owner"), 1), keys))
            for record, request in zip(records, requests)
        ),
        "changed_method_cannot_open_original_payload": all(author.rejected(
            lambda: open_key_block(openssl, record.replace(
                author.method_line(b"key_method", request.selector.method),
                author.method_line(b"key_method", other.selector.method), 1), keys))
            for record, request, other in zip(records, requests, reversed(requests))
        ),
        "signed_data_owner_and_name_only_in_key_blocks": (
            b"data_keyowner" not in protect.fields(envelope) and b"data_keyname" not in protect.fields(envelope)
            and all(info.owner == data.owner and info.name == data.name for info, _ in opened)
        ),
        "ordinary_data_owner_and_name_visible": (
            ordinary_fields[b"data_keyowner"] == data.owner and ordinary_fields[b"data_keyname"] == data.name
            and protect.decrypt_body(openssl, ordinary_fields[b"data_method"], ordinary_key,
                                     author.payload(ordinary, b"data_block").decoded) == body
        ),
        "signature_blocks_modified_author_body": author.rejected(
            lambda: pack_signed(openssl, work, requests, keys, body + b"\n", signer, signature)),
        "recovered_hdl_matches": run_icarus.run(restored, icarus_bin)[0],
    }
    changed = {
        "owner": b"Fixture Other Data",
        "name": b"changed",
        "method": b"aes128-cbc" if method != b"aes128-cbc" else b"aes256-cbc",
        "key": bytes([data.key[0] ^ 1]) + data.key[1:],
    }
    for field, keyword in DATA_FIELDS:
        changed_requests = (requests[0], replace(requests[1], data=replace(data, **{field: changed[field]})))
        checks[f"second_recipient_changes_{keyword.decode()}"] = rejected_before_key_block_generation(
            openssl, work, changed_requests, keys, body, signer, signature, keyword)
    return checks, layout.clear[0] + wire + layout.clear[1]


def native_single_recipient(python: str, openssl: str, work: Path, keys: tuple[Path, Path],
                            source: bytes) -> dict:
    private, public_key = keys
    variant, output = work / "native-source.sv", work / "native.out.sv"
    variant.write_bytes(source)
    output.unlink(missing_ok=True)
    try:
        run = cipher.run_encryptor(python, variant, public_key, output)
        if run.returncode != 0 or not output.is_file():
            return {"outcome": "rejected_or_no_output", "exit": run.returncode}
        wire = output.read_bytes()
        layout = protect.split(wire, protect.OUTPUT_BEGIN, protect.OUTPUT_END, protect.FALLBACK_BEGIN)
        envelope, = layout.bodies
        count = sum(line.strip() == b"key_block" for line in protect.DIRECTIVE.findall(envelope))
        settings = protect.fields(envelope)
        info = {
            "key_blocks": count,
            "key_owner": settings.get(b"key_keyowner", b"").decode("ascii"),
            "key_method": settings.get(b"key_method", b"").decode("ascii"),
            "output_data_method": settings.get(b"data_method", b"").decode("ascii"),
        }
        if count != 1:
            return {"outcome": "other_key_block_count", **info}
        recovered = protect.recover(openssl, private, protect.parse_blocks(envelope))
        original, = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END).bodies
        return {"outcome": "one_cli_recipient_recovers_body" if protect.keeps_body(original, recovered)
                else "recovered_body_differs", **info}
    except (ValueError, KeyError, subprocess.TimeoutExpired):
        return {"outcome": "invalid_or_unreadable_output"}


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
    with tempfile.TemporaryDirectory() as scratch:
        directory = Path(scratch)
        cli_keys = protect.exchange_key(openssl, directory, "cli")
        for case, fixture in fixtures.items():
            work = directory / fixture.stem
            work.mkdir()
            controls, prepared = reference_checks(openssl, fixture, work, args.iverilog_bin,
                                                   public_only=case == CHANGED)
            tests[case] = {
                "inputs_sha256": fingerprints[case], "reference_controls": controls,
                "ordinary_cli": native_single_recipient(python, openssl, work, cli_keys, fixture.read_bytes()),
                "prepared_cli": author.native_trial(python, openssl, work, cli_keys, prepared, prepared=True),
            }
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or test input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
        "openssl": protect.invoke([openssl, "version"]).decode().strip(),
        "icarus": protect.invoke([str(args.iverilog_bin / "iverilog"), "-V"]).decode().splitlines()[0],
        "reference_signature": "detached fixture-author signature verified before packaging",
        "tests": tests,
    })
    failed = False
    for case, row in tests.items():
        controls = row["reference_controls"]
        print(f"{case}: {sum(controls.values())}/{len(controls)} reference controls match")
        print(f"  ordinary: {row['ordinary_cli']['outcome']}, prepared: {row['prepared_cli']['outcome']}")
        failed |= (not all(controls.values()) or row["ordinary_cli"].get("key_blocks") != 2
                   or row["prepared_cli"]["outcome"] != "prepared_input_preserved")
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())

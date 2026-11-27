#!/usr/bin/env python3
"""Check author-encrypted body and digest payloads with fixture-owned signing keys."""

import argparse
from dataclasses import dataclass, replace
import hashlib
from io import BytesIO
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import tempfile

import run_icarus
import run_protect_block_boundaries as boundaries
import run_protect_cipher_methods as cipher
import run_protect_digests as digests
import run_protect_encodings as encodings
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-author-digests"
CHECKER = "tools/run_protect_author_digests.py"
EXPLICIT = "ch34/test_protect_author_digest_wraps_explicit_key"
DEFAULT = "ch34/test_protect_author_digest_inherits_data_key"
PLACEMENT = "ch34/test_protect_digest_metadata_placement"
CASES = {EXPLICIT: "author digest explicit=9b", DEFAULT: "author digest inherited=32,4f",
         PLACEMENT: "digest metadata payload=6d"}
DATA_KEY = b"data_decrypt_key"
DIGEST_KEY = b"digest_decrypt_key"
DIGEST_SELECTOR = (b"digest_keyowner", b"digest_keyname")
DIGEST_FIELDS = (*DIGEST_SELECTOR, b"digest_key_method", b"digest_method")
PRAGMA = b"`pragma protect "
DESCRIPTOR = re.compile(rb"^" + protect.PRAGMA + rb"encoding[ \t]*=")
REPEATED_END_SUFFIX = re.compile(rb"^" + protect.PRAGMA + rb"end_protected_protected(?=\r?$)", re.M)


@dataclass(frozen=True)
class DigestKeys:
    data_method: bytes
    data_key: bytes
    digest_key_method: bytes
    digest_key: bytes


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(encodings.checker_digest().encode())
    digest.update(suite_results.runner_digest("icarus").encode())
    return digest.hexdigest()


def method_line(name: bytes, value: bytes) -> bytes:
    return PRAGMA + name + b' = "' + value + b'"\n'


def field_text(metadata: dict[bytes, bytes], names: tuple[bytes, ...]) -> bytes:
    return b"".join(method_line(name, metadata[name]) for name in names if name in metadata)


def payload(text: bytes, name: bytes) -> protect.Block:
    lines = text.splitlines(keepends=True)
    matches = [index for index, line in enumerate(lines)
               if line.strip() == PRAGMA + name]
    if len(matches) != 1 or matches[0] == 0:
        raise ValueError("expected one payload after its descriptor")
    index = matches[0]
    previous = lines[index - 1].strip()
    if not DESCRIPTOR.match(previous):
        raise ValueError("missing immediate encoding descriptor")
    descriptor = protect.attributes(previous)
    if index + 1 == len(lines) or not lines[index + 1].strip():
        raise ValueError("payload must start on the next line")
    stream = BytesIO(b"".join(lines[index + 1:]))
    mode = descriptor[b"enctype"]
    if mode not in (b"base64", b"uuencode"):
        raise ValueError("unexpected fixture encoding")
    decoded = encodings.read_payload(stream, mode, int(descriptor[b"bytes"]))
    encoded = tuple(line.rstrip(b"\r\n") for line in stream.getvalue()[:stream.tell()].splitlines())
    return protect.Block(encoded, decoded, descriptor, previous)


def resolve_keys(text: bytes) -> DigestKeys:
    headers = protect.fields(text)
    data_method = headers[b"data_method"]
    data_key = payload(text, DATA_KEY).decoded
    supplied = any(line.strip() == DIGEST_KEY for line in protect.DIRECTIVE.findall(text))
    digest_key = payload(text, DIGEST_KEY).decoded if supplied else data_key
    digest_key_method = headers.get(b"digest_key_method", data_method)
    if (len(data_key) != protect.CIPHERS[data_method][1]
            or len(digest_key) != protect.CIPHERS[digest_key_method][1]):
        raise ValueError("metadata key size does not match its method")
    return DigestKeys(data_method, data_key, digest_key_method, digest_key)


def key_text(keys: DigestKeys, mode: bytes) -> bytes:
    return (method_line(b"data_method", keys.data_method)
            + digests.encoded_block(DATA_KEY, keys.data_key, mode)
            + method_line(b"digest_key_method", keys.digest_key_method)
            + digests.encoded_block(DIGEST_KEY, keys.digest_key, mode))


def make_author_input(openssl: str, headers: dict[bytes, bytes], body: bytes,
                      digest_key: bytes | None = None) -> bytes:
    mode, data_method, digest_method = (headers[field] for field in
                                       (b"enctype", b"data_method", b"digest_method"))
    data_key = secrets.token_bytes(protect.CIPHERS[data_method][1])
    digest_key_method = headers.get(b"digest_key_method", data_method)
    if digest_key is None:
        digest_key = (secrets.token_bytes(protect.CIPHERS[digest_key_method][1])
                      if b"digest_key_method" in headers else data_key)
    metadata = (method_line(b"data_method", data_method)
                + method_line(b"digest_method", digest_method)
                + field_text(headers, DIGEST_SELECTOR)
                + digests.encoded_block(DATA_KEY, data_key, mode))
    if b"digest_key_method" in headers:
        metadata += (method_line(b"digest_key_method", digest_key_method)
                     + digests.encoded_block(DIGEST_KEY, digest_key, mode))
    digest = hashlib.new(digest_method.decode(), body).digest()
    return (metadata
            + digests.encoded_block(b"data_block", boundaries.seal(openssl, data_method, data_key, body), mode)
            + digests.encoded_block(
                b"digest_block", boundaries.seal(openssl, digest_key_method, digest_key, digest), mode))


def wrap_author(openssl: str, signing_public: Path, signature: Path,
                recipient_public: Path, author: bytes, mode: bytes) -> bytes:
    # A detached signature selects the fixture's author-signature path.
    protect.invoke([openssl, "dgst", "-sha256", "-verify", str(signing_public),
                    "-signature", str(signature)], author)
    keys = resolve_keys(author)
    data = payload(author, b"data_block").decoded
    digest = payload(author, b"digest_block").decoded
    digest_text = digests.encoded_block(b"digest_block", digest, mode)
    buffer = key_text(keys, mode) + digest_text
    buffer += field_text(protect.fields(author), (*DIGEST_SELECTOR, b"digest_method"))
    wrapped = protect.invoke([openssl, "pkeyutl", "-encrypt", "-pubin", "-inkey", str(recipient_public),
                              "-pkeyopt", "rsa_padding_mode:oaep", "-pkeyopt", "rsa_oaep_md:sha256",
                              "-pkeyopt", "rsa_mgf1_md:sha256"], buffer)
    public_der = protect.invoke([openssl, "pkey", "-pubin", "-in", str(recipient_public), "-outform", "DER"])
    return (PRAGMA + b"begin_protected\n"
            + method_line(b"key_method", b"rsa")
            + digests.encoded_block(b"key_public_key", public_der, mode)
            + digests.encoded_block(b"key_block", wrapped, mode)
            + digests.encoded_block(b"data_block", data, mode)
            + digest_text
            + PRAGMA + b"end_protected\n")


def read_key_block(openssl: str, private: Path, wire: bytes) -> tuple[bytes, DigestKeys]:
    if protect.fields(wire)[b"key_method"] != b"rsa":
        raise ValueError("unexpected recipient key method")
    wrapped = payload(wire, b"key_block")
    clear = protect.unwrap_session_key(openssl, private, wrapped)
    return clear, resolve_keys(clear)


def authenticate(openssl: str, keys: DigestKeys, wire: bytes, digest_method: bytes) -> tuple[bytes, bool]:
    body = protect.decrypt_body(openssl, keys.data_method, keys.data_key, payload(wire, b"data_block").decoded)
    digest = protect.decrypt_body(openssl, keys.digest_key_method, keys.digest_key,
                                  payload(wire, b"digest_block").decoded)
    return body, digest == hashlib.new(digest_method.decode(), body).digest()


def unsigned_envelope(author: bytes, mode: bytes) -> bytes:
    # The unsigned control supplies the fixture keys out of band.
    return (PRAGMA + b"begin_protected\n"
            + field_text(protect.fields(author), (b"data_method", *DIGEST_FIELDS))
            + digests.encoded_block(b"data_block", payload(author, b"data_block").decoded, mode)
            + digests.encoded_block(b"digest_block", payload(author, b"digest_block").decoded, mode)
            + PRAGMA + b"end_protected\n")


def verify_unsigned(openssl: str, wire: bytes, keys: DigestKeys,
                    named_keys: dict[tuple[bytes, bytes], bytes], body: bytes) -> bool:
    fields = protect.fields(wire)
    try:
        selector = tuple(fields[field] for field in DIGEST_SELECTOR)
        selected_keys = replace(keys, digest_key=named_keys[selector], digest_key_method=fields[b"digest_key_method"])
        return authenticate(openssl, selected_keys, wire, fields[b"digest_method"]) == (body, True)
    except (KeyError, ValueError):
        return False


def placement_controls(openssl: str, author: bytes, wire: bytes, meta: bytes, keys: DigestKeys,
                       named_keys: dict[tuple[bytes, bytes], bytes], body: bytes, mode: bytes) -> dict:
    supplied = protect.fields(author)
    unsigned = unsigned_envelope(author, mode)
    outer, inner, unsigned_fields = map(protect.fields, (wire, meta, unsigned))
    owner, name = (supplied[field] for field in DIGEST_SELECTOR)
    wrong_owner = unsigned.replace(method_line(b"digest_keyowner", owner),
                                   method_line(b"digest_keyowner", b"Fixture West"), 1)
    wrong_name = unsigned.replace(method_line(b"digest_keyname", name),
                                  method_line(b"digest_keyname", b"backup"), 1)
    controls = {
        "unsigned_digest_matches": verify_unsigned(openssl, unsigned, keys, named_keys, body),
        "digest_key_selected_by_owner_and_name": keys.digest_key == named_keys[(owner, name)]
            and not verify_unsigned(openssl, wrong_owner, keys, named_keys, body)
            and not verify_unsigned(openssl, wrong_name, keys, named_keys, body),
        "uses_key_block_without_digest_key_block": (
            b"key_block" in protect.DIRECTIVE.findall(wire)
            and all(b"digest_key_block" not in protect.DIRECTIVE.findall(form) for form in (wire, unsigned))
        ),
    }
    for field in DIGEST_FIELDS:
        label = field.decode("ascii")
        controls[f"unsigned_preserves_{label}"] = unsigned_fields.get(field) == supplied[field]
        controls[f"signed_wraps_{label}"] = inner.get(field) == supplied[field] and field not in outer
    return controls


def rejected(operation) -> bool:
    try:
        operation()
    except ValueError:
        return True
    return False


def rsa_recipient(openssl: str, directory: Path) -> tuple[Path, Path]:
    # Fit the digest owner, name, methods and ciphertext in one OAEP block.
    private = directory / "recipient.pem"
    public = directory / "recipient-public.pem"
    private.write_bytes(protect.invoke(
        [openssl, "genpkey", "-algorithm", "RSA", "-pkeyopt", "rsa_keygen_bits:6144"]))
    private.chmod(0o600)
    public.write_bytes(protect.invoke([openssl, "pkey", "-in", str(private), "-pubout"]))
    return private, public


def reference_checks(openssl: str, work: Path, fixture: Path, icarus_bin: Path,
                     recipient: tuple[Path, Path], explicit: bool) -> tuple[dict, bytes]:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    body, = (part.strip(b"\r\n") for part in layout.bodies)
    headers = protect.fields(source)
    mode = headers[b"enctype"]
    named_keys = {}
    digest_key = None
    if b"digest_keyowner" in headers:
        owner, name = (headers[field] for field in DIGEST_SELECTOR)
        width = protect.CIPHERS[headers[b"digest_key_method"]][1]
        named_keys = {identity: secrets.token_bytes(width) for identity in
                      ((owner, name), (b"Fixture West", name), (owner, b"backup"))}
        digest_key = named_keys[(owner, name)]
    author = make_author_input(openssl, headers, body, digest_key)
    sign_private, sign_public = protect.exchange_key(openssl, work, "author")
    recipient_private, recipient_public = recipient
    signature = work / "author.sig"
    signature.write_bytes(protect.invoke([openssl, "dgst", "-sha256", "-sign", str(sign_private)], author))
    wire = wrap_author(openssl, sign_public, signature, recipient_public, author, mode)
    meta, keys = read_key_block(openssl, recipient_private, wire)
    digest_method = protect.fields(meta)[b"digest_method"]
    recovered, valid_digest = authenticate(openssl, keys, wire, digest_method)
    restored = work / fixture.name
    restored.write_bytes(layout.clear[0] + b"\n" + recovered + b"\n" + layout.clear[1])

    altered_digest = bytearray(payload(wire, b"digest_block").decoded)
    altered_digest[0] ^= 1
    wrong_wire = wire.replace(
        digests.encoded_block(b"digest_block", payload(wire, b"digest_block").decoded, mode),
        digests.encoded_block(b"digest_block", bytes(altered_digest), mode), 1,
    )
    wrong_digest_key = bytes([keys.digest_key[0] ^ 1]) + keys.digest_key[1:]
    wrong_keys = DigestKeys(keys.data_method, keys.data_key, keys.digest_key_method, wrong_digest_key)
    try:
        _, wrong_key_authenticated = authenticate(openssl, wrong_keys, wire, digest_method)
    except ValueError:
        wrong_key_authenticated = False
    checks = {
        "author_signature_verified": True,
        "unsigned_input_rejected": rejected(
            lambda: wrap_author(openssl, sign_public, work / "absent.sig", recipient_public, author, mode)),
        "changed_author_bytes_rejected": rejected(
            lambda: wrap_author(openssl, sign_public, signature, recipient_public, author + b"\n", mode)),
        "wrong_recipient_rejected": rejected(lambda: read_key_block(openssl, sign_private, wire)),
        "methods_and_keys_unwrapped": keys == resolve_keys(author),
        "digest_key_explicit_or_inherited": (
            (DIGEST_KEY in protect.DIRECTIVE.findall(author)) == explicit
            and (keys.digest_key != keys.data_key if explicit else keys.digest_key == keys.data_key)
            and keys.digest_key_method == headers.get(b"digest_key_method", keys.data_method)
        ),
        "both_wrapped_key_encodings": all(payload(meta, tag).encoding[b"enctype"] == mode
                                          for tag in (DATA_KEY, DIGEST_KEY)),
        "key_buffer_encoding": payload(wire, b"key_block").encoding[b"enctype"] == mode,
        "wrapped_digest_matches_author": payload(meta, b"digest_block") == payload(author, b"digest_block"),
        "key_public_key_matches_recipient": payload(wire, b"key_public_key").decoded == protect.invoke(
            [openssl, "pkey", "-in", str(recipient_private), "-pubout", "-outform", "DER"]),
        "key_material_only_in_wrapped_buffer": (
            all(keyword not in protect.DIRECTIVE.findall(wire)
                for keyword in (DATA_KEY, DIGEST_KEY))
            and all(keyword not in protect.fields(wire) for keyword in (b"data_method", b"digest_key_method"))
        ),
        "author_data_preserved": payload(wire, b"data_block") == payload(author, b"data_block"),
        "author_digest_preserved": payload(wire, b"digest_block") == payload(author, b"digest_block"),
        "body_and_digest_recovered": recovered == body and valid_digest,
        "altered_digest_detected": wrong_wire != wire and not authenticate(openssl, keys, wrong_wire, digest_method)[1],
        "wrong_digest_key_detected": not wrong_key_authenticated,
        "recovered_hdl_matches": run_icarus.run(restored, icarus_bin)[0],
    }
    if named_keys:
        checks.update(placement_controls(openssl, author, wire, meta, keys, named_keys, body, mode))
    return checks, layout.clear[0] + wire + layout.clear[1]


def native_trial(python: str, openssl: str, work: Path, recipient: tuple[Path, Path],
                 source: bytes, *, prepared: bool) -> dict:
    private, public = recipient
    variant, output = work / "native.sv", work / "native.protected.sv"
    variant.write_bytes(source)
    output.unlink(missing_ok=True)
    try:
        run = cipher.run_encryptor(python, variant, public, output)
        if run.returncode != 0 or not output.is_file():
            return {"outcome": "rejected_or_no_output", "exit": run.returncode}
        emitted = output.read_bytes()
        if prepared and emitted == source:
            return {"outcome": "prepared_input_preserved"}
        layout, recovered = boundaries.recovered_ranges(openssl, private, emitted)
    except (ValueError, KeyError, subprocess.TimeoutExpired):
        return {"outcome": "invalid_or_unreadable_output"}
    if prepared:
        if not recovered and REPEATED_END_SUFFIX.search(emitted):
            # Repair the duplicated suffix only for recovering the diagnostic
            # view. Keep the actual output classified as malformed.
            probe = REPEATED_END_SUFFIX.sub(PRAGMA + b"end_protected", emitted)
            original = protect.split(source, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
            try:
                _, probe_body = boundaries.recovered_ranges(openssl, private, probe)
            except (ValueError, KeyError, subprocess.TimeoutExpired):
                probe_body = ()
            return {
                "outcome": "prepared_input_malformed_delimiter",
                "output_ranges": len(layout.bodies),
                "prepared_contents_reencrypted": (
                    len(probe_body) == 1 and len(original.bodies) == 1
                    and probe_body[0] == b"_protected\n" + original.bodies[0].strip(b"\r\n")
                ),
            }
        return {"outcome": "prepared_input_wrapped_as_plain_source"
                if len(recovered) == 1 and protect.keeps_body(source, recovered[0])
                else "prepared_input_changed",
                "output_ranges": len(layout.bodies)}
    original = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    return {"outcome": "ordinary_body_recovered"
            if len(recovered) == 1 and protect.keeps_body(original.bodies[0], recovered[0])
            else "ordinary_body_changed",
            "ordinary_data_method_preserved": len(layout.bodies) == 1 and (
                protect.fields(layout.bodies[0]).get(b"data_method") == protect.fields(source)[b"data_method"]),
            "emitted_digest_blocks": sum(directive.strip() == b"digest_block" for part in layout.bodies
                                         for directive in protect.DIRECTIVE.findall(part))}


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
        recipient = rsa_recipient(openssl, work)
        for case, fixture in fixtures.items():
            if suite_results.header(fixture).get("expected_stdout") != CASES[case]:
                parser.error(f"unexpected HDL control output for {case}")
            controls, prepared = reference_checks(openssl, work, fixture, args.iverilog_bin, recipient,
                                                   explicit=case != DEFAULT)
            tests[case] = {
                "inputs_sha256": fingerprints[case], "reference_controls": controls,
                "native_ordinary": native_trial(python, openssl, work, recipient, fixture.read_bytes(), prepared=False),
                "native_prepared": native_trial(python, openssl, work, recipient, prepared, prepared=True),
            }
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")
    icarus_version = protect.invoke([str(args.iverilog_bin / "iverilog"), "-V"]).decode().splitlines()[0]
    run_slang.write(args.json, {
        "profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
        "openssl": protect.invoke([openssl, "version"]).decode().strip(), "icarus": icarus_version,
        "signature_mode": "detached author signature checked by the reference packager",
        "native_prepared_mode": "already formed decryption envelope passed to ordinary CLI",
        "tests": tests,
    })
    failed = False
    for case, row in tests.items():
        controls = row["reference_controls"]
        print(f"{case}: {sum(controls.values())}/{len(controls)} reference controls match")
        print(f"  ordinary: {row['native_ordinary']['outcome']}, prepared: {row['native_prepared']['outcome']}")
        failed |= (not all(controls.values()) or row["native_ordinary"]["outcome"] != "ordinary_body_recovered"
                   or not row["native_ordinary"].get("ordinary_data_method_preserved")
                   or row["native_prepared"]["outcome"] != "prepared_input_preserved")
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Check native protected-envelope digests and independently constructed controls."""

import argparse
import base64
import binascii
import hashlib
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import tempfile

import run_protect_cipher_methods as cipher
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-digests"
CHECKER = "tools/run_protect_digests.py"
CASE = "ch34/test_protect_digests_authenticate_key_and_data"
KEY_CASE = "ch34/test_protect_digest_distinguishes_registered_keys"
CASES = {CASE: "digest bodies=39,72", KEY_CASE: "digest registered=2b,58"}
DIGEST_METHOD = b'`pragma protect digest_method = "sha1"'
REQUEST = b"`pragma protect digest_block"
INPUT_ONLY = re.compile(rb"^`ifdef PROTECT_DIGEST_ENCRYPTION_INPUT\n(.*?)^`endif\n", re.M | re.S)
KEY_FIELDS = (b"digest_key_method", b"digest_keyowner", b"digest_keyname")
DIGEST_KEYS = {
    (b"Digest Fixture", b"digest-aes128"): bytes(range(16)),
    (b"Digest Fixture", b"digest-backup"): bytes(range(16, 32)),
    (b"Other Digest Fixture", b"digest-aes128"): bytes(range(32, 48)),
}
DIGESTS = {
    "sha1": ("sha1", "a9993e364706816aba3e25717850c26c9cd0d89d", True),
    "md5": ("md5", "900150983cd24fb0d6963f7d28e17f72", True),
    "md2": ("md2", "da853b0d3f88d99b30283a69e6ded6bb", False),
    "ripemd-160": ("ripemd160", "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc", False),
}
BLOCK_ORDER = (b"key_block", b"digest_block", b"data_block", b"digest_block")


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(cipher.checker_digest().encode())
    return digest.hexdigest()


def source_variant(source: bytes, method: str) -> bytes:
    active, count = INPUT_ONLY.subn(rb"\1", source)
    if count != 2 or active.count(REQUEST) != 2 or active.count(DIGEST_METHOD) != 1:
        raise ValueError("expected one digest method and two activated requests")
    return active.replace(DIGEST_METHOD, b'`pragma protect digest_method = "' + method.encode() + b'"')


def without_request(source: bytes) -> bytes:
    return protect.without_directives(source, (*KEY_FIELDS, b"encoding")).replace(
        REQUEST + b"\n", b"",
    ).strip(b"\r\n")


def message_digest(nettle: Path, method: str, data: bytes) -> bytes:
    return protect.invoke([str(nettle), "--digest", DIGESTS[method][0]], data)


def encoded_block(kind: bytes, payload: bytes, enctype: bytes) -> bytes:
    if enctype == b"base64":
        text = base64.b64encode(payload)
        encoded = b"".join(text[offset:offset + 76] + b"\n" for offset in range(0, len(text), 76))
    elif enctype == b"uuencode":
        encoded = b"".join(binascii.b2a_uu(payload[offset:offset + 45], backtick=True)
                           for offset in range(0, len(payload), 45))
    else:
        raise ValueError("unsupported fixture encoding")
    return (b'`pragma protect encoding = (enctype="' + enctype + b'", bytes='
            + str(len(payload)).encode() + b")\n`pragma protect " + kind + b"\n" + encoded)


def payloads(envelope: bytes, expected_encoding: bytes) -> tuple[bytes, ...]:
    lines = envelope.splitlines()
    directives = [(i, match[1]) for i, line in enumerate(lines)
                  if (match := protect.DIRECTIVE.fullmatch(line.strip()))]
    encoding = {}
    blocks = []
    for index, (line, expression) in enumerate(directives):
        if expression.startswith(b"encoding"):
            encoding = protect.attributes(expression)
            continue
        if expression not in BLOCK_ORDER:
            if blocks and blocks[-1][0] in (b"key_block", b"data_block"):
                raise ValueError("unrelated pragma before associated digest")
            continue
        next_line = directives[index + 1][0] if index + 1 < len(directives) else len(lines)
        data_lines = tuple(lines[line + 1:next_line])
        if not data_lines or not data_lines[0].strip():
            raise ValueError("encoded payload must start on the following line")
        if encoding.get(b"enctype") != expected_encoding:
            raise ValueError("unexpected encoding descriptor")
        clear = protect.decode_payload(data_lines, expected_encoding)
        if encoding.get(b"bytes") != str(len(clear)).encode():
            raise ValueError("encoded bytes descriptor does not match payload")
        blocks.append((expression, clear))
    if tuple(kind for kind, _ in blocks) != BLOCK_ORDER:
        raise ValueError("expected an adjacent digest for each key and data block")
    return tuple(data for _, data in blocks)


def digest_cipher(header: dict[bytes, bytes], session_key: bytes) -> tuple[str, bytes]:
    if b"digest_key_method" not in header:
        return header[b"data_method"].decode(), session_key
    selector = (header[b"digest_keyowner"], header[b"digest_keyname"])
    return header[b"digest_key_method"].decode(), DIGEST_KEYS[selector]


def seal(openssl: str, nettle: Path, method: str, key: bytes, plain: bytes) -> bytes:
    block_bytes = cipher.CIPHERS[method].block_bytes
    iv = secrets.token_bytes(block_bytes)
    padding = block_bytes - len(plain) % block_bytes
    return iv + cipher.cbc(openssl, nettle, method, "-e", key, iv, plain + bytes([padding]) * padding)


def open_cbc(openssl: str, nettle: Path, method: str, key: bytes, encoded: bytes) -> bytes:
    block_bytes = cipher.CIPHERS[method].block_bytes
    iv, ciphertext = encoded[:block_bytes], encoded[block_bytes:]
    if not ciphertext:
        raise ValueError("missing ciphertext after prefixed IV")
    plain = cipher.cbc(openssl, nettle, method, "-d", key, iv, ciphertext)
    padding = plain[-1] if plain else 0
    if not 0 < padding <= block_bytes or not plain.endswith(bytes([padding]) * padding):
        raise ValueError("incorrect CBC padding")
    return plain[:-padding]


def authenticate(openssl: str, nettle: Path, private: Path, header: dict[bytes, bytes],
                 blocks: tuple[bytes, ...]) -> tuple[tuple[bool, bool], bytes]:
    key_block, key_digest, data_block, data_digest = blocks
    key = protect.unwrap_session_key(openssl, private, protect.Block((), key_block, {}, b""))
    clear = open_cbc(openssl, nettle, header[b"data_method"].decode(), key, data_block)
    key_method, digest_key = digest_cipher(header, key)
    method = header[b"digest_method"].decode()
    verdict = tuple(open_cbc(openssl, nettle, key_method, digest_key, stored)
                    == message_digest(nettle, method, plain)
                    for stored, plain in ((key_digest, key), (data_digest, clear)))
    return verdict, clear


def reference_envelope(openssl: str, nettle: Path, public: Path, method: str, source: bytes) -> bytes:
    settings = protect.fields(source)
    enctype = settings.get(b"enctype", b"base64")
    header = {b"data_method": b"aes256-cbc", b"digest_method": method.encode(),
              **{field: settings[field] for field in KEY_FIELDS if field in settings}}
    key = secrets.token_bytes(32)
    wrapped = protect.invoke([openssl, "pkeyutl", "-encrypt", "-pubin", "-inkey", str(public),
                              "-pkeyopt", "rsa_padding_mode:oaep", "-pkeyopt", "rsa_oaep_md:sha256",
                              "-pkeyopt", "rsa_mgf1_md:sha256"], key)
    digest_method, digest_key = digest_cipher(header, key)
    body = without_request(source)
    body_cipher = seal(openssl, nettle, "aes256-cbc", key, body)
    values = (wrapped, seal(openssl, nettle, digest_method, digest_key, message_digest(nettle, method, key)),
              body_cipher, seal(openssl, nettle, digest_method, digest_key, message_digest(nettle, method, body)))
    return (b"".join(b'`pragma protect ' + field + b' = "' + value + b'"\n' for field, value in header.items())
            + b"".join(encoded_block(kind, value, enctype) for kind, value in zip(BLOCK_ORDER, values)))


def reference_controls(openssl: str, nettle: Path, private: Path, public: Path,
                       method: str, source: bytes) -> dict[str, bool]:
    envelope = reference_envelope(openssl, nettle, public, method, source)
    blocks = payloads(envelope, protect.fields(source).get(b"enctype", b"base64"))
    header = protect.fields(envelope)
    verdict, recovered = authenticate(openssl, nettle, private, header, blocks)
    controls = {"intact": verdict == (True, True) and recovered == without_request(source)}
    for label, index, expectation in (("changed_data", 2, (True, False)),
                                      ("changed_data_digest", 3, (True, False)),
                                      ("changed_key_digest", 1, (False, True))):
        changed = list(blocks)
        value = changed[index]
        changed[index] = bytes([value[0] ^ 1]) + value[1:]
        result, _ = authenticate(openssl, nettle, private, header, tuple(changed))
        controls[label] = result == expectation
    changed_method = b"sha1" if method != "sha1" else b"md5"
    result, _ = authenticate(openssl, nettle, private, {**header, b"digest_method": changed_method}, blocks)
    controls["changed_digest_method"] = result == (False, False)
    if b"digest_key_method" in header:
        fields = (b"digest_keyowner", b"digest_keyname")
        for index, field in enumerate(fields):
            try:
                digest_cipher({**header, field: b"unregistered"}, b"")
            except KeyError:
                controls["unknown_" + field.decode()] = True
            else:
                controls["unknown_" + field.decode()] = False
            for identity in DIGEST_KEYS:
                other = fields[1 - index]
                if identity[1 - index] != header[other] or identity[index] == header[field]:
                    continue
                changed_header = {**header, field: identity[index]}
                try:
                    verdict, _ = authenticate(openssl, nettle, private, changed_header, blocks)
                except ValueError:
                    verdict = (False, False)
                controls["other_" + field.decode()] = verdict == (False, False)
    return controls


def inspect_native(openssl: str, nettle: Path, private: Path, method: str,
                   output: bytes, sources: tuple[bytes, ...]) -> tuple[list, bool]:
    layout = protect.split(output, protect.OUTPUT_BEGIN, protect.OUTPUT_END, protect.FALLBACK_BEGIN)
    if len(layout.bodies) != len(sources):
        raise ValueError("unexpected number of output envelopes")
    observations = []
    for envelope, source in zip(layout.bodies, sources):
        header = protect.fields(envelope)
        requested = protect.fields(source)
        emitted = header.get(b"digest_method", b"").decode("ascii", errors="replace")
        count = sum(line.strip() == b"digest_block" for line in protect.DIRECTIVE.findall(envelope))
        clear = protect.recover(openssl, private, protect.parse_blocks(envelope))
        selected = all(header.get(field) == requested.get(field) for field in KEY_FIELDS)
        authenticated = False
        if emitted in DIGESTS and count == 2 and selected:
            verdict, authenticated_body = authenticate(
                openssl, nettle, private, header, payloads(envelope, requested.get(b"enctype", b"base64")),
            )
            authenticated = verdict == (True, True) and without_request(source) == authenticated_body
        observations.append({
            "requested_digest_key": "named_digest_key" if b"digest_key_method" in requested else "data_session_key",
            "emitted_digest_method": emitted or None, "digest_blocks": count,
            "request_in_recovered_data": REQUEST in clear, "body_recovered": without_request(clear) == without_request(source),
            "digest_key_selection_matches": selected, "authenticated": authenticated,
        })
    return observations, all(row["emitted_digest_method"] == method and row["authenticated"] for row in observations)


def compare_digests(python: str, openssl: str, nettle: Path, fixture: Path, work: Path) -> dict:
    source = fixture.read_bytes()
    private, public = protect.exchange_key(openssl, work, "fixture")
    variant, output = work / "digest.sv", work / "protected.sv"
    results = {}
    for method, (_, answer, required) in DIGESTS.items():
        active = source_variant(source, method)
        ranges = protect.split(active, protect.SOURCE_BEGIN, protect.SOURCE_END).bodies
        if len(ranges) != 2:
            raise ValueError("expected the default and explicit digest-key envelopes")
        controls = {name: reference_controls(openssl, nettle, private, public, method, part)
                    for name, part in zip(("first_envelope", "second_envelope"), ranges)}
        result = {"required": required, "known_answer": message_digest(nettle, method, b"abc").hex() == answer,
                  "reference_controls": controls, "outcome": "invalid_envelope"}
        results[method] = result
        variant.write_bytes(active)
        output.unlink(missing_ok=True)
        try:
            native = cipher.run_encryptor(python, variant, public, output)
        except subprocess.TimeoutExpired:
            result["outcome"] = "encryptor_timeout"
            continue
        if native.returncode:
            result["outcome"] = cipher.rejected_method(method, native.returncode, native.stderr + native.stdout,
                                                        required=required)
            continue
        try:
            result["envelopes"], passed = inspect_native(
                openssl, nettle, private, method, output.read_bytes() if output.is_file() else b"", ranges,
            )
        except (ValueError, KeyError, subprocess.TimeoutExpired):
            continue
        result["outcome"] = "pass" if passed else "digest_mismatch"
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--nettle-prefix", type=Path, required=True, help="Nettle headers and library prefix")
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    python, openssl = shutil.which(args.python), shutil.which(args.openssl)
    if python is None or openssl is None:
        parser.error("Python or OpenSSL is unavailable")
    fixtures = {name: suite_results.ROOT / "tests" / (name + ".sv") for name in CASES}
    fingerprints = suite_results.fingerprints(list(fixtures.values()))
    checker, tool = checker_digest(), protect.tool_info(python)
    tests = {}
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        nettle = work / "nettle"
        version = cipher.build_nettle(args.nettle_prefix, nettle)
        for name, fixture in fixtures.items():
            if suite_results.header(fixture).get("expected_stdout") != CASES[name]:
                parser.error(f"unexpected HDL control output for {name}")
            checks = compare_digests(python, openssl, nettle, fixture, work)
            tests[name] = {"inputs_sha256": fingerprints[name], "checks": checks}
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "encryptor": tool, "nettle": version,
        "openssl": protect.invoke([openssl, "version"]).decode().strip(), "checker_sha256": checker,
        "tests": tests,
    })
    failed = False
    for name, record in tests.items():
        for method, result in record["checks"].items():
            print(f"{name} {method}: {result['outcome']} (known answer: {result['known_answer']})")
            failed |= (not result["known_answer"]
                       or not all(all(row.values()) for row in result["reference_controls"].values())
                       or result["outcome"] not in ("pass", "unsupported_optional_method"))
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())

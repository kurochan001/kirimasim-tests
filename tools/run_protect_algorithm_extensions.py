#!/usr/bin/env python3
"""Qualify standard and implementation-defined protection algorithm identifiers."""

import argparse
import binascii
import hashlib
import json
from pathlib import Path
import re
import secrets
import shutil
import tempfile

import run_icarus
import run_protect_block_boundaries as boundaries
import run_protect_cipher_methods as cipher
import run_protect_digests as digest
import run_protect_encodings as encoding
import run_protect_encryption as protect
import suite_results


PROFILE = "protect-algorithm-extensions"
CHECKER = "tools/run_protect_algorithm_extensions.py"
CASE = "ch34/test_protect_registered_algorithm_extensions"
CASES = {CASE: "protection extension body=73"}
REGISTRATION = {b"enctype": b"fixture-hex", b"data_method": b"fixture-aes128-ctr",
                b"digest_method": b"fixture-sha256"}
HEX_BLOCK = re.compile(rb'^`pragma protect encoding = \(enctype="fixture-hex", bytes=(\d+)\)\n'
                       rb'`pragma protect (data_block|digest_block)\n([0-9a-f]+)\n', re.M)


class UnsupportedAlgorithm(ValueError):
    def __init__(self, field: bytes, identifier: bytes | None):
        super().__init__(f"{field!r} has an unsupported identifier {identifier!r}")
        self.field = field


def checker_digest() -> str:
    fingerprint = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    fingerprint.update(encoding.checker_digest().encode())
    fingerprint.update(digest.checker_digest().encode())
    fingerprint.update(suite_results.runner_digest("icarus").encode())
    return fingerprint.hexdigest()


def ctr(openssl: str, operation: str, key: bytes, iv: bytes, data: bytes) -> bytes:
    return protect.invoke([openssl, "enc", operation, "-aes-128-ctr", "-K", key.hex(),
                           "-iv", iv.hex(), "-nopad", "-nosalt"], data)


def hex_block(name: bytes, data: bytes) -> bytes:
    return (b'`pragma protect encoding = (enctype="fixture-hex", bytes=' + str(len(data)).encode()
            + b')\n`pragma protect ' + name + b"\n" + binascii.hexlify(data) + b"\n")


def extension_envelope(openssl: str, headers: dict[bytes, bytes], body: bytes, key: bytes) -> bytes:
    if any(headers.get(field) != identifier for field, identifier in REGISTRATION.items()):
        raise ValueError("the fixture must request the three registered extensions")
    iv = secrets.token_bytes(16)
    methods = (b'`pragma protect ' + field + b' = "' + headers[field] + b'"\n'
               for field in (b"data_method", b"digest_method"))
    return (b"`pragma protect begin_protected\n" + b"".join(methods)
            + hex_block(b"data_block", iv + ctr(openssl, "-e", key, iv, body))
            + hex_block(b"digest_block", hashlib.sha256(body).digest())
            + b"`pragma protect end_protected\n")


def open_extension(openssl: str, wire: bytes, key: bytes, registry: dict[bytes, bytes]) -> bytes:
    envelope, = protect.split(wire, protect.OUTPUT_BEGIN, protect.OUTPUT_END).bodies
    headers = protect.fields(envelope)
    for field, expected in REGISTRATION.items():
        declared = headers.get(field)
        if declared != expected or registry.get(field) != declared:
            raise UnsupportedAlgorithm(field, declared)
    blocks = {}
    for count, name, text in HEX_BLOCK.findall(envelope):
        data = bytes.fromhex(text.decode("ascii"))
        if len(data) != int(count) or name in blocks:
            raise ValueError("wrong decoded count or duplicate block")
        blocks[name] = data
    if set(blocks) != {b"data_block", b"digest_block"}:
        raise ValueError("missing extension payload block")
    iv, ciphertext = blocks[b"data_block"][:16], blocks[b"data_block"][16:]
    body = ctr(openssl, "-d", key, iv, ciphertext)
    if protect.invoke([openssl, "dgst", "-sha256", "-binary"], body) != blocks[b"digest_block"]:
        raise ValueError("digest does not authenticate the recovered body")
    return body


def rejected_identifier(openssl: str, wire: bytes, key: bytes, field: bytes) -> bool:
    registry = {name: value for name, value in REGISTRATION.items() if name != field}
    try:
        open_extension(openssl, wire, key, registry)
    except UnsupportedAlgorithm as error:
        return error.field == field
    return False


def extension_vectors(openssl: str) -> dict[str, bool]:
    # NIST SP 800-38A F.5.1, the first two CTR-AES128 blocks.
    key = bytes.fromhex("2b7e151628aed2a6abf7158809cf4f3c")
    counter = bytes.fromhex("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff")
    plain = bytes.fromhex("6bc1bee22e409f96e93d7e117393172a" "ae2d8a571e03ac9c9eb76fac45af8e51")
    ciphertext = bytes.fromhex("874d6191b620e3261bef6864990db6ce" "9806f66b7970fdff8617187bb9fffdff")
    expected_hash = bytes.fromhex("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    block = HEX_BLOCK.fullmatch(hex_block(b"data_block", b"\x00\xff=\n"))
    return {
        "hex_preserves_octets_and_length": block is not None and block.groups() == (b"4", b"data_block", b"00ff3d0a"),
        "aes128_ctr_known_answer": ctr(openssl, "-e", key, counter, plain) == ciphertext
                                   and ctr(openssl, "-d", key, counter, ciphertext) == plain,
        "sha256_known_answer": hashlib.sha256(b"abc").digest() == expected_hash ==
                              protect.invoke([openssl, "dgst", "-sha256", "-binary"], b"abc"),
    }


def reference_checks(openssl: str, nettle: Path, iverilog: Path, fixture: Path, work: Path) -> dict:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    body, = (block.strip(b"\r\n") for block in layout.bodies)
    key = secrets.token_bytes(16)
    wire = extension_envelope(openssl, protect.fields(source), body, key)
    recovered = open_extension(openssl, wire, key, REGISTRATION)
    restored = work / fixture.name
    restored.write_bytes(layout.clear[0] + b"\n" + recovered + b"\n" + layout.clear[-1])
    # Reuse the existing required and optional vectors, independently of the extension registry.
    return {
        "standard_encodings": encoding.byte_controls(),
        "standard_cbc": {method: cipher.reference_control(openssl, nettle, method, body)
                         for method in cipher.CIPHERS},
        "standard_digests": {method: digest.message_digest(nettle, method, b"abc").hex() == answer
                             for method, (_, answer, _) in digest.DIGESTS.items()},
        "extension_vectors": extension_vectors(openssl),
        "registered_extensions_recover_body": recovered == body and run_icarus.run(restored, iverilog)[0],
        "unregistered_identifiers": {field.decode(): rejected_identifier(openssl, wire, key, field)
                                     for field in REGISTRATION},
        "required_cbc": cipher.REQUIRED,
    }


def native_observation(python: str, openssl: str, fixture: Path, work: Path) -> dict:
    private, public = protect.exchange_key(openssl, work, "cli")
    output = work / "native.sv"
    result = cipher.run_encryptor(python, fixture, public, output)
    if result.returncode != 0 or not output.is_file():
        return {"outcome": "rejected_or_no_output", "exit": result.returncode}
    try:
        layout, recovered = boundaries.recovered_ranges(openssl, private, output.read_bytes())
        envelope, = layout.bodies
        body, = recovered
    except (KeyError, ValueError):
        return {"outcome": "invalid_or_unreadable_output"}
    original, = protect.split(fixture.read_bytes(), protect.SOURCE_BEGIN, protect.SOURCE_END).bodies
    headers = protect.fields(envelope)
    return {"outcome": "emitted", "body_recovered": protect.keeps_body(original, body),
            "requested": {name.decode(): value.decode() for name, value in REGISTRATION.items()},
            "emitted": {name.decode(): headers[name].decode() if name in headers else None
                        for name in REGISTRATION}}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--nettle-prefix", type=Path, required=True)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, openssl = shutil.which(args.python), shutil.which(args.openssl)
    if python is None or openssl is None or not (args.iverilog_bin / "iverilog").is_file():
        parser.error("Python, OpenSSL or Icarus is unavailable")
    fixture = suite_results.ROOT / "tests" / (CASE + ".sv")
    inputs = suite_results.input_digest(fixture)
    checker, tool = checker_digest(), protect.tool_info(python)
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        helper = work / "nettle-helper"
        nettle_version = cipher.build_nettle(args.nettle_prefix, helper)
        reference = reference_checks(openssl, helper, args.iverilog_bin, fixture, work)
        native = native_observation(python, openssl, fixture, work)
    if (checker != checker_digest() or inputs != suite_results.input_digest(fixture)
            or tool != protect.tool_info(python)):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    passed = (reference["registered_extensions_recover_body"] and
              all(all(reference[field].values()) for field in
                  ("standard_encodings", "standard_cbc", "standard_digests", "extension_vectors",
                   "unregistered_identifiers")))
    record = {"profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
              "openssl": suite_results.tool_version([openssl, "version"]), "nettle": nettle_version,
              "icarus": suite_results.tool_version([str(args.iverilog_bin / "iverilog"), "-V"]),
              "tests": {CASE: {"inputs_sha256": inputs, "reference": reference, "native": native, "pass": passed}}}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: reference {'pass' if passed else 'fail'}, native {native}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

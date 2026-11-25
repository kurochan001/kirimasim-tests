#!/usr/bin/env python3
"""Qualify protected payload block placement and nested re-encryption."""

import argparse
import hashlib
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import tempfile

import run_protect_cipher_methods as cipher
import run_protect_digests as digests
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-block-boundaries"
CHECKER = "tools/run_protect_block_boundaries.py"
PLAINTEXT = "ch34/test_protect_reject_plaintext_payload_blocks"
NESTED = "ch34/test_protect_reencrypt_nested_envelope"
CASES = {PLAINTEXT: "plaintext control=31", NESTED: "outer=24,69 clear=17"}
DIAGNOSTIC_REQUIREMENTS = {
    "SV2023-34.5.1.2-EXTRACT-NO-ENCRYPTION-NESTING",
    "SV2023-34.5.15.2-EXTRACT-INPUT-BLOCK-ERROR",
    "SV2023-34.5.27.2-EXTRACT-KEY-BLOCK-INPUT-ERROR",
}
DIAGNOSTIC_ANCHOR = "def rejected_at_variant("
POSITIONS = (b"// Plaintext file payload position", b"// Plaintext envelope payload position")
NESTED_POSITION = b"// Nested envelope qualification position"
INNER_BODY = b"module protect_previous; initial begin end endmodule"
INNER_KEY = b"data_decrypt_key"


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(digests.checker_digest().encode())
    return digest.hexdigest()


def seal(openssl: str, method: bytes, key: bytes, source: bytes) -> bytes:
    option, key_bytes = protect.CIPHERS[method]
    if len(key) != key_bytes:
        raise ValueError("unexpected fixture key width")
    iv = secrets.token_bytes(16)
    return iv + protect.invoke([openssl, "enc", "-e", "-" + option,
                                "-K", key.hex(), "-iv", iv.hex()], source)


def text_key(source: bytes) -> tuple[bytes, bytes]:
    lines = source.splitlines()
    positions = [i for i, line in enumerate(lines) if line == b"`pragma protect " + INNER_KEY]
    if len(positions) != 1 or positions[0] + 2 != len(lines):
        raise ValueError("expected one next-line data key")
    header = protect.fields(source[:source.index(b"`pragma protect " + INNER_KEY)])
    method = header[b"data_method"]
    key = protect.decode_payload((lines[positions[0] + 1],), header[b"enctype"])
    if len(key) != protect.CIPHERS[method][1] or header.get(b"bytes") != str(len(key)).encode():
        raise ValueError("incorrect decoded key length")
    return method, key


def restore_inner(openssl: str, exchange: bytes, envelope: bytes, *, changed_block: bytes | None = None) -> bytes:
    header = protect.fields(envelope)
    blocks = protect.parse_blocks(envelope)
    wrapped, data = (blocks[tag].decoded for tag in protect.BLOCKS)
    if changed_block == b"key_block":
        wrapped = bytes([wrapped[0] ^ 1]) + wrapped[1:]
    if not all(protect.has_descriptor(block) for block in blocks.values()):
        raise ValueError("missing encoded descriptor")
    decoded_key = protect.decrypt_body(openssl, header[b"key_method"], exchange, wrapped)
    method, key = text_key(decoded_key)
    if changed_block == b"data_block":
        data = bytes([data[0] ^ 1]) + data[1:]
    return protect.decrypt_body(openssl, method, key, data)


def previously_encrypted(openssl: str) -> tuple[bytes, dict]:
    exchange = secrets.token_bytes(16)
    data_key = secrets.token_bytes(32)
    method = b"aes256-cbc"
    encoded_key = b'`pragma protect data_method = "aes256-cbc"\n' + digests.encoded_block(
        INNER_KEY, data_key, b"base64",
    )
    key_payload = seal(openssl, b"aes128-cbc", exchange, encoded_key)
    data_payload = seal(openssl, method, data_key, INNER_BODY)
    inner = (b'`pragma protect begin_protected\n`pragma protect key_method = "aes128-cbc"\n'
             + digests.encoded_block(b"key_block", key_payload, b"base64")
             + digests.encoded_block(b"data_block", data_payload, b"base64")
             + b"`pragma protect end_protected")
    checks = {"structured_key_and_body": restore_inner(openssl, exchange, inner) == INNER_BODY}
    try:
        restore_inner(openssl, exchange, inner, changed_block=b"key_block")
    except (ValueError, KeyError):
        checks["changed_key_iv_rejected"] = True
    else:
        checks["changed_key_iv_rejected"] = False
    checks["changed_data_iv_detected"] = restore_inner(
        openssl, exchange, inner, changed_block=b"data_block",
    ) != INNER_BODY
    return inner, checks


def recovered_ranges(openssl: str, private: Path, output: bytes) -> tuple[protect.Layout, tuple[bytes, ...]]:
    layout = protect.split(output, protect.OUTPUT_BEGIN, protect.OUTPUT_END, protect.FALLBACK_BEGIN)
    return layout, tuple(protect.recover(openssl, private, protect.parse_blocks(body)) for body in layout.bodies)


def verify_outer(openssl: str, private: Path, source: bytes, output: bytes) -> dict:
    original = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    layout, recovered = recovered_ranges(openssl, private, output)
    clear = len(layout.clear) == len(original.clear) and all(
        protect.without_directives(before, protect.CONTROLS) == protect.without_directives(after, protect.CONTROLS)
        for before, after in zip(original.clear, layout.clear)
    )
    bodies = len(recovered) == len(original.bodies) and all(
        protect.keeps_body(expected, recovered_body)
        for expected, recovered_body in zip(original.bodies, recovered)
    )
    header = protect.fields(layout.bodies[0]) if len(layout.bodies) == 1 else {}
    descriptors = protect.parse_blocks(layout.bodies[0]) if len(layout.bodies) == 1 else {}
    return {
        "outer_begin_protected": bool(layout.opened) and all(layout.opened),
        "outside_source_preserved": clear,
        "complete_input_range_recovered": bodies,
        "input_method_matches": header.get(b"data_method") == b"aes256-cbc",
        "expected_exchange_identity": (header.get(b"key_keyowner"), header.get(b"key_keyname")) ==
                                      (b"Qualification", b"fixture-only"),
        "base64_descriptors": len(descriptors) == 2 and all(protect.has_descriptor(b) for b in descriptors.values()),
        "post_inner_module_in_clear": any(b"module protect_outer_after(" in part for part in layout.clear),
    }


def rejected_at_variant(run: subprocess.CompletedProcess, path: Path, number: int, expression: bytes) -> bool:
    if run.returncode <= 0:
        return False
    location = rb"(?:^|[/\s])" + re.escape(path.name.encode()) + str(f":{number}:").encode()
    return any(re.search(location, line) and b"error" in line.lower() and expression in line.lower()
               for line in (run.stdout + run.stderr).splitlines())


def observe_invalid(python: str, openssl: str, private: Path, public: Path, work: Path,
                    source: bytes, trigger: bytes, term: bytes) -> dict:
    variant, output = work / "invalid.sv", work / "invalid.protected.sv"
    if source.count(trigger) != 1:
        raise ValueError("ambiguous invalid input line")
    line = source[:source.index(trigger)].count(b"\n") + 1
    variant.write_bytes(source)
    output.unlink(missing_ok=True)
    run = cipher.run_encryptor(python, variant, public, output)
    result = {"exit": run.returncode, "rejected_at_directive": rejected_at_variant(run, variant, line, term)}
    if run.returncode == 0 and output.is_file():
        try:
            _, bodies = recovered_ranges(openssl, private, output.read_bytes())
        except (ValueError, KeyError):
            result["recovered"] = False
        else:
            result["recovered"] = bool(bodies)
            result["trigger_preserved_in_recovered_source"] = any(trigger in body for body in bodies)
    return result


def run_case(python: str, openssl: str, fixture: Path, work: Path, case: str) -> dict:
    private, public = protect.exchange_key(openssl, work, "fixture")
    source = fixture.read_bytes()
    if case == PLAINTEXT:
        baseline = protect.encrypt(python, fixture, public, work / "plain.protected.sv",
                                   (b"Qualification", b"fixture-only"))
        control = verify_outer(openssl, private, source, baseline)
        observations = {}
        for marker, where in zip(POSITIONS, ("file", "plaintext_envelope")):
            if source.count(marker) != 1:
                raise ValueError("missing plaintext fixture position")
            for kind in protect.BLOCKS:
                trigger = b"`pragma protect " + kind
                block = digests.encoded_block(kind, b"fixture-owned input", b"base64")
                altered = source.replace(marker, block.rstrip(b"\n"))
                observations[where + "_" + kind.decode()] = observe_invalid(
                    python, openssl, private, public, work, altered, trigger, kind,
                )
        return {"invalid": observations, "ordinary_control": control}

    if source.count(NESTED_POSITION) != 1:
        raise ValueError("missing nested fixture position")
    ordinary_nested = b"`pragma protect begin\n" + INNER_BODY + b"\n`pragma protect end"
    altered = source.replace(NESTED_POSITION, ordinary_nested)
    variant, output = work / "invalid.sv", work / "invalid.protected.sv"
    variant.write_bytes(altered)
    nested_line = source[:source.index(NESTED_POSITION)].count(b"\n") + 1
    run = cipher.run_encryptor(python, variant, public, output)
    nested = {"exit": run.returncode, "rejected_at_directive": rejected_at_variant(run, variant, nested_line, b"nest")}

    inner, controls = previously_encrypted(openssl)
    active = source.replace(NESTED_POSITION, inner)
    body, = protect.split(active, protect.SOURCE_BEGIN, protect.SOURCE_END).bodies
    body = body.strip(b"\r\n")
    padding_key = secrets.token_bytes(32)
    padded = b"// producer padding\n" + body + b"\n/* trailing producer padding */"
    changed = b"module unrelated_padding; endmodule\n" + body
    for label, candidate, expected in (("comment_padding_permitted", padded, True),
                                       ("extra_hdl_rejected", changed, False)):
        ciphertext = seal(openssl, b"aes256-cbc", padding_key, candidate)
        decoded = protect.decrypt_body(openssl, b"aes256-cbc", padding_key, ciphertext)
        controls[label] = protect.keeps_body(body, decoded) == expected
    variant = work / "nested.sv"
    variant.write_bytes(active)
    output = work / "nested.protected.sv"
    protected = protect.encrypt(python, variant, public, output, (b"Qualification", b"fixture-only"))
    try:
        observed = verify_outer(openssl, private, active, protected)
    except (ValueError, KeyError):
        observed = {
            "invalid_output_layout": True,
            "post_inner_module_in_clear": b"module protect_outer_after(" in protected,
        }
    return {"invalid_nested": nested, "previously_encrypted": observed, "reference_controls": controls}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    python, openssl = shutil.which(args.python), shutil.which(args.openssl)
    if python is None or openssl is None:
        parser.error("Python or OpenSSL is unavailable")
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    fingerprints = suite_results.fingerprints(list(fixtures.values()))
    checker, tool = checker_digest(), protect.tool_info(python)
    cases = {}
    for case, fixture in fixtures.items():
        if suite_results.header(fixture).get("expected_stdout") != CASES[case]:
            parser.error(f"unexpected HDL control output for {case}")
        with tempfile.TemporaryDirectory() as work:
            observed = run_case(python, openssl, fixture, Path(work), case)
        cases[case] = {"inputs_sha256": fingerprints[case], **observed}
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")
    run_slang.write(args.json, {"profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
                               "openssl": protect.invoke([openssl, "version"]).decode().strip(), "tests": cases})
    invalid = sum(not record["rejected_at_directive"] for record in cases[PLAINTEXT]["invalid"].values())
    ordinary = cases[PLAINTEXT]["ordinary_control"]
    nested = cases[NESTED]
    reference = nested["reference_controls"]
    outer = nested["previously_encrypted"]
    outer_ok = not any(outer.get(name) is not wanted for name, wanted in (
        ("outer_begin_protected", True), ("outside_source_preserved", True),
        ("complete_input_range_recovered", True), ("input_method_matches", True),
        ("expected_exchange_identity", True), ("base64_descriptors", True),
        ("post_inner_module_in_clear", False),
    ))
    print(f"Plaintext rejections at the directive: {4 - invalid}/4")
    print(f"Ordinary plaintext body recovers: {ordinary['complete_input_range_recovered']}")
    print(f"Nested plaintext rejection at the directive: {nested['invalid_nested']['rejected_at_directive']}")
    print(f"Previously encrypted bytes and enclosing boundaries match: {outer_ok}")
    print(f"CBC key and data controls: {sum(reference.values())}/{len(reference)}")
    return int(invalid != 0 or not ordinary["complete_input_range_recovered"]
               or not nested["invalid_nested"]["rejected_at_directive"]
               or not outer_ok or not all(reference.values()))


if __name__ == "__main__":
    raise SystemExit(main())

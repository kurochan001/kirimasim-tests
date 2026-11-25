#!/usr/bin/env python3
"""Check protect encoding requests against native output and binary-safe controls."""

import argparse
import binascii
from dataclasses import dataclass
import hashlib
from io import BytesIO
from pathlib import Path
import re
import secrets
import shutil
import tempfile

import run_protect_block_boundaries as boundaries
import run_protect_cipher_methods as cipher
import run_protect_digests as digests
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-encodings"
CHECKER = "tools/run_protect_encodings.py"
MATRIX = "ch34/test_protect_encoding_selects_output_representation"
FIELDS = "ch34/test_protect_encoding_uses_separate_field_descriptors"
CASES = {MATRIX: "encoding body=94", FIELDS: "encoding fields=29,71"}
ENCODINGS = {b"base64": True, b"uuencode": True, b"quoted-printable": False, b"raw": False}
FIELD_ENCODINGS = {
    b"data_public_key": b"base64",
    b"data_decrypt_key": b"uuencode",
    b"key_public_key": b"quoted-printable",
    b"key_block": b"base64",
    b"digest_block": b"uuencode",
    b"data_block": b"raw",
}
REQUEST = b'enctype="base64"'


@dataclass(frozen=True)
class Field:
    enctype: bytes
    decoded: bytes


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(boundaries.checker_digest().encode())
    return digest.hexdigest()


def encode_field(kind: bytes, enctype: bytes, payload: bytes) -> bytes:
    if enctype in (b"base64", b"uuencode"):
        return digests.encoded_block(kind, payload, enctype)
    if enctype == b"quoted-printable":
        text = binascii.b2a_qp(payload, quotetabs=True, istext=False)
    elif enctype == b"raw":
        text = payload
    else:
        raise ValueError("unsupported reference encoding")
    return (b'`pragma protect encoding=(enctype="' + enctype + b'", bytes='
            + str(len(payload)).encode() + b")\n`pragma protect " + kind + b"\n" + text + b"\n")


def quoted_printable_text(lines: list[bytes] | tuple[bytes, ...]) -> bytes:
    return b"".join(lines).removesuffix(b"\n").removesuffix(b"\r")


def encoded_lines(stream: BytesIO, quoted_printable_bytes: int | None = None) -> tuple[bytes, ...]:
    lines = []
    while True:
        position = stream.tell()
        line = stream.readline()
        if not line:
            break
        if protect.DIRECTIVE.fullmatch(line.strip()):
            # A soft break can put literal pragma text at the start of a QP line.
            if (quoted_printable_bytes is None or
                    len(binascii.a2b_qp(quoted_printable_text(lines))) >= quoted_printable_bytes):
                stream.seek(position)
                break
        lines.append(line)
    return tuple(lines)


def read_payload(stream: BytesIO, enctype: bytes, count: int) -> bytes:
    if enctype == b"raw":
        data = stream.read(count)
        if stream.readline() not in (b"\n", b"\r\n"):
            raise ValueError("raw payload is not followed by a separator")
    else:
        lines = encoded_lines(stream, count if enctype == b"quoted-printable" else None)
        if enctype == b"quoted-printable":
            text = quoted_printable_text(lines)
            if re.search(rb"=(?![0-9a-fA-F]{2}|\r?\n)", text):
                raise ValueError("invalid quoted-printable escape")
            data = binascii.a2b_qp(text)
        else:
            data = protect.decode_payload(tuple(line.rstrip(b"\r\n") for line in lines), enctype)
    if len(data) != count:
        raise ValueError("decoded bytes do not match the encoding descriptor")
    return data


def read_fields(envelope: bytes) -> dict[bytes, Field]:
    stream = BytesIO(envelope)
    descriptor = {}
    fields = {}
    for line in stream:
        match = protect.DIRECTIVE.fullmatch(line.strip())
        if match is None:
            if line.strip():
                raise ValueError("unexpected bytes outside a payload")
            continue
        expression = match[1]
        if expression.startswith(b"encoding"):
            descriptor = protect.attributes(expression)
        elif expression in FIELD_ENCODINGS:
            if expression in fields or b"enctype" not in descriptor or b"bytes" not in descriptor:
                raise ValueError("duplicate payload or missing descriptor")
            enctype = descriptor[b"enctype"]
            data = read_payload(stream, enctype, int(descriptor[b"bytes"]))
            fields[expression] = Field(enctype, data)
            descriptor = {}
    return fields


def byte_controls() -> dict:
    # Signal-looking text in a raw block remains data according to the byte count.
    all_octets = bytes(range(256)) + b"\n`pragma protect data_block\n\x00"
    results = {mode.decode(): read_fields(encode_field(b"data_block", mode, all_octets)) ==
               {b"data_block": Field(mode, all_octets)} for mode in ENCODINGS}
    vector = b'`pragma protect encoding=(enctype="uuencode", bytes=3)\n`pragma protect data_block\n#0V%T\n'
    results["historical_uuencode_vector"] = read_fields(vector)[b"data_block"].decoded == b"Cat"
    return results


def mixed_field_control(openssl: str, private: Path, public: Path, source: bytes) -> dict:
    public_der = protect.invoke([openssl, "pkey", "-pubin", "-in", str(public), "-outform", "DER"])
    key = secrets.token_bytes(32)
    wrapped = protect.invoke([openssl, "pkeyutl", "-encrypt", "-pubin", "-inkey", str(public),
                              "-pkeyopt", "rsa_padding_mode:oaep", "-pkeyopt", "rsa_oaep_md:sha256",
                              "-pkeyopt", "rsa_mgf1_md:sha256"], key)
    digest = hashlib.sha1(source).digest()
    values = {
        b"data_public_key": public_der, b"key_public_key": public_der,
        b"data_decrypt_key": key, b"key_block": wrapped,
        b"digest_block": boundaries.seal(openssl, b"aes256-cbc", key, digest),
        b"data_block": boundaries.seal(openssl, b"aes256-cbc", key, source),
    }
    expected = {kind: Field(mode, values[kind]) for kind, mode in FIELD_ENCODINGS.items()}
    envelope = b"".join(encode_field(kind, f.enctype, f.decoded) for kind, f in expected.items())
    recovered = read_fields(envelope)
    out = {kind.decode(): recovered[kind] == f for kind, f in expected.items()}
    block_pair = {kind: protect.Block((), recovered[kind].decoded, {}, b"") for kind in protect.BLOCKS}
    out["body_recovered"] = protect.recover(openssl, private, block_pair) == source
    out["digest_recovered"] = protect.decrypt_body(
        openssl, b"aes256-cbc", recovered[b"data_decrypt_key"].decoded, recovered[b"digest_block"].decoded,
    ) == digest
    for label, changed in (
        ("wrong_codec_detected", envelope.replace(b'enctype="raw"', b'enctype="base64"', 1)),
        ("wrong_count_detected", envelope.replace(
            b'bytes=' + str(len(values[b"data_block"])).encode() + b")\n`pragma protect data_block",
            b'bytes=' + str(len(values[b"data_block"]) - 1).encode() + b")\n`pragma protect data_block", 1,
        )),
    ):
        try:
            different = read_fields(changed) != expected
        except (ValueError, KeyError):
            different = True
        out[label] = different
    return out


def inspect_wire(openssl: str, private: Path, output: bytes, expected: tuple[bytes, ...],
                 requested: tuple[bytes, ...]) -> list[dict]:
    layout = protect.split(output, protect.OUTPUT_BEGIN, protect.OUTPUT_END, protect.FALLBACK_BEGIN)
    if len(layout.bodies) != len(expected):
        raise ValueError("encrypted range count differs")
    checks = []
    for original, envelope, mode in zip(expected, layout.bodies, requested):
        try:
            fields = read_fields(envelope)
        except ValueError:
            # Native output may remain readable despite missing encoding descriptors.
            blocks = protect.parse_blocks(envelope)
            encodings = {kind.decode(): blocks[kind].encoding.get(b"enctype", b"").decode() or None
                         for kind in protect.BLOCKS}
            recovered_using = {kind.decode(): blocks[kind].encoding.get(b"enctype", b"base64").decode()
                               for kind in protect.BLOCKS}
            valid = False
        else:
            blocks = {kind: protect.Block((), fields[kind].decoded, {}, b"") for kind in protect.BLOCKS}
            encodings = {kind.decode(): fields[kind].enctype.decode() for kind in protect.BLOCKS}
            recovered_using = encodings
            valid = all(fields[kind].enctype == mode for kind in protect.BLOCKS)
        recovered = protect.recover(openssl, private, blocks)
        checks.append({
            "requested": mode.decode(), "emitted_encodings": encodings,
            "decoded_using": recovered_using,
            "body_recovered": protect.keeps_body(original, recovered),
            "requested_encodings_and_counts_match": valid,
        })
    return checks


def run_request(python: str, openssl: str, work: Path, private: Path, public: Path,
                source: bytes, requested: tuple[bytes, ...]) -> dict:
    variant, output = work / "encoding.sv", work / "encoded.sv"
    variant.write_bytes(source)
    output.unlink(missing_ok=True)
    run = cipher.run_encryptor(python, variant, public, output)
    if run.returncode:
        unsupported = False
        if run.returncode > 0 and len(requested) == 1 and not ENCODINGS[requested[0]]:
            label = rb"(?<![\w-])" + re.escape(requested[0]) + rb"(?![\w-])"
            unsupported = any(re.search(label, line) and
                              re.search(rb"unsupported|not supported|unknown encoding", line)
                              for line in (run.stderr + run.stdout).lower().splitlines())
        return {"outcome": "unsupported_optional_encoding" if unsupported else "encryptor_error"}
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    try:
        checks = inspect_wire(openssl, private, output.read_bytes(), layout.bodies, requested)
    except (ValueError, KeyError, FileNotFoundError):
        return {"outcome": "invalid_or_unreadable_payload"}
    match = all(row["body_recovered"] and row["requested_encodings_and_counts_match"] for row in checks)
    return {"outcome": "pass" if match else "encoding_mismatch", "ranges": checks}


def run_case(python: str, openssl: str, fixture: Path, work: Path, case: str) -> dict:
    private, public = protect.exchange_key(openssl, work, "fixture")
    source = fixture.read_bytes()
    if source.count(REQUEST) != 1:
        raise ValueError("expected one explicit base64 request")
    if case == MATRIX:
        controls = byte_controls()
        runs = {mode.decode(): run_request(
            python, openssl, work, private, public, source.replace(REQUEST, b'enctype="' + mode + b'"'), (mode,),
        ) for mode in ENCODINGS}
    else:
        layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
        controls = mixed_field_control(openssl, private, public, layout.bodies[-1].strip(b"\r\n"))
        runs = {"separate_ranges": run_request(
            python, openssl, work, private, public, source, (b"base64", b"uuencode"),
        )}
    return {"reference_controls": controls, "native": runs}


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
    tests = {}
    for case, fixture in fixtures.items():
        if suite_results.header(fixture).get("expected_stdout") != CASES[case]:
            parser.error(f"unexpected HDL control output for {case}")
        with tempfile.TemporaryDirectory() as directory:
            checks = run_case(python, openssl, fixture, Path(directory), case)
        tests[case] = {"inputs_sha256": fingerprints[case], **checks}
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")
    run_slang.write(args.json, {"profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
                               "openssl": protect.invoke([openssl, "version"]).decode().strip(), "tests": tests})
    failed = False
    for case, row in tests.items():
        controls = row["reference_controls"]
        print(f"{case}: {sum(controls.values())}/{len(controls)} reference controls match")
        for name, result in row["native"].items():
            print(f"{name}: {result['outcome']}")
        failed |= not all(controls.values()) or any(
            r["outcome"] not in ("pass", "unsupported_optional_encoding") for r in row["native"].values()
        )
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())

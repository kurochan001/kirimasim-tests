#!/usr/bin/env python3
"""Compare protection envelopes alone, together and in reverse order."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import tempfile

import run_icarus
import run_protect_author_digests as author
import run_protect_block_boundaries as boundaries
import run_protect_digests as digest
import run_protect_encryption as protect
import suite_results


PROFILE = "protect-envelope-isolation"
CHECKER = "tools/run_protect_envelope_isolation.py"
CASE = "ch34/test_protect_independent_models_and_comments"
CASES = {CASE: "protected independent=49,a2"}
SELECTOR = (b"key_keyowner", b"key_keyname")
COMMENT = re.compile(rb"^[ \t]*" + protect.PRAGMA + rb'comment[ \t]*=[ \t]*"[^"\r\n]+"[ \t]*\r?$', re.M)
EXPECTED_COMMENTS = (
    (b"First model prefix", b"Included first model notice"),
    (b"Second model suffix",),
)


def checker_digest() -> str:
    fingerprint = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    fingerprint.update(author.checker_digest().encode())
    return fingerprint.hexdigest()


def preprocess(iverilog: Path, fixture: Path, output: Path) -> bytes:
    sources, include_dirs = suite_results.files(fixture)
    protect.invoke([str(iverilog / "iverilog"), "-g2012", "-E", "-o", str(output),
                    *[f"-I{path}" for path in include_dirs], *map(str, sources), str(fixture)])
    return output.read_bytes()


def comment_lines(text: bytes) -> tuple[bytes, ...]:
    return tuple(match.group().strip() for match in COMMENT.finditer(text))


def comment_values(lines: tuple[bytes, ...]) -> tuple[bytes, ...]:
    return tuple(protect.attributes(line)[b"comment"] for line in lines)


def seal_model(openssl: str, public: Path, headers: dict[bytes, bytes], body: bytes,
               comments: tuple[bytes, ...]) -> bytes:
    method, mode = headers[b"data_method"], headers[b"enctype"]
    key = secrets.token_bytes(protect.CIPHERS[method][1])
    wrapped = protect.invoke([openssl, "pkeyutl", "-encrypt", "-pubin", "-inkey", str(public),
                              "-pkeyopt", "rsa_padding_mode:oaep", "-pkeyopt", "rsa_oaep_md:sha256",
                              "-pkeyopt", "rsa_mgf1_md:sha256"], key)
    data = boundaries.seal(openssl, method, key, body)
    descriptor, payload = digest.encoded_block(b"data_block", data, mode).split(b"\n", 1)
    return (b"`pragma protect begin_protected\n"
            + author.method_line(b"key_method", b"rsa")
            + author.field_text(headers, (*SELECTOR, b"data_method"))
            + digest.encoded_block(b"key_block", wrapped, mode)
            + descriptor + b"\n" + b"".join(line + b"\n" for line in comments) + payload
            + b"`pragma protect end_protected\n")


def open_models(openssl: str, wire: bytes, keys: dict[tuple[bytes, ...], Path]) -> tuple[bytes, ...]:
    models = []
    for envelope in protect.split(wire, protect.OUTPUT_BEGIN, protect.OUTPUT_END).bodies:
        headers = protect.fields(envelope)
        if any(field not in headers for field in (*SELECTOR, b"data_method")) or headers.get(b"key_method") != b"rsa":
            raise ValueError("missing local key or cipher selection")
        blocks = protect.parse_blocks(envelope)
        if set(blocks) != set(protect.BLOCKS) or not all(
            protect.has_descriptor(block, block.encoding.get(b"enctype", b"base64")) for block in blocks.values()
        ):
            raise ValueError("missing local descriptor or payload")
        private = keys[tuple(headers[field] for field in SELECTOR)]
        key = protect.unwrap_session_key(openssl, private, blocks[b"key_block"])
        models.append(protect.decrypt_body(openssl, headers[b"data_method"], key, blocks[b"data_block"].decoded))
    return tuple(models)


def comments_before_data(envelope: bytes) -> tuple[bytes, ...]:
    lines = envelope.splitlines()
    position = lines.index(b"`pragma protect data_block")
    start = position
    while start > 0 and COMMENT.fullmatch(lines[start - 1]):
        start -= 1
    return tuple(lines[start:position])


def reference_checks(openssl: str, iverilog: Path, fixture: Path, expanded: bytes, work: Path) -> dict:
    source = protect.split(expanded, protect.SOURCE_BEGIN, protect.SOURCE_END)
    if len(source.bodies) != len(EXPECTED_COMMENTS):
        raise ValueError("expected two independently configured models")
    comments = tuple(comment_lines(clear) + comment_lines(body)
                     for clear, body in zip(source.clear[:-1], source.bodies, strict=True))
    headers = tuple(protect.fields(clear) for clear in source.clear[:-1])
    clear_models = tuple(protect.without_directives(body, (b"comment",)).strip(b"\r\n") for body in source.bodies)
    keys, envelopes = {}, []
    for index, (header, body, notices) in enumerate(zip(headers, clear_models, comments, strict=True)):
        identity = tuple(header[field] for field in SELECTOR)
        private, public = protect.exchange_key(openssl, work, f"model-{index}")
        keys[identity] = private
        envelopes.append(seal_model(openssl, public, header, body, notices))
    first, second = envelopes
    adjacent = open_models(openssl, first + second, keys)
    incomplete = second.replace(author.method_line(b"data_method", headers[1][b"data_method"]), b"", 1)
    try:
        open_models(openssl, first + incomplete, keys)
    except ValueError as error:
        missing_rejected = str(error) == "missing local key or cipher selection"
    else:
        missing_rejected = False
    restored = work / fixture.name
    restored.write_bytes(b"".join(protect.without_directives(clear, (b"comment",)) + b"\n" + body + b"\n"
                                  for clear, body in zip(source.clear[:-1], adjacent, strict=True)) + source.clear[-1])
    emitted = protect.split(first + second, protect.OUTPUT_BEGIN, protect.OUTPUT_END).bodies
    return {
        "each_model_opens_alone": tuple(open_models(openssl, envelope, keys)[0] for envelope in envelopes) == clear_models,
        "adjacent_models_match": adjacent == clear_models,
        "reordered_models_match": open_models(openssl, second + first, keys) == clear_models[::-1],
        "missing_local_cipher_does_not_inherit": missing_rejected,
        "distinct_owners_methods_and_encodings": len(keys) == 2
            and len({header[b"key_keyowner"] for header in headers}) == 2
            and len({header[b"key_keyname"] for header in headers}) == 1
            and len({header[b"data_method"] for header in headers}) == 2
            and len({header[b"enctype"] for header in headers}) == 2,
        "expected_comment_sources": tuple(map(comment_values, comments)) == EXPECTED_COMMENTS,
        "comments_immediately_before_matching_data": tuple(map(comments_before_data, emitted)) == comments,
        "comment_lines_preserved_and_only_emitted_once": tuple(map(comment_lines, emitted)) == comments,
        "comments_excluded_from_ciphertext": all(not comment_lines(body) for body in adjacent)
            and all(value not in body for body in adjacent for model in EXPECTED_COMMENTS for value in model),
        "recovered_hdl_matches": run_icarus.run(restored, iverilog)[0],
    }


def native_envelope_slices(wire: bytes) -> tuple[bytes, ...]:
    envelopes = []
    cursor = 0
    for closing in protect.OUTPUT_END.finditer(wire):
        opening = (protect.OUTPUT_BEGIN.search(wire, cursor, closing.start())
                   or protect.FALLBACK_BEGIN.search(wire, cursor, closing.start()))
        if opening is None:
            raise ValueError("unpaired native envelope")
        envelopes.append(wire[opening.start():closing.end()] + b"\n")
        cursor = closing.end()
    return tuple(envelopes)


def native_observation(python: str, openssl: str, fixture: Path, work: Path) -> dict:
    private, public = protect.exchange_key(openssl, work, "cli")
    output = work / "native.sv"
    output.unlink(missing_ok=True)
    try:
        wire = protect.encrypt(python, fixture, public, output, (b"Qualification", b"fixture-only"))
        layout, recovered = boundaries.recovered_ranges(openssl, private, wire)
        envelopes = native_envelope_slices(wire)
        isolated = tuple(boundaries.recovered_ranges(openssl, private, envelope)[1][0] for envelope in envelopes)
        reordered = boundaries.recovered_ranges(openssl, private, b"".join(envelopes[::-1]))[1]
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired):
        return {"outcome": "missing_or_unreadable_output"}
    return {
        "outcome": "recovered",
        "recovered_models": len(recovered),
        "explicit_opening_delimiters": list(layout.opened),
        "each_model_recovers_in_isolation": isolated == recovered,
        "reordered_models_recover": reordered == recovered[::-1],
        "envelope_comments": [[value.decode() for value in comment_values(comment_lines(envelope))]
                              for envelope in layout.bodies],
        "comments_in_clear_surroundings": [value.decode() for clear in layout.clear
                                           for value in comment_values(comment_lines(clear))],
        "comment_values_in_recovered_bodies": [value.decode() for body in recovered
                                               for value in comment_values(comment_lines(body))],
        "include_left_in_recovered_body": any(b'`include "notice.svh"' in body for body in recovered),
    }


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
    fixture = suite_results.ROOT / "tests" / (CASE + ".sv")
    inputs = suite_results.input_digest(fixture)
    checker, encryptor = checker_digest(), protect.tool_info(python)
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        expanded_path = work / "expanded.sv"
        expanded = preprocess(args.iverilog_bin, fixture, expanded_path)
        checks = reference_checks(openssl, args.iverilog_bin, fixture, expanded, work)
        native = {name: native_observation(python, openssl, path, work)
                  for name, path in (("source_with_include", fixture), ("preprocessed_source", expanded_path))}
    if (checker != checker_digest() or inputs != suite_results.input_digest(fixture)
            or encryptor != protect.tool_info(python)):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    passed = all(checks.values())
    record = {"profile": PROFILE, "checker_sha256": checker, "encryptor": encryptor,
              "openssl": suite_results.tool_version([openssl, "version"]),
              "icarus": suite_results.tool_version([str(args.iverilog_bin / "iverilog"), "-V"]),
              "tests": {CASE: {"inputs_sha256": inputs, "reference_controls": checks, "native": native, "pass": passed}}}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: {sum(checks.values())}/{len(checks)} reference controls match, native {native}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

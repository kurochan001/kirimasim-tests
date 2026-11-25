#!/usr/bin/env python3
"""Test nested protected replacement, macro expansion, and sibling boundaries."""

import argparse
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import tempfile

import run_ghost
import run_icarus
import run_protect_author_digests as author
import run_protect_block_boundaries as boundaries
import run_protect_cipher_methods as cipher
import run_protect_digests as digests
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-nested-decryption"
CHECKER = "tools/run_protect_nested_decryption.py"
DEPTH = "ch34/test_protect_decrypts_eight_layers_before_expanding_macros"
SIBLING = "ch34/test_protect_replaces_nested_macros_before_next_envelope"
CASES = {DEPTH: "nested macro value=47", SIBLING: "nested sibling values=33,50"}
LEAF_START = b"// Nested payload starts\n"
LEAF_END = b"// Nested payload ends\n"
TAIL = b"// Outer tail stays protected"


@dataclass(frozen=True)
class Header:
    owner: bytes
    name: bytes
    key_method: bytes
    data_method: bytes
    encoding: bytes


@dataclass(frozen=True)
class Exchange:
    method: bytes
    key: bytes


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(author.checker_digest().encode())
    digest.update(suite_results.runner_digest("ghost").encode())
    return digest.hexdigest()


def input_header(text: bytes) -> Header:
    fields = protect.fields(text)
    return Header(*(fields[name] for name in
                    (b"key_keyowner", b"key_keyname", b"key_method", b"data_method", b"enctype")))


def put_envelope(openssl: str, header: Header, text: bytes, keys: dict) -> bytes:
    identity = (header.owner, header.name)
    if identity in keys:
        raise ValueError("duplicate exchange key identity in test")
    key = Exchange(header.key_method, secrets.token_bytes(protect.CIPHERS[header.key_method][1]))
    keys[identity] = key
    session = secrets.token_bytes(protect.CIPHERS[header.data_method][1])
    private_metadata = (author.method_line(b"data_method", header.data_method)
                        + digests.encoded_block(author.DATA_KEY, session, header.encoding))
    wrapped = boundaries.seal(openssl, key.method, key.key, private_metadata)
    data = boundaries.seal(openssl, header.data_method, session, text)
    return (author.PRAGMA + b"begin_protected\n"
            + author.method_line(b"key_keyowner", header.owner)
            + author.method_line(b"key_keyname", header.name)
            + author.method_line(b"key_method", header.key_method)
            + digests.encoded_block(b"key_block", wrapped, header.encoding)
            + digests.encoded_block(b"data_block", data, header.encoding)
            + author.PRAGMA + b"end_protected")


def open_envelope(openssl: str, envelope: bytes, keys: dict) -> tuple[Header, bytes]:
    metadata = protect.fields(envelope)
    identity = (metadata.get(b"key_keyowner"), metadata.get(b"key_keyname"))
    exchange = keys.get(identity)
    if exchange is None or exchange.method != metadata.get(b"key_method"):
        raise ValueError("no registered exchange key for this envelope")
    key_block = author.payload(envelope, b"key_block")
    data_block = author.payload(envelope, b"data_block")
    clear_key = protect.decrypt_body(openssl, exchange.method, exchange.key, key_block.decoded)
    method, session = boundaries.text_key(clear_key)
    header = Header(*identity, exchange.method, method, data_block.encoding[b"enctype"])
    return header, protect.decrypt_body(openssl, method, session, data_block.decoded)


def replace_envelopes(openssl: str, source: bytes, keys: dict, trace: list,
                      depth: int = 1) -> bytes:
    layout = protect.split(source, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
    parts = []
    for clear, envelope in zip(layout.clear, layout.bodies):
        header, body = open_envelope(openssl, envelope, keys)
        trace.append(("open", depth, header))
        parts.append(clear + b"\n" + replace_envelopes(openssl, body, keys, trace, depth + 1) + b"\n")
        trace.append(("close", depth, header))
    return b"".join(parts) + layout.clear[-1]


def replace_outer(layout: protect.Layout, parts: tuple[bytes, ...]) -> bytes:
    if len(parts) != len(layout.bodies):
        raise ValueError("replacement count does not match the fixture")
    return b"".join(clear + part for clear, part in zip(layout.clear, parts)) + layout.clear[-1]


def with_original_boundaries(layout: protect.Layout, parts: tuple[bytes, ...]) -> bytes:
    return replace_outer(layout, tuple(author.PRAGMA + b"begin\n" + part + b"\n" + author.PRAGMA + b"end"
                                       for part in parts))


def assemble(openssl: str, layout: protect.Layout, levels: int) -> tuple:
    outer = tuple(input_header(clear) for clear in layout.clear[:-1])
    first, *siblings = (body.strip(b"\r\n") for body in layout.bodies)
    prefix, marked = first.split(LEAF_START)
    leaf, suffix = marked.split(LEAF_END)
    keys = {}
    child_headers = tuple(
        Header(f"Nested layer {depth}".encode(), b"assembly", b"aes128-cbc",
               b"aes128-cbc" if depth % 2 == 0 else b"aes256-cbc",
               b"uuencode" if depth % 2 == 0 else b"base64")
        for depth in range(2, levels + 1)
    )
    child = leaf
    for header in reversed(child_headers):
        child = put_envelope(openssl, header, child, keys)
    author_inputs = (prefix + child + b"\n" + suffix, *siblings)
    sealed = tuple(put_envelope(openssl, header, body, keys) for header, body in zip(outer, author_inputs))
    return outer, child_headers, child, keys, author_inputs, sealed


def fixture_run(path: Path, file: str, source: bytes, icarus_bin: Path) -> bool:
    fixture = path / file
    fixture.write_bytes(source)
    return run_icarus.run(fixture, icarus_bin)[0]


def starts_after_existing_block(openssl: str, child: bytes, after: bytes, body: bytes,
                                header: Header, keys: dict) -> bool:
    original = child + after
    existing = protect.split(original, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
    selection = input_header(existing.clear[-1])
    exchange = keys.copy()
    exchange.pop((selection.owner, selection.name))
    next_envelope = put_envelope(openssl, selection, body, exchange)
    output = original + next_envelope
    emitted = protect.split(output, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
    first, second = emitted.bodies
    return (output.startswith(original)
            and first == existing.bodies[0]
            and open_envelope(openssl, second, exchange) == (header, body))


def trace_details(trace: list) -> list[dict]:
    return [{"event": event, "depth": depth, **{key: value.decode() for key, value in vars(header).items()}}
            for event, depth, header in trace]


def reference_controls(openssl: str, fixture: Path, work: Path, icarus_bin: Path,
                       case: str) -> tuple[dict, bytes, bytes]:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    levels = 8 if case == DEPTH else 3
    outer, child_headers, child, keys, author_inputs, sealed = assemble(openssl, layout, levels)
    packaged = replace_outer(layout, sealed)
    emitted = protect.split(packaged, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
    recorded = tuple(open_envelope(openssl, wire, keys) for wire in emitted.bodies)
    trace = []
    restored = replace_envelopes(openssl, packaged, keys, trace)
    chain = list(enumerate((outer[0], *child_headers), start=1))
    expected_trace = ([("open", depth, header) for depth, header in chain]
                      + [("close", depth, header) for depth, header in reversed(chain)])
    for sibling in outer[1:]:
        expected_trace.extend((("open", 1, sibling), ("close", 1, sibling)))
    deepest = child_headers[-1]
    identity = (deepest.owner, deepest.name)
    exchange = keys[identity]
    wrong_keys = {**keys, identity: Exchange(exchange.method, bytes([exchange.key[0] ^ 1]) + exchange.key[1:])}
    broken_close = protect.OUTPUT_END.sub(b"", packaged, count=1)
    macro_guard = b"PROTECT_DEPTH_OFFSET" if case == DEPTH else b"PROTECT_CHAIN_STEP"
    missing_macro = re.sub(rb"(?m)^`define " + macro_guard + rb"[^\r\n]*\n", b"", restored, count=1)
    checks = {
        "outside_bytes_unchanged_by_encryption": emitted.clear == layout.clear,
        "outer_header_selects_key_method_data_method_and_encoding": tuple(header for header, _ in recorded) == outer,
        "outer_bytes_recovered_without_interpreting_inner_pragmas": tuple(body for _, body in recorded) == author_inputs,
        "complete_inner_envelope_in_outer_data": child in recorded[0][1]
                                                and child.startswith(author.PRAGMA + b"begin_protected")
                                                and child.endswith(author.PRAGMA + b"end_protected"),
        "outer_tail_remains_protected": TAIL not in packaged and TAIL in recorded[0][1],
        "proper_open_and_close_order": trace == expected_trace,
        "restored_macros_match_hdl_output": fixture_run(work, fixture.name, restored, icarus_bin),
        "raw_ciphertext_does_not_produce_expected_compilation": not fixture_run(work, fixture.name, packaged, icarus_bin),
        "removing_recovered_macro_changes_result": missing_macro != restored and
                                                  not fixture_run(work, fixture.name, missing_macro, icarus_bin),
        "wrong_deep_key_stops_replacement": author.rejected(lambda: replace_envelopes(openssl, packaged, wrong_keys, [])),
        "missing_close_stops_replacement": author.rejected(lambda: replace_envelopes(openssl, broken_close, keys, [])),
    }
    if case == SIBLING:
        latest = outer[-1]
        carried = sealed[-1].replace(
            author.method_line(b"key_keyowner", latest.owner),
            author.method_line(b"key_keyowner", outer[0].owner), 1,
        )
        changed = replace_outer(layout, (*sealed[:-1], carried))
        checks["closed_envelope_owner_cannot_open_next_sibling"] = author.rejected(
            lambda: replace_envelopes(openssl, changed, keys, []))
        checks["next_sibling_uses_new_method_and_encoding"] = (
            outer[0].data_method != latest.data_method and outer[0].encoding != latest.encoding
            and trace[-2:] == [("open", 1, latest), ("close", 1, latest)]
        )
        checks["begins_new_encryption_after_preserving_previous_block"] = starts_after_existing_block(
            openssl, child, layout.clear[1], author_inputs[-1], latest, keys)
    return {"checks": checks, "trace": trace_details(trace)}, with_original_boundaries(layout, author_inputs), packaged


def native_encrypt(python: str, openssl: str, work: Path, cli_key: tuple[Path, Path], source: bytes) -> dict:
    private, public = cli_key
    variant, output = work / "native.sv", work / "native.protected.sv"
    variant.write_bytes(source)
    output.unlink(missing_ok=True)
    try:
        process = cipher.run_encryptor(python, variant, public, output)
        if process.returncode != 0 or not output.is_file():
            return {"outcome": "rejected_or_no_output", "exit": process.returncode}
        wire = output.read_bytes()
    except subprocess.TimeoutExpired:
        return {"outcome": "timeout"}
    original = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    exposed = TAIL in wire
    try:
        layout, opened = boundaries.recovered_ranges(openssl, private, wire)
    except (ValueError, KeyError):
        return {"outcome": "invalid_output_layout", "outer_tail_exposed": exposed}
    body_match = len(opened) == len(original.bodies) and all(
        protect.keeps_body(body, actual) for body, actual in zip(original.bodies, opened))
    return {
        "outcome": "all_bodies_recovered" if body_match else "incomplete_body_recovery",
        "output_ranges": len(layout.bodies), "outer_tail_exposed": exposed,
    }


def native_ghost(ghost: str, profile: dict, fixture: Path, work: Path, packaged: bytes) -> dict:
    path = work / fixture.name
    path.write_bytes(packaged)
    try:
        result = subprocess.run(
            [ghost, *profile["arguments"], "-top", suite_results.top_module(fixture), str(path)],
            cwd=work, env={**os.environ, **profile["environment"]},
            capture_output=True, text=True, errors="replace", timeout=90,
        )
    except (OSError, subprocess.TimeoutExpired):
        return {"outcome": "could_not_run_or_timed_out"}
    output = run_ghost.normalize(result.stdout, profile)
    diagnostic = run_ghost.ANSI.sub("", result.stdout + result.stderr)
    unsupported = any(re.search(r"protected|pragma protect", line, re.I)
                      and re.search(r"not supported|unsupported", line, re.I) for line in diagnostic.splitlines())
    matches = output == suite_results.expected_output(fixture)
    return {
        "outcome": "protected_envelope_unsupported" if unsupported
                   else "pass" if result.returncode == 0 and matches else "output_differs",
        "exit": result.returncode, "matches_expected_hdl": matches,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--ghost-profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, openssl, ghost = (shutil.which(name) for name in (args.python, args.openssl, args.ghost))
    if python is None or openssl is None or ghost is None or not (args.iverilog_bin / "iverilog").is_file():
        parser.error("Python, OpenSSL, Ghost or Icarus is unavailable")
    ghost = str(Path(ghost).resolve())
    profile_bytes = args.ghost_profile.read_bytes()
    ghost_hash = hashlib.sha256(Path(ghost).read_bytes()).hexdigest()
    profile = json.loads(profile_bytes)
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    fingerprints = suite_results.fingerprints(list(fixtures.values()))
    checker, tool = checker_digest(), protect.tool_info(python)
    tests = {}
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        cli_key = protect.exchange_key(openssl, work, "cli")
        for case, fixture in fixtures.items():
            reference, prepared, packaged = reference_controls(openssl, fixture, work, args.iverilog_bin, case)
            tests[case] = {
                "inputs_sha256": fingerprints[case], "reference": reference,
                "ordinary_cli": native_encrypt(python, openssl, work, cli_key, fixture.read_bytes()),
                "with_preexisting_envelope": native_encrypt(python, openssl, work, cli_key, prepared),
                "ghost_encrypted": native_ghost(ghost, profile, fixture, work, packaged),
            }
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)
            or profile_bytes != args.ghost_profile.read_bytes()
            or ghost_hash != hashlib.sha256(Path(ghost).read_bytes()).hexdigest()):
        parser.exit(2, "Tool, checker or input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
        "openssl": protect.invoke([openssl, "version"]).decode().strip(),
        "icarus": protect.invoke([str(args.iverilog_bin / "iverilog"), "-V"]).decode().splitlines()[0],
        "ghost": {"binary_sha256": ghost_hash, "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()},
        "tests": tests,
    })
    failed = False
    for case, row in tests.items():
        controls = row["reference"]["checks"]
        print(f"{case}: {sum(controls.values())}/{len(controls)} reference controls match")
        for phase in ("ordinary_cli", "with_preexisting_envelope", "ghost_encrypted"):
            print(f"  {phase}: {row[phase]['outcome']}")
        failed |= (not all(controls.values())
                   or row["ordinary_cli"]["outcome"] != "all_bodies_recovered"
                   or row["with_preexisting_envelope"]["outcome"] != "all_bodies_recovered"
                   or row["ghost_encrypted"]["outcome"] != "pass")
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())

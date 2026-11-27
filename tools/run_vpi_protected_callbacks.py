#!/usr/bin/env python3
"""Qualify statement callback registration on recovered HDL source ranges."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import run_protect_block_boundaries as boundaries
import run_protect_encryption as encryptor
import run_vpi_protected_access as access
import suite_results


CHECKER = "tools/run_vpi_protected_callbacks.py"
PROFILE = "vpi-protected-callbacks-reference"
CASE = "ch38/test_vpi_protected_statement_callbacks"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
DIAGNOSTIC_ANCHOR = "direct_denial_with_diagnostic"
DIAGNOSTIC_REQUIREMENTS = {"SV2023-38.36.1.1-EXTRACT-PROTECTED-STATEMENT-CALLBACK"}


def checker_digest() -> str:
    return hashlib.sha256((access.digest(suite_results.ROOT / CHECKER) + access.checker_digest()).encode()).hexdigest()


def alternate_layout(source: bytes) -> bytes:
    plain = access.PRAGMA_LINES.sub(b"", source)
    opening, closing = b"    // left begin\n", b"    // left end\n"
    if plain.count(opening) != 1 or plain.count(closing) != 1:
        raise ValueError("left protection markers missing or ambiguous")
    return plain.replace(opening, opening + b"`pragma protect begin\n").replace(
        closing, b"`pragma protect end\n" + closing)


def recover(paths: dict, source: bytes, work: Path) -> tuple[Path, int, int]:
    staged = work / "input.sv"
    staged.write_bytes(source)
    openssl = str(paths["openssl"])
    private, public = encryptor.exchange_key(openssl, work, "callbacks")
    wire = encryptor.encrypt(str(paths["python"]), staged, public, work / "encrypted.sv",
                             (b"Qualification", b"callbacks"))
    _, (body,) = boundaries.recovered_ranges(openssl, private, wire)
    opening, = encryptor.SOURCE_BEGIN.finditer(source)
    closing, = encryptor.SOURCE_END.finditer(source)
    original = source[opening.end():closing.start()]
    if body.strip() != original.strip():
        raise ValueError("the recovered statement payload differs")
    # The encryptor trims framing whitespace. Preserve the original source lines.
    first = len(original) - len(original.lstrip())
    last = len(original.rstrip())
    restored = work / "restored.sv"
    restored.write_bytes(source[:opening.end()] + original[:first] + body.strip() + original[last:] + source[closing.start():])
    return restored, source.count(b"\n", 0, opening.start()) + 1, source.count(b"\n", 0, closing.start()) + 1


def build_probe(paths: dict, fixture: Path, work: Path, reference: bool) -> Path:
    library = work / ("reference.so" if reference else "native.so")
    probe = fixture.parent / "vpi_protected_callbacks" / "probe.c"
    flags = ["-DREFERENCE_CALLBACKS"] if reference else []
    linking = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    build = access.observe([paths["cc"], "-std=c11", "-Wall", "-Wextra", "-Werror", "-shared", "-fPIC",
                            *linking, "-I", paths["vpi_user.h"].parent, "-I", work, *flags, probe, "-o", library], work)
    if build.returncode:
        raise ValueError(f"probe compilation exited {build.returncode}: {build.stderr.strip()}")
    return library


def statement_lines(slang: Path, top: str, source: Path, work: Path) -> dict:
    build = access.observe([slang, "--std=1800-2023", "--top", top, "--ast-json", "design.json",
                            "--ast-json-source-info", source], work)
    if build.returncode:
        raise ValueError(f"Slang elaboration exited {build.returncode}: {build.stderr.strip()}")
    design = json.loads((work / "design.json").read_text(encoding="utf-8"))["design"]
    block, = (node for node in access.documents(design)
              if node.get("kind") == "Block" and node.get("block", "").endswith(" actions"))
    left, right, tail_delay, tail_write = block["body"]["list"]
    nodes = {"outer": block}
    for label, branch in (("left", left), ("right", right)):
        if branch["kind"] != "Block" or not branch["block"].endswith(f" {label}_actions"):
            raise ValueError(f"unexpected {label} branch in the Slang statement tree")
        nodes[f"{label}-block"] = branch
        nodes[f"{label}-delay"], nodes[f"{label}-write"] = branch["body"]["list"]
    nodes.update({"tail-delay": tail_delay, "tail-write": tail_write})
    for name, item in nodes.items():
        suffix = name.rsplit("-", 1)[-1]
        kind = {"delay": "Timed", "write": "ExpressionStatement"}.get(suffix, "Block")
        if item["kind"] != kind or (work / item["source_file_start"]).resolve() != source.resolve():
            raise ValueError(f"unexpected source position or kind for {name}")
    return {name: (node["source_line_start"], node["source_line_end"]) for name, node in nodes.items()}


def qualify(paths: dict, profile: dict, fixture: Path, work: Path) -> dict:
    top = suite_results.top_module(fixture) or fixture.stem
    native_lib = build_probe(paths, fixture, work, reference=False)
    native_expected = suite_results.expected_output(fixture).splitlines()
    original = fixture.read_bytes()
    sources = {"right": original, "left": alternate_layout(original)}
    cases, checks = {}, {}
    for selected, source in sources.items():
        directory = work / selected
        directory.mkdir()
        restored, begin, end = recover(paths, source, directory)
        positions = statement_lines(paths["slang"], top, restored, directory)
        (directory / "envelope_range.h").write_text(
            f"enum {{ envelope_begin = {begin}, envelope_end = {end} }};\n", encoding="utf-8")
        reference_lib = build_probe(paths, fixture, directory, reference=True)
        native = access.simulate(paths["ghost"], profile, restored, native_lib, top, directory)
        reference = access.simulate(paths["ghost"], profile, restored, reference_lib, top, directory)
        output = (fixture.parent / "vpi_protected_callbacks" / f"{selected}.expected").read_text(
            encoding="utf-8").splitlines()
        diagnostic = f"vpi_register_cb: cbStmt on protected statement ({selected}-block)"
        locations = (positions[name][0] for name in ("outer", "left-block", "right-block"))
        block_lines = "block lines outer=%d left=%d right=%d" % tuple(locations)
        blocked = {name for name, (first, last) in positions.items() if begin < first <= last < end}
        cases[selected] = {"range": [begin, end], "statement_lines": positions,
                           "native_restored": native, "reference": reference}
        checks[f"{selected}_recovered_origins_agree_with_backing_handles"] = (
            restored.read_bytes() == source
            and blocked == {f"{selected}-{kind}" for kind in ("block", "delay", "write")}
            and native["output"][:1] == reference["output"][:1] == [block_lines])
        checks[f"{selected}_{DIAGNOSTIC_ANCHOR}"] = (
            reference["diagnostics"] == [diagnostic]
            and f"direct registration {selected}-block=0" in reference["output"])
        checks[f"{selected}_excludes_protected_placements_and_delivers_other_callbacks"] = (
            reference["exit"] == 0 and reference["output"] == output)
        checks[f"{selected}_native_restored_observation_matches_public_control"] = (
            native["exit"] == 0 and not native["diagnostics"] and native["output"] == [block_lines, *native_expected[1:]])
    checks["layout_swap_moves_only_the_protection_range"] = (
        access.PRAGMA_LINES.sub(b"", sources["right"]) == access.PRAGMA_LINES.sub(b"", sources["left"])
        and cases["right"]["reference"]["output"][1:] != cases["left"]["reference"]["output"][1:])
    return {"layouts": cases, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--python", required=True, help="Python environment containing hdl-encrypt")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    paths = {}
    for name in ("ghost", "slang", "python", "openssl", "cc"):
        executable = shutil.which(os.environ.get("CC", "cc") if name == "cc" else getattr(args, name))
        if executable is None:
            parser.error(f"missing tool: {name}")
        paths[name] = Path(executable).absolute()
    paths.update({"profile": args.profile, "vpi_user.h": args.include.resolve() / "vpi_user.h",
                  "vpi_compatibility.h": args.include.resolve() / "vpi_compatibility.h"})
    if not all(path.is_file() for path in paths.values()):
        parser.error("the VPI headers and Ghost profile are required")
    profile = json.loads(args.profile.read_bytes())
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("Ghost must use the strict LRM mode")
    fixture = CASES[CASE]
    checker, inputs = checker_digest(), suite_results.input_digest(fixture)
    hashes = {name: access.digest(path) for name, path in paths.items()}
    try:
        package = encryptor.tool_info(str(paths["python"]))
        with tempfile.TemporaryDirectory() as directory:
            result = qualify(paths, profile, fixture, Path(directory).resolve())
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"protected callback qualification stopped: {error}\n")
    if (hashes != {name: access.digest(path) for name, path in paths.items()} or checker != checker_digest()
            or package != encryptor.tool_info(str(paths["python"])) or inputs != suite_results.input_digest(fixture)):
        parser.exit(2, "qualification inputs changed during the run\n")
    versions = {name: suite_results.tool_version([paths[name], option])
                for name, option in (("ghost", "--version"), ("slang", "--version"),
                                     ("cc", "--version"), ("openssl", "version"))}
    args.json.write_text(json.dumps({"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                                     "versions": versions, "encryptor": package,
                                     "tests": {CASE: {"inputs_sha256": inputs, **result}}}, indent=2) + "\n")
    for name, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {name}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

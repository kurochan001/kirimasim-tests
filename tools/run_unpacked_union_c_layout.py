#!/usr/bin/env python3
"""Compare a Verilator-generated unpacked union with an independently compiled C layout."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_verilator
import suite_results


CHECKER = "tools/run_unpacked_union_c_layout.py"
PROFILE = "verilator-unpacked-union-c-layout"
CASE = "ch7/test_unpacked_union_c_member_order"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
FIELDS = (
    "union.size", "union.alignment", "union.left", "union.right",
    "left.size", "left.alignment", "left.marker", "left.codepoint", "left.ratio",
    "right.size", "right.alignment", "right.marker", "right.codepoint", "right.mode", "right.score",
)
MEMBERS = re.compile(r"^( +[^\n]+ __PVT__marker;\n)( +[^\n]+ __PVT__codepoint;\n)", re.M)
SEEDS = (1, 73)


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def compile_checked(command: list[str], work: Path, timeout: int = 30) -> None:
    result = run_verilator.execute(command, timeout, cwd=str(work))
    if result.returncode:
        raise ValueError(f"{Path(command[0]).name} exited {result.returncode}: {result.stderr.strip()}")


def structured_layout(line: str, name: str) -> dict[str, int]:
    label, *numbers = line.split()
    if label != name or len(numbers) != len(FIELDS):
        raise ValueError("missing or malformed C layout measurement")
    return dict(zip(FIELDS, map(int, numbers), strict=True))


def measure(cxx: str, include: Path, work: Path, generated: Path, helpers: Path, c_object: Path) -> dict:
    binary = work / ("abi-" + generated.name)
    compile_checked([cxx, "-std=c++20", "-I", str(generated), "-isystem", str(include),
                     str(helpers / "compare.cpp"), str(c_object), "-o", str(binary)], work)
    run = run_verilator.execute([str(binary)], 30, cwd=str(work))
    lines = run.stdout.splitlines()
    if len(lines) < 3:
        raise ValueError("union probe did not produce both layouts and a comparison")
    return {
        "exit": run.returncode, "c": structured_layout(lines[0], "c"),
        "generated": structured_layout(lines[1], "generated"), "observations": lines[2:],
    }


def qualify(verilator: str, cc: str, cxx: str, include: Path, source: Path, work: Path) -> dict:
    helpers = source.parent / "union_c_layout"
    generated = work / "generated"
    compile_checked([verilator, "--cc", "--timing", "--public-flat-rw", "-Wno-fatal",
                     "--top-module", source.stem, "--prefix", "Vlayout", "--Mdir", str(generated), str(source)],
                    work, run_verilator.BUILD_TIMEOUT)
    c_object = work / "layout.o"
    compile_checked([cc, "-std=c11", "-Wall", "-Wextra", "-Werror", "-c", str(helpers / "layout.c"),
                     "-o", str(c_object)], work)
    baseline = measure(cxx, include, work, generated, helpers, c_object)
    header = generated / "Vlayout___024root.h"
    original = header.read_text(encoding="utf-8")
    matches = list(MEMBERS.finditer(original))
    if len(matches) != 2:
        raise ValueError("could not isolate the common fields of both generated structs")
    changed = work / "reordered"
    changed.mkdir()
    pair = matches[0]
    mutated = original[:pair.start()] + pair[2] + pair[1] + original[pair.end():]
    (changed / header.name).write_text(mutated, encoding="utf-8")
    reordered = measure(cxx, include, work, changed, helpers, c_object)
    layout = baseline["generated"]
    bad = reordered["generated"]

    prefix = run_verilator.install_prefix(verilator)
    ordinary = {}
    for seed in SEEDS:
        matches_output, reason = run_verilator.run(source, verilator, seed, prefix)
        ordinary[seed] = {"pass": matches_output, "reason": reason}

    checks = {
        "matches_independent_c_layout": baseline["exit"] == 0 and baseline["c"] == layout
        and baseline["observations"][0] == "layout=1 ascending=1",
        "both_members_share_offset_zero": layout["union.left"] == layout["union.right"] == 0,
        "union_can_store_differently_sized_structures": layout["left.size"] < layout["right.size"]
        and layout["right.size"] == layout["union.size"],
        "values_pass_between_generated_and_c_types": baseline["observations"][1:] == ["c_reads=1 cpp_reads=1"],
        "reordered_fields_detected_before_transfer": reordered["exit"] == 3
        and reordered["c"] == baseline["c"]
        and bad["left.codepoint"] == 0 < bad["left.marker"] < bad["left.ratio"]
        and reordered["observations"] == ["layout=0 ascending=0"],
        "ordinary_common_initial_sequence": all(trial["pass"] for trial in ordinary.values()),
    }
    return {"baseline": baseline, "reordered": reordered, "ordinary": ordinary,
            "generated_header_sha256": digest(header), "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    commands = {
        "verilator": shutil.which(args.verilator), "cc": shutil.which(os.environ.get("CC", "cc")),
        "cxx": shutil.which(os.environ.get("CXX", "c++")),
    }
    if not all(commands.values()):
        parser.error("Verilator and C and C++ compilers are required")
    commands = {key: str(Path(value).absolute()) for key, value in commands.items()}
    root = subprocess.check_output([commands["verilator"], "--getenv", "VERILATOR_ROOT"],
                                   text=True, timeout=30).strip()
    include = Path(root).resolve() / "include"
    artifacts = {name: Path(path) for name, path in commands.items()}
    for name in ("verilated.h", "verilated_types.h"):
        artifacts[name] = include / name
    backend = Path(os.environ.get("VERILATOR_BIN", artifacts["verilator"].resolve().with_name("verilator_bin")))
    if backend.is_file():
        artifacts["verilator_backend"] = backend
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("Verilator's public C++ runtime headers are unavailable")
    hashes = {key: digest(path) for key, path in artifacts.items()}
    source = CASES[CASE]
    inputs = suite_results.fingerprints([source])
    checker, runner = checker_digest(), suite_results.runner_digest("verilator")
    versions = {name: suite_results.tool_version([path, "--version"]) for name, path in commands.items()}
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = qualify(commands["verilator"], commands["cc"], commands["cxx"],
                             include, source, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Unpacked union qualification stopped: {error}\n")
    if (hashes != {key: digest(path) for key, path in artifacts.items()}
            or checker != checker_digest() or runner != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints([source])):
        parser.exit(2, "Qualification inputs changed during the run.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "seeds": list(SEEDS)}
    verdict = ("pass", "") if result["pass"] else ("fail", "C layout, transfer, or reordered control differed")
    suite_results.write(args.json, "verilator", "Verilator", versions["verilator"],
                        {CASE: verdict}, inputs=inputs, runner_sha256=runner, configuration=configuration)
    args.observations.write_text(json.dumps({
        "versions": versions, "configuration": configuration,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **result}},
    }, indent=2) + "\n", encoding="utf-8")
    for check, passed in result["checks"].items():
        print(f"{check}: {'PASS' if passed else 'FAIL'}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

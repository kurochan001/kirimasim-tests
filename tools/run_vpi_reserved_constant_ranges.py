#!/usr/bin/env python3
"""Check the allocated and future-use constant ranges in IEEE 1800-2023 Annex M."""

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


PROFILE = "vpi-reserved-constant-ranges"
CHECKER = "tools/run_vpi_reserved_constant_ranges.py"
CASE = "ch36/test_vpi_extension_reserved_constant_ranges"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
COVERAGE_CONSTANTS = Path("tests/ch36/test_sv_vpi_user_h_coverage_constants.expected")
LANGUAGES = {"c": ("CC", "cc", "c11"), "c++": ("CXX", "c++", "c++17")}
PUBLIC_MACRO = re.compile(r"^#define ((?:vpi|cb)[A-Z]\w*)[ \t]+.+$", re.M)
FUTURE_CONTROLS = ("-DvpiFirstFuture=(0x300+32)", "-DcbLastFuture=(900-1)",
                   "-DvpiBeforeFuture=799", "-DvpiAfterFuture=900")
EXPECTED_FUTURE_CONTROLS = {"cbLastFuture": 899, "vpiFirstFuture": 800}
INCLUDE = '#include "sv_vpi_user.h"\n'


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    inputs = (Path(CHECKER), COVERAGE_CONSTANTS)
    return hashlib.sha256(b"".join((suite_results.ROOT / path).read_bytes() for path in inputs)).hexdigest()


def read_allocations(command: list[str], directory: Path, flags: tuple[str, ...] = ()) -> dict:
    macros = subprocess.run([*command, *flags, "-E", "-dM", "-"], input=INCLUDE,
                            capture_output=True, text=True, timeout=30, cwd=directory)
    if macros.returncode != 0:
        return {"preprocess_exit": macros.returncode}

    names = sorted(set(PUBLIC_MACRO.findall(macros.stdout)))
    observations = {"preprocess_exit": 0, "public_object_macros": len(names)}
    # Let the C or C++ compiler resolve aliases and integral expressions.
    # Match the public object-like macro namespace of the two headers.
    harness = ['#include <stdio.h>', INCLUDE, 'int main(void) {']
    for name in names:
        harness.append(f'{{ enum {{ value = {name} }}; printf("{name} %d\\n", (int)value); }}')
    harness += ['return 0;', '}']
    program = directory / "constant_ranges"
    compile_result = subprocess.run([*command, *flags, "-o", str(program), "-"], input="\n".join(harness),
                                    capture_output=True, text=True, timeout=30, cwd=directory)
    observations["compile_exit"] = compile_result.returncode
    if compile_result.returncode != 0:
        return observations
    run = subprocess.run([str(program)], capture_output=True, text=True, timeout=30, cwd=directory)
    observations["run_exit"] = run.returncode
    if run.returncode != 0 or run.stderr:
        return observations
    values = {name: int(raw) for name, raw in map(str.split, run.stdout.splitlines())}
    if sorted(values) != names:
        return observations
    return {**observations,
            "coverage": {name: val for name, val in values.items() if 750 <= val <= 779},
            "future_use": {name: val for name, val in values.items() if 800 <= val <= 899}}


def observe(include: Path, drivers: dict[str, str], directory: Path) -> dict:
    expected = (suite_results.ROOT / COVERAGE_CONSTANTS).read_text(encoding="utf-8")
    coverage = {name: int(value) for name, value in map(str.split, expected.splitlines())}
    observations = {}
    for lang, (_, _, standard) in LANGUAGES.items():
        command = [drivers[lang], "-x", lang, f"-std={standard}", "-I", str(include)]
        baseline = read_allocations(command, directory)
        seeded = read_allocations(command, directory, FUTURE_CONTROLS)
        passed = (baseline.get("coverage") == coverage and baseline.get("future_use") == {}
                  and seeded.get("coverage") == coverage and seeded.get("future_use") == EXPECTED_FUTURE_CONTROLS)
        observations[lang] = {"pass": passed, "baseline": baseline, "boundary_controls": seeded}
    return observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--comparison-include", type=Path, help="optional second directory with public headers")
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    verilator = shutil.which(args.verilator)
    drivers = {lang: shutil.which(os.environ.get(variable, default))
               for lang, (variable, default, _) in LANGUAGES.items()}
    if not verilator or not all(drivers.values()):
        parser.error("Verilator and both C and C++ compilers are required")
    root = subprocess.check_output([verilator, "--getenv", "VERILATOR_ROOT"], text=True, timeout=30).strip()
    includes = {"verilator": Path(root) / "include" / "vltstd"}
    if args.comparison_include:
        includes["comparison"] = args.comparison_include.resolve()
    artifacts = {"verilator": Path(verilator), **{lang: Path(path) for lang, path in drivers.items()}}
    for label, directory in includes.items():
        for name in ("vpi_user.h", "sv_vpi_user.h", "vpi_compatibility.h"):
            header = directory / name
            if name == "vpi_compatibility.h" and not header.is_file():
                continue
            if not header.is_file():
                parser.error(f"{label} lacks {name}")
            artifacts[f"{label}/{name}"] = header
    hashes = {name: digest(path) for name, path in artifacts.items()}
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    checker = checker_digest()
    runner = suite_results.runner_digest("verilator")
    version = suite_results.tool_version([verilator, "--version"])
    compilers = {lang: suite_results.tool_version([path, "--version"]) for lang, path in drivers.items()}
    with tempfile.TemporaryDirectory() as directory:
        headers = {label: observe(path, drivers, Path(directory)) for label, path in includes.items()}
    run_matches, reason = run_verilator.run(fixture, verilator, 1, run_verilator.install_prefix(verilator))
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checker != checker_digest()
            or inputs != suite_results.fingerprints([fixture]) or runner != suite_results.runner_digest("verilator")):
        parser.exit(2, "Tool, headers, checker or fixture changed during qualification.\n")
    qualified = run_matches and all(result["pass"] for result in headers["verilator"].values())
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "binary_and_header_sha256": hashes,
                     "compilers": compilers}
    status = ("pass", "") if qualified else ("fail", reason or "public header allocations differed")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: status}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], "headers": headers,
                                                  "runtime_matches": run_matches}}}, indent=2) + "\n",
        encoding="utf-8")
    for label, languages in headers.items():
        print(f"{label}: " + ", ".join(f"{lang} {'pass' if result['pass'] else 'fail'}"
                                       for lang, result in languages.items()))
    print(f"Verilator simulation {'pass' if run_matches else 'fail'}")
    return int(not qualified or not all(result["pass"] for checks in headers.values() for result in checks.values()))


if __name__ == "__main__":
    raise SystemExit(main())

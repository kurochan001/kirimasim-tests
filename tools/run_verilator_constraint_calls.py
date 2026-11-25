#!/usr/bin/env python3
"""Observe side-effect-free constraint calls through Verilator line coverage."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import run_verilator
import suite_results


PROFILE = "verilator-active-constraint-calls"
CHECKER = "tools/run_verilator_constraint_calls.py"
CASE = "ch18/test_active_constraint_functions_execute"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
RETURNS = {"left_bound": "return base + 4;", "right_bound": "return base * 3;"}
ORDERS = {"forward": [], "reverse": ["+define+REVERSE_CONSTRAINT_ORDER"]}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def hit_counts(report: str, source: Path, sites: dict[str, int]) -> dict[str, int]:
    counts = {}
    methods = {line: name for name, line in sites.items()}
    in_source = False
    for line in report.splitlines():
        if line.startswith("SF:"):
            in_source = (source.parent / line[3:]).resolve() == source
        elif line == "end_of_record":
            in_source = False
        elif in_source and line.startswith("DA:"):
            line_number, times, *_ = line[3:].split(",")
            if method := methods.get(int(line_number)):
                if method in counts:
                    raise ValueError(f"duplicate coverage record for {method}")
                counts[method] = int(times)
    return counts


def hits_match(mode: str, hits: dict[str, int]) -> bool:
    if hits.keys() != RETURNS.keys():
        return False
    if mode == "active":
        return all(count >= 1 for count in hits.values())
    expected = {"inactive": 0, "direct": 2}[mode]
    return all(count == expected for count in hits.values())


def run_orders(verilator: Path, coverage: Path, fixture: Path, sites: dict[str, int]) -> dict:
    expected = {
        "active": suite_results.expected_output(fixture).splitlines(),
        "inactive": ["disabled in domain: 1"],
        "direct": ["direct first: 11 21", "direct second: 12 24"],
    }
    orders = {}
    for order, defines in ORDERS.items():
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory).resolve()
            source = work / fixture.name
            shutil.copyfile(fixture, source)
            compile_command = [str(verilator), "--binary", "--timing", "--coverage-line",
                               "-Wno-fatal", "-Wno-lint", "-Wno-style", "--top-module", fixture.stem,
                               "-Mdir", "obj", "--prefix", "Vcalls", *defines, source.name]
            build = run_verilator.execute(compile_command, run_verilator.BUILD_TIMEOUT, cwd=str(work))
            if build.returncode != 0:
                errors = [line for line in build.stderr.splitlines() if line.startswith("%Error")]
                orders[order] = {"pass": False, "compile_exit": build.returncode,
                                 "diagnostics": [run_verilator.neutral(line, str(work)) for line in errors]}
                continue

            executable = str(work / "obj" / "Vcalls")
            trials = {}
            for mode, output in expected.items():
                raw, report = f"{mode}.dat", f"{mode}.info"
                options = [] if mode == "active" else [f"+{mode}"]
                run = run_verilator.execute([executable, f"+verilator+coverage+file+{raw}", *options],
                                           run_verilator.RUN_TIMEOUT, cwd=str(work))
                convert = run_verilator.execute([str(coverage), "--write-info", report, raw],
                                               run_verilator.RUN_TIMEOUT, cwd=str(work))
                lines = [line for line in run.stdout.splitlines() if not run_verilator.BANNER.match(line)]
                hits = hit_counts((work / report).read_text(encoding="utf-8"), source, sites) if convert.returncode == 0 else {}
                ok = run.returncode == convert.returncode == 0 and lines == output and hits_match(mode, hits)
                trials[mode] = {"pass": ok, "runtime_exit": run.returncode, "converter_exit": convert.returncode,
                                "stdout": lines, "expected_stdout": output, "hits": hits}
            orders[order] = {"pass": all(trial["pass"] for trial in trials.values()), "trials": trials}
    return orders


def select_sites(fixture: Path) -> dict[str, int]:
    source = fixture.read_text(encoding="utf-8").splitlines()
    sites = {}
    for method, statement in RETURNS.items():
        lines = [line for line, text in enumerate(source, 1) if text.strip() == statement]
        if len(lines) != 1:
            raise ValueError(f"{method}: expected one return statement in {fixture.name}")
        sites[method] = lines[0]
    return sites


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--coverage", required=True, help="verilator_coverage from the same install")
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    programs = [shutil.which(program) for program in (args.verilator, args.coverage)]
    if None in programs:
        parser.error("both Verilator executables must be available")
    verilator, coverage = (Path(program).resolve() for program in programs)
    version = suite_results.tool_version([str(verilator), "--version"])
    if not version or version != suite_results.tool_version([str(coverage), "--version"]):
        parser.error("the compiler and coverage tool must report the same version")
    binaries = {"verilator": verilator, "coverage": coverage}
    for name, path, variable, default in (
        ("compiler", verilator, "VERILATOR_BIN", "verilator_bin"),
        ("coverage_backend", coverage, "VERILATOR_COVERAGE_BIN", "verilator_coverage_bin"),
    ):
        binary = shutil.which(os.environ.get(variable, str(path.with_name(default))))
        if binary:
            binaries[name] = Path(binary).resolve()
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    runner_hash = suite_results.runner_digest("verilator")
    checker_hash = checker_digest()
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    sites = select_sites(fixture)
    try:
        orders = run_orders(verilator, coverage, fixture, sites)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        orders = {"qualification": {"pass": False, "error": type(error).__name__}}
    if (binary_hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    passed = all(order["pass"] for order in orders.values())
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash, "binary_sha256": binary_hashes}
    result = ("pass", "") if passed else ("fail", "constraint function output or line count differed")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: result},
                        inputs=inputs, runner_sha256=runner_hash, configuration=configuration)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "runner_sha256": runner_hash, "configuration": configuration,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "return_lines": sites,
                         "status": result[0], "orders": orders}},
    }, indent=2) + "\n", encoding="utf-8")
    for name, order in orders.items():
        print(f"{name}: {order}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Replay silent, warning and error policies for one narrowing assignment."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import run_verilator
import run_verilator_directive_extension as directive
import suite_results


CHECKER = "tools/run_verilator_width_diagnostics.py"
PROFILE = "verilator-width-diagnostic-policies"
CASE = "ch10/test_truncation_diagnostic_and_explicit_cast"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
ASSIGNMENT = "implicit_value = wide;"
POLICIES = {"silent": "-Wno-WIDTHTRUNC", "warn": "-Wno-fatal", "error": "-Werror-WIDTHTRUNC"}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for source in (CHECKER, directive.CHECKER):
        digest.update(source.encode() + b"\0")
        digest.update((suite_results.ROOT / source).read_bytes())
    return digest.hexdigest()


def trial(executable: Path, fixture: Path, policy: str) -> dict:
    with tempfile.TemporaryDirectory() as directory:
        shutil.copyfile(fixture, Path(directory) / fixture.name)
        mode = ["--lint-only"] if policy == "error" else ["--binary", "--Mdir", "obj", "-o", "probe"]
        build = run_verilator.execute(
            [str(executable), *mode, "--timing", POLICIES[policy], "--top-module",
             fixture.stem, fixture.name], run_verilator.BUILD_TIMEOUT, cwd=directory)
        truncations, other_errors = directive.diagnostics(build.stderr)
        result = {"option": POLICIES[policy], "compile_exit": build.returncode,
                  "truncations": truncations, "unrelated_errors": other_errors}
        if policy != "error" and build.returncode == 0:
            runtime = run_verilator.execute(["./obj/probe"], run_verilator.RUN_TIMEOUT, cwd=directory)
            result.update(runtime_exit=runtime.returncode, observed=[
                line for line in runtime.stdout.splitlines() if not run_verilator.BANNER.match(line)])
        return result


def qualifies(trials: dict, source: str, assignment_line: int, expected: list[str]) -> bool:
    reports = {"silent": [], "warn": [{"severity": "warning", "file": source, "line": assignment_line}],
               "error": [{"severity": "error", "file": source, "line": assignment_line}]}
    if any(item["unrelated_errors"] or item["truncations"] != reports[policy]
           for policy, item in trials.items()):
        return False
    if trials["error"]["compile_exit"] <= 0:
        return False
    return all(item["compile_exit"] == 0 and item["runtime_exit"] == 0 and item["observed"] == expected
               for item in (trials["silent"], trials["warn"]))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    program = shutil.which(args.verilator)
    if program is None:
        parser.error("Verilator is unavailable")
    launcher = Path(program).resolve()
    compiler = shutil.which(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    binaries = {"launcher": launcher}
    if compiler is not None:
        binaries["compiler"] = Path(compiler).resolve()
    binary_hashes = {name: directive.digest(path) for name, path in binaries.items()}
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("verilator")
    version = suite_results.tool_version([str(launcher), "--version"])
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    assignment_line, = (number for number, line in enumerate(fixture.read_text(encoding="utf-8").splitlines(), 1)
                        if line.strip() == ASSIGNMENT)
    expected = suite_results.expected_output(fixture).splitlines()
    try:
        trials = {policy: trial(launcher, fixture, policy) for policy in POLICIES}
        passed = qualifies(trials, fixture.name, assignment_line, expected)
        reason = "" if passed else "truncation diagnostic policy or control output differed"
    except (OSError, subprocess.TimeoutExpired):
        trials, passed, reason = {}, False, "compiler or simulation did not complete"
    status = "pass" if passed else "fail"
    if (binary_hashes != {name: directive.digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Compiler, checker or test input changed during qualification.\n")
    config = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
              "binaries_sha256": binary_hashes}
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: (status, reason)},
                        inputs=inputs, runner_sha256=runner_hash, configuration=config)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "version": version, "configuration": config, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": status, "reason": reason,
                         "assignment_line": assignment_line, "expected": expected, "trials": trials}},
    }, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: {status}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Replay undefined, unspecified and implementation-dependent HDL cases in Icarus."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import suite_results


CHECKER = "tools/run_domain_boundaries.py"
PROFILE = "icarus-domain-boundaries"
DISABLED_TASK = "ch9/test_disable_task_unspecified_effects"
INVALID_SCAN = "ch21/test_sscanf_invalid_conversion_observation"
CASES = {
    "ch11/test_real_power_unspecified_domain_values": {
        "+observe_zero_negative": "zero_to_negative=",
        "+observe_negative_fractional": "negative_to_fractional=",
    },
    "ch12/test_foreach_dynamic_resize_undefined": {
        "+observe_growth": "growth=",
        "+observe_shrink": "shrink=",
    },
    "ch11/test_conflicting_expression_side_effect_order": {
        "+observe_conflict": "conflicts left=",
    },
    DISABLED_TASK: {"+observe_disabled": "complete t=6 "},
    INVALID_SCAN: {},
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def execute(command: list, directory: str, timeout: int) -> dict:
    try:
        result = subprocess.run(command, cwd=directory, capture_output=True, text=True,
                                errors="replace", timeout=timeout)
    except subprocess.TimeoutExpired:
        return {"error": "timed out"}
    except OSError:
        return {"error": "could not start command"}
    return {"exit": result.returncode, "stdout": result.stdout.splitlines(),
            "stderr": result.stderr.splitlines()}


def report_received(run: dict, expected: list[str], prefix: str) -> bool:
    # Check that the isolated trial reached its report without comparing its payload.
    return (run.get("exit") == 0 and len(run["stdout"]) == len(expected) + 1
            and run["stdout"][:-1] == expected
            and run["stdout"][-1].startswith(prefix))


def task_disable_received(run: dict, expected: list[str], prefix: str) -> bool:
    entry, returned, _ = expected
    return report_received(run, [entry, "disabling task at t=2", returned], prefix)


def invalid_scan_observation(compiler: Path, runtime: Path, fixture: Path,
                             directory: str, expected: list[str]) -> tuple[bool, dict]:
    line, = (number for number, text in enumerate(fixture.read_text(encoding="utf-8").splitlines(), 1)
             if '$sscanf("42 f", "%d %k",' in text)

    def targeted_diagnostic(run: dict) -> bool:
        return any(f"{fixture.name}:{line}:" in text and "%k" in text for text in
                   [*run.get("stdout", []), *run.get("stderr", [])])

    build = execute([compiler, "-g2012", "-DOBSERVE_INVALID_SCAN", "-s", fixture.stem,
                     "-o", "invalid.vvp", fixture.name], directory, 60)
    detail = {"format_line": line, "compile": build}
    if build.get("exit") != 0:
        return build.get("exit", 0) > 0 and targeted_diagnostic(build), detail

    run = execute([runtime, "invalid.vvp"], directory, 15)
    detail["run"] = run
    before_call = [*expected, "before invalid conversion"]
    observed = report_received(run, before_call, "observed count=")
    diagnosed = (run.get("exit", 0) > 0 and run["stdout"][:len(before_call)] == before_call
                 and targeted_diagnostic(run))
    return observed or diagnosed, detail


def observe(compiler: Path, runtime: Path, fixture: Path, probes: dict) -> tuple[bool, dict]:
    expected = suite_results.expected_output(fixture).splitlines()
    with tempfile.TemporaryDirectory() as directory:
        shutil.copyfile(fixture, Path(directory) / fixture.name)
        build = execute([compiler, "-g2012", "-s", fixture.stem, "-o", "probe.vvp", fixture.name],
                        directory, 60)
        trials = {"compile": build}
        if build.get("exit") != 0:
            return False, trials
        command = [runtime, "probe.vvp"]
        control = execute(command, directory, 15)
        domains = {arg: execute([*command, arg], directory, 15) for arg in probes}
        trials.update(control=control, probes=domains)
        case = suite_results.test_id(fixture)
        if case == DISABLED_TASK:
            observed = task_disable_received(domains["+observe_disabled"], expected, probes["+observe_disabled"])
        elif case == INVALID_SCAN:
            observed, detail = invalid_scan_observation(compiler, runtime, fixture, directory, expected)
            trials["invalid_scan"] = detail
        else:
            observed = all(report_received(domains[arg], expected, prefix) for arg, prefix in probes.items())
        passed = control.get("exit") == 0 and control["stdout"] == expected and observed
        return passed, trials


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    bindir = args.iverilog_bin.resolve()
    compiler, runtime = bindir / "iverilog", bindir / "vvp"
    binaries = (compiler, runtime)
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries):
        parser.error("the binary directory must contain executable iverilog and vvp")

    binary_hashes = {path.name: digest(path) for path in binaries}
    version = suite_results.tool_version([str(compiler), "-V"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("icarus")
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    observations, results = {}, {}
    for case, fixture in fixtures.items():
        passed, trials = observe(compiler, runtime, fixture, CASES[case])
        status = "pass" if passed else "fail"
        results[case] = (status, "" if passed else "control mismatch or probe observation unavailable")
        observations[case] = {"inputs_sha256": inputs[case], "status": status, **trials}
        print(f"{case}: {status}")

    if (binary_hashes != {path.name: digest(path) for path in binaries}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("icarus")
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Icarus, the checker or test inputs changed during observation.\n")
    config = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
              "binary_sha256": binary_hashes}
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, results, inputs=inputs,
                        runner_sha256=runner_hash, configuration=config)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "version": version, "configuration": config, "runner_sha256": runner_hash,
        "tests": observations,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

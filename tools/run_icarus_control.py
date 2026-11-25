#!/usr/bin/env python3
"""Run the SystemVerilog simulation-control cases in the Icarus debugger."""

import argparse
import hashlib
import os
from pathlib import Path
import unittest

import suite_results


PROFILE = "icarus-interactive-control"
CHECKER = "tools/test_icarus_simulation_control.py"
CASE_METHODS = {
    "ch20/test_stop_suspends_each_call_and_resumes_same_tick":
        "test_two_stops_each_require_a_continue_command",
    "ch20/test_control_diagnostic_argument_defaults_to_one":
        "test_default_diagnostics_match_explicit_level_one",
}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in ("tools/run_icarus_control.py", CHECKER):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True, help="directory with iverilog and vvp")
    parser.add_argument("--json", type=Path, required=True, help="write results to this file")
    args = parser.parse_args()
    bindir = args.iverilog_bin.resolve()
    binaries = (bindir / "iverilog", bindir / "vvp")
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries):
        parser.error("both iverilog and vvp are required")
    os.environ["IVERILOG_BIN"] = str(bindir)
    from test_icarus_simulation_control import IcarusSimulationControl

    binary_hashes = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in binaries}
    version = suite_results.tool_version([str(binaries[0]), "-V"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("icarus")
    inputs = suite_results.fingerprints([
        suite_results.ROOT / "tests" / (case + ".sv") for case in CASE_METHODS
    ])
    results = {}
    for case, method in CASE_METHODS.items():
        result = unittest.TestResult()
        IcarusSimulationControl(method).run(result)
        passed = (result.testsRun == 1 and result.wasSuccessful()
                  and not result.skipped and not result.expectedFailures)
        results[case] = ("pass", "") if passed else ("fail", "interactive control output differs")
        print(f"{results[case][0].upper()} {case}")

    if (any(binary_hashes[p.name] != hashlib.sha256(p.read_bytes()).hexdigest() for p in binaries)
            or checker_hash != checker_digest()):
        parser.exit(2, "Icarus or the interactive checker changed during execution.\n")
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, results,
                        inputs=inputs, runner_sha256=runner_hash,
                        configuration={"evidence_profile": PROFILE,
                                       "checker_sha256": checker_hash,
                                       "binary_sha256": binary_hashes})
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

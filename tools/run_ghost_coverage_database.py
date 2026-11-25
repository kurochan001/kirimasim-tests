#!/usr/bin/env python3
"""Check a coverage database operation across independent Ghost runs."""

import argparse
import hashlib
import os
from pathlib import Path
import unittest

import suite_results


CHECKER = "tools/test_ghost_covergroup_report.py"
CASE = "ch19/test_coverage_db_name_and_type_data_across_two_runs"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SCENARIOS = {
    "set-name": ("ghost-coverage-db-set-name", "test_select_database_filename_at_end_of_run",
                 "the selected end-of-run database was unavailable or differed"),
    "load": ("ghost-coverage-db-load", "test_load_cumulative_values_of_both_covergroup_types",
             "database did not load both expected cumulative values"),
}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in ("tools/run_ghost_coverage_database.py", CHECKER):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", type=Path, required=True, help="private Ghost executable")
    parser.add_argument("--scenario", choices=SCENARIOS, required=True)
    parser.add_argument("--json", type=Path, required=True, help="write public results to this file")
    args = parser.parse_args()
    simulator = args.simulator.resolve()
    if not simulator.is_file() or not os.access(simulator, os.X_OK):
        parser.error("Ghost executable is unavailable")
    os.environ["GHOST_SIMULATOR"] = str(simulator)
    from test_ghost_covergroup_report import GhostCovergroupReport

    profile, method, reason = SCENARIOS[args.scenario]
    binary_hash = hashlib.sha256(simulator.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints(list(CASES.values()))

    result = unittest.TextTestRunner(verbosity=2).run(GhostCovergroupReport(method))
    status = "fail"
    if result.skipped:
        status, reason = "unsupported", result.skipped[0][1]
    elif result.testsRun == 1 and result.wasSuccessful():
        status, reason = "pass", ""
    tests = {CASE: (status, reason)}

    if (binary_hash != hashlib.sha256(simulator.read_bytes()).hexdigest()
            or checker_hash != checker_digest()
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Ghost, the database checker or the simulation inputs changed during execution.\n")
    suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}", tests,
                        inputs=inputs, runner_sha256=runner_hash,
                        configuration={"evidence_profile": profile, "checker_sha256": checker_hash,
                                       "binary_sha256": binary_hash})
    return int(status != "pass")


if __name__ == "__main__":
    raise SystemExit(main())

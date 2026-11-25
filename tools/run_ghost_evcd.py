#!/usr/bin/env python3
"""Run Ghost and verify the closing records in its completed EVCD files."""

import argparse
import hashlib
import os
from pathlib import Path
import unittest

import suite_results


PROFILE = "ghost-evcd-close"
CHECKER = "tools/test_ghost_evcd_close.py"
CASE_METHODS = {
    "ch21/test_evcd_dumps_whole_port_when_connected_to_slice_and_expression":
        "test_vcdclose_records_end_even_after_changes_stop",
    "ch21/test_evcd_close_waits_for_finish_even_when_dumping_is_paused":
        "test_finish_finalizes_active_and_paused_files",
    "ch21/test_evcd_close_records_final_time_when_queue_drains":
        "test_queue_drain_finalizes_file_at_last_scheduled_event",
}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in ("tools/run_ghost_evcd.py", CHECKER):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", type=Path, required=True, help="private Ghost executable")
    parser.add_argument("--json", type=Path, required=True, help="write public results to this file")
    args = parser.parse_args()
    simulator = args.simulator.resolve()
    if not simulator.is_file() or not os.access(simulator, os.X_OK):
        parser.error("Ghost executable is unavailable")
    os.environ["GHOST_SIMULATOR"] = str(simulator)
    from test_ghost_evcd_close import GhostEvcdClose

    binary_hash = hashlib.sha256(simulator.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints([
        suite_results.ROOT / "tests" / (case + ".sv") for case in CASE_METHODS
    ])
    results = {}
    for case, method in CASE_METHODS.items():
        result = unittest.TestResult()
        GhostEvcdClose(method).run(result)
        passed = result.testsRun == 1 and result.wasSuccessful() and not result.skipped
        results[case] = ("pass", "") if passed else ("fail", "completed EVCD differs or was unavailable")
        print(f"{results[case][0].upper()} {case}")

    if (binary_hash != hashlib.sha256(simulator.read_bytes()).hexdigest()
            or checker_hash != checker_digest()):
        parser.exit(2, "Ghost or the waveform checker changed during execution.\n")
    suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}", results,
                        inputs=inputs, runner_sha256=runner_hash,
                        configuration={"evidence_profile": PROFILE,
                                       "checker_sha256": checker_hash,
                                       "binary_sha256": binary_hash})
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

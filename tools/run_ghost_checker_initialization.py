#!/usr/bin/env python3
"""Probe checker free-variable initialization before the first clock in Ghost."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_ghost
import suite_results


PROFILE = "ghost-checker-initialization"
CHECKER = "tools/run_ghost_checker_initialization.py"
CASE = "ch17/test_checker_free_initial_values_before_any_clock"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SEEDS = (1, 7, 31, 73, 101, 509)
DRAW = re.compile(r"draws active=(?P<active>[0-9a-f]{16}) inactive=(?P<inactive>[0-9a-f]{16}) "
                  r"const=(?P<const>[0-9a-f]{16}) control=(?P<control>[0-9a-f]{8})")


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def observe_seed(test: Path, simulator: Path, profile: dict, seed: int) -> dict:
    with tempfile.TemporaryDirectory() as cwd:
        try:
            result = subprocess.run(
                [str(simulator), *profile["arguments"], "--seed", str(seed),
                 "-top", suite_results.top_module(test), str(test), "+print-initial-values"],
                cwd=cwd, env={**os.environ, **profile["environment"]},
                capture_output=True, text=True, errors="replace", timeout=90,
            )
        except (OSError, subprocess.TimeoutExpired):
            return {"seed": seed, "error": "could not start or run timed out"}
    output = run_ghost.normalize(result.stdout, profile).splitlines()
    if result.returncode != 0 or len(output) != 2:
        return {"seed": seed, "error": "did not complete with two observations"}
    match = DRAW.fullmatch(output[1])
    if match is None:
        return {"seed": seed, "error": "initialization trace missing or malformed"}
    return {"seed": seed, **match.groupdict(),
            "initializer_preserved": output[0] + "\n" == suite_results.expected_output(test)}


def evaluate(rows: list[dict]) -> tuple[str, str]:
    if any("error" in row for row in rows):
        return "fail", "seed sweep did not complete"
    if not all(row["initializer_preserved"] for row in rows):
        return "fail", "explicit initializer changed"
    if len({row["control"] for row in rows}) < 2:
        return "fail", "the ordinary random control was invariant across seeds"
    # No individual value is prescribed. Compare only the behavior across
    # seeds once the control has established that the seed actually changed.
    invariant = [name for name in ("active", "inactive", "const")
                 if len({row[name] for row in rows}) < 2]
    if invariant:
        return "fail", "invariant checker initialization across seeds: " + ", ".join(invariant)
    return "pass", ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, help="private Ghost executable")
    parser.add_argument("--profile", type=Path, required=True, help="private runtime profile")
    parser.add_argument("--json", type=Path, required=True, help="write public results to this file")
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    if program is None:
        parser.error("Ghost executable is unavailable")
    simulator = Path(program).resolve()
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    binary_hash = hashlib.sha256(simulator.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints(list(CASES.values()))
    observed = [observe_seed(CASES[CASE], simulator, profile, seed) for seed in SEEDS]
    status, reason = evaluate(observed)
    if (binary_hash != hashlib.sha256(simulator.read_bytes()).hexdigest()
            or checker_hash != checker_digest()
            or runner_hash != suite_results.runner_digest("ghost")
            or profile_bytes != args.profile.read_bytes()
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Ghost, the checker, the profile or simulation inputs changed.\n")
    suite_results.write(
        args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}",
        {CASE: (status, reason)}, inputs=inputs, runner_sha256=runner_hash,
        configuration={"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                       "binary_sha256": binary_hash, "seed_observations": observed,
                       "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()},
    )
    print(status.upper() + (f": {reason}" if reason else ""))
    return int(status != "pass")


if __name__ == "__main__":
    raise SystemExit(main())

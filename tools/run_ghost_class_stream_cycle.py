#!/usr/bin/env python3
"""Replay a class streaming control and record the cyclic process outcome."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shutil
import subprocess
import tempfile

import run_ghost
import suite_results


CHECKER = "tools/run_ghost_class_stream_cycle.py"
PROFILE = "ghost-class-stream-cycle"
CASE = "ch11/test_class_stream_cycle_observation"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
CYCLE_MARKER = "before cyclic stream self=1"
CYCLE_VALUE = re.compile(r"after cyclic stream value=([0-9a-f]{2})", re.IGNORECASE)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def observe(simulator: Path, fixture: Path, profile: dict, cycle: bool) -> dict:
    args = ["+observe_cycle"] if cycle else []
    with tempfile.TemporaryDirectory() as directory:
        shutil.copyfile(fixture, Path(directory) / fixture.name)
        try:
            result = subprocess.run(
                [simulator, *profile["arguments"], *args, fixture.name],
                cwd=directory, env={**os.environ, **profile["environment"]},
                capture_output=True, text=True, errors="replace", timeout=20,
            )
        except subprocess.TimeoutExpired as error:
            output = (error.stdout or b"").decode(errors="replace")
            return {"exit": None, "timed_out": True,
                    "stdout": run_ghost.normalize(output, profile).splitlines()}
    return {"exit": result.returncode, "timed_out": False,
            "stdout": run_ghost.normalize(result.stdout, profile).splitlines()}


def cycle_outcome(trial: dict, expected: list[str]) -> str:
    prefix = [*expected, CYCLE_MARKER]
    if trial["stdout"][:len(prefix)] != prefix:
        return "not_reached"
    if trial["timed_out"]:
        return "timeout"
    if trial["exit"] < 0:
        return "signal"
    if trial["exit"] > 0:
        return "error_exit"
    tail = trial["stdout"][len(prefix):]
    if len(tail) == 1 and CYCLE_VALUE.fullmatch(tail[0]):
        return "returned"
    return "unconfirmed"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, type=Path)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    simulator = args.simulator.resolve()
    if not simulator.is_file():
        parser.error("Ghost executable is unavailable")
    profile_hash = digest(args.profile)
    profile = json.loads(args.profile.read_bytes())
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    binary_hash = digest(simulator)
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    expected = suite_results.expected_output(fixture).splitlines()

    # The isolated probe can terminate by a signal. Do not write a core dump.
    _, hard_limit = resource.getrlimit(resource.RLIMIT_CORE)
    resource.setrlimit(resource.RLIMIT_CORE, (0, hard_limit))
    control = observe(simulator, fixture, profile, cycle=False)
    cyclic = observe(simulator, fixture, profile, cycle=True)
    outcome = cycle_outcome(cyclic, expected)
    matches = control["exit"] == 0 and control["stdout"] == expected
    if not matches:
        status, reason = "fail", "the acyclic control differed from its expected output"
    elif outcome in ("returned", "signal", "error_exit"):
        status, reason = "pass", ""
    else:
        status, reason = "unsupported", f"the cyclic observation was {outcome}"
    if (profile_hash != digest(args.profile) or binary_hash != digest(simulator)
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker, or inputs changed during qualification.\n")

    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "artifact_sha256": {"ghost": binary_hash}, "profile_sha256": profile_hash}
    version = f"private build {binary_hash[:12]}"
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: (status, reason)}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": status, "control": control,
                         "cyclic": {**cyclic, "outcome": outcome}}},
    }, indent=2) + "\n", encoding="utf-8")
    print(status, CASE, outcome)
    return int(status != "pass")


if __name__ == "__main__":
    raise SystemExit(main())

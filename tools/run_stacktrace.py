#!/usr/bin/env python3
"""Check stacktrace delivery and frame identities on Ghost."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

import suite_results


CHECKER = "tools/run_stacktrace.py"
PROFILE = "ghost-stacktrace"
RESULT = "ch20/test_stacktrace_task_and_function_results"
CONTEXT = "ch20/test_stacktrace_resumed_task_context"
CASES = {
    RESULT: ("CAPTURE", "RETURN", "TASK"),
    CONTEXT: ("INITIAL", "RESUME", "AFTER"),
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def frames(lines: list[str]) -> str:
    """Read the Ghost format and retain the ordered frames for comparison."""
    if (len(lines) < 3 or lines[0] != "=== Call Stack Trace ==="
            or lines[-1] != "======================="):
        raise ValueError("could not decode a stack trace")
    body = lines[1:-1]
    if body == ["(top level)"]:
        return "top level"
    labels = []
    for index, line in enumerate(body):
        frame = re.fullmatch(r"#(\d+) ([\w$.:]+)(?:\s+.*)?", line)
        if frame is None or int(frame[1]) != index:
            raise ValueError("could not decode an ordered frame")
        labels.append(frame[2].rsplit(".", 1)[-1])
    return ",".join(labels)


def blocks(output: str, markers: tuple[str, ...]) -> tuple[dict[str, list[str]], list[str]]:
    lines = [line.strip() for line in output.splitlines() if line.strip()]
    result = {}
    detail = []
    start = 0
    for marker in markers:
        begin, end = marker + "_BEGIN", marker + "_END"
        if lines.count(begin) != 1 or lines.count(end) != 1:
            raise ValueError("missing or repeated observation marker")
        first, last = lines.index(begin), lines.index(end)
        if not start <= first < last:
            raise ValueError("observation markers are out of order")
        detail.extend(lines[start:first])
        result[marker] = lines[first + 1:last]
        start = last + 1
    detail.extend(lines[start:])
    return result, detail


def observe(case: str, output: str) -> list[str]:
    trace, detail = blocks(output, CASES[case])
    if case == RESULT:
        if len(detail) != 1 or not re.fullmatch(r"type=\w+ nonempty=[01]", detail[0]):
            raise ValueError("missing or unexpected result type observation")
        return [
            f"capture emitted={int(bool(trace['CAPTURE']))}",
            detail[0],
            f"returned={frames(trace['RETURN'])}",
            f"displayed={frames(trace['TASK'])}",
        ]
    if detail:
        raise ValueError("unexpected output outside context observations")
    return [
        f"initial={frames(trace['INITIAL'])}",
        f"resumed={frames(trace['RESUME'])}",
        f"after={frames(trace['AFTER'])}",
    ]


def run(simulator: Path, fixture: Path, case: str) -> tuple[tuple[str, str], dict]:
    expected = suite_results.expected_output(fixture).splitlines()
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [str(simulator), "--quiet-all", "--lrm-strict", str(fixture)],
                cwd=directory, capture_output=True, text=True, errors="replace", timeout=60,
            )
    except (OSError, subprocess.TimeoutExpired):
        return ("fail", "simulation did not complete"), {"expected": expected}
    evidence = {"simulation_exit": result.returncode, "expected": expected}
    if result.returncode != 0 or re.search(r"^\s*(?:\[(?:error|fatal)\]|(?:error|fatal):)",
                                           result.stderr, re.MULTILINE | re.IGNORECASE):
        return ("fail", "simulation emitted an error or exited unsuccessfully"), evidence
    try:
        actual = observe(case, result.stdout)
    except ValueError as error:
        return ("fail", str(error)), evidence
    evidence["observed"] = actual
    if actual != expected:
        return ("fail", "observed stacktrace differs"), evidence
    return ("pass", ""), evidence


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    simulator = args.simulator.resolve()
    if not simulator.is_file():
        parser.error("Ghost executable is unavailable")

    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    binary_hash = digest(simulator)
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints(list(fixtures.values()))
    observations, results = {}, {}
    for case, fixture in fixtures.items():
        results[case], evidence = run(simulator, fixture, case)
        status, reason = results[case]
        observations[case] = {"status": status, "reason": reason,
                              "inputs_sha256": inputs[case], **evidence}
        print(f"{case}: {status}" + (f" ({reason})" if reason else ""))

    if (binary_hash != digest(simulator) or checker_hash != checker_digest()
            or runner_hash != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Simulator, checker, or test input changed during measurement.\n")

    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "binary_sha256": binary_hash}
    suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}", results,
                        inputs=inputs, runner_sha256=runner_hash, configuration=configuration)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": observations,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

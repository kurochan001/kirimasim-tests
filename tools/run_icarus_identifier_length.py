#!/usr/bin/env python3
"""Measure and verify the Icarus lexer boundary for simple identifiers."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

import run_icarus
import suite_results


PROFILE = "icarus-identifier-length"
CHECKER = "tools/run_icarus_identifier_length.py"
CASE = "ch5/test_identifier_length_boundary"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
DIAGNOSTIC_REQUIREMENTS = {"SV2023-5.6-EXTRACT-IDENTIFIER-LIMIT-ERROR"}
DIAGNOSTIC_ANCHOR = "input buffer overflow, can't enlarge buffer because scanner uses REJECT"
MIN_LENGTH = 1024
PROBE_MAX_LENGTH = 262144
FIRST_NAME = "length_probe_x"
SECOND_NAME = "length_probe_y"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def measure(binaries: dict[str, Path], fixture: Path, work: Path) -> dict:
    source = fixture.read_text(encoding="utf-8")
    expected = suite_results.expected_output(fixture).splitlines()
    design = work / fixture.name
    compiled = work / "design.vvp"
    probes = []
    observations = {"minimum_length": MIN_LENGTH, "probe_max_length": PROBE_MAX_LENGTH, "probes": probes}

    def run(text: str) -> dict:
        design.write_text(text, encoding="utf-8")
        compiled.unlink(missing_ok=True)
        build = run_icarus.execute(
            [str(binaries["iverilog"]), "-g2012", "-s", fixture.stem, "-o", compiled.name, design.name],
            run_icarus.COMPILE_TIMEOUT, cwd=str(work),
        )
        observation = {"compile_exit": build.returncode}
        if build.returncode == 0:
            result = run_icarus.execute(
                [str(binaries["vvp"]), compiled.name], run_icarus.RUN_TIMEOUT, cwd=str(work),
            )
            output = result.stdout.splitlines()
            outcome = "accepted" if result.returncode == 0 and output == expected and not result.stderr else "unexpected"
            observation.update(run_exit=result.returncode, stdout_matches=output == expected)
        elif build.returncode > 0 and DIAGNOSTIC_ANCHOR in build.stderr.splitlines():
            outcome = "lexer_diagnostic"
            observation["diagnostic"] = DIAGNOSTIC_ANCHOR
        else:
            outcome = "unexpected"
        return {**observation, "outcome": outcome}

    def probe(length: int) -> str:
        prefix = "a" * (length - 1)
        design_text = source.replace(FIRST_NAME, prefix + "x").replace(SECOND_NAME, prefix + "y")
        observation = run(design_text)
        probes.append({"length": length, **observation})
        return observation["outcome"]

    if probe(MIN_LENGTH) != "accepted":
        return {**observations, "reason": "the minimum length or distinct values failed"}

    accepted = MIN_LENGTH
    rejected = 2 * MIN_LENGTH
    while rejected <= PROBE_MAX_LENGTH:
        outcome = probe(rejected)
        if outcome == "lexer_diagnostic":
            break
        if outcome != "accepted":
            return {**observations, "reason": "unexpected compiler or simulation result"}
        accepted = rejected
        rejected *= 2
    else:
        return {**observations, "reason": "no lexer boundary observed within the probe range"}

    while rejected - accepted > 1:
        midpoint = (accepted + rejected) // 2
        outcome = probe(midpoint)
        if outcome == "accepted":
            accepted = midpoint
        elif outcome == "lexer_diagnostic":
            rejected = midpoint
        else:
            return {**observations, "reason": "unexpected compiler or simulation result"}

    last_accepted = probe(accepted)
    first_rejected = probe(rejected)
    if (last_accepted, first_rejected) != ("accepted", "lexer_diagnostic"):
        return {**observations, "reason": "adjacent outcomes changed when repeated"}

    # Keep the short names and exceed even the longest line of the failing design.
    longest_failing_line = max(len(line) for line in source.replace(
        FIRST_NAME, "a" * rejected).replace(SECOND_NAME, "a" * rejected).splitlines())
    short_tokens = "/* short */ "
    padding = short_tokens * (longest_failing_line // len(short_tokens) + 1)
    control_source = source.replace(f"  int {FIRST_NAME}", f"  {padding}int {FIRST_NAME}")
    control_line_length = max(map(len, control_source.splitlines()))
    control = run(control_source)
    observations.update(
        last_accepted=accepted, first_rejected=rejected,
        longest_rejected_source_line=longest_failing_line,
        long_line_control={"line_length": control_line_length, **control},
    )
    if control_line_length <= longest_failing_line or control["outcome"] != "accepted":
        return {**observations, "reason": "the long line made of short tokens did not pass"}
    return observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    bindir = args.iverilog_bin.resolve()
    binaries = {name: bindir / name for name in ("iverilog", "vvp")}
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries.values()):
        parser.error("iverilog and vvp must be available")
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    version = suite_results.tool_version([str(binaries["iverilog"]), "-V"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("icarus")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation = measure(binaries, fixture, Path(directory))
    except (OSError, subprocess.TimeoutExpired) as error:
        observation = {"reason": type(error).__name__}
    if (binary_hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("icarus")
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "binary_sha256": binary_hashes}
    reason = observation.get("reason", "")
    status = "fail" if reason else "pass"
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, {CASE: (status, reason)},
                        inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}}},
        indent=2) + "\n", encoding="utf-8")
    if reason:
        print(reason)
    else:
        print(f"{observation['last_accepted']} characters accepted, "
              f"{observation['first_rejected']} characters diagnosed")
    return int(bool(reason))


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Compare the current sequence method with legacy and unknown selectors."""

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


PROFILE = "ghost-sequence-method-migration"
CHECKER = "tools/run_ghost_sequence_method.py"
CASE = "ch16/test_sequence_triggered_replaces_ended"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
MODES = {
    "current": ("triggered", []),
    "legacy": ("ended", ["+define+PROBE_LEGACY_METHOD"]),
    "unknown": ("no_such_sequence_method", ["+define+PROBE_UNKNOWN_METHOD"]),
}
MEMBER_ERROR = re.compile(r"SEQUENCE-MEMBER-ACCESS|no visible member|no member|unknown .*method", re.I)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def verdict(mode: str, result: dict, expected: list[str]) -> str:
    if mode != "unknown" and result["returncode"] == 0 and result["stdout"] == expected:
        return "current" if mode == "current" else "legacy_alias"
    if mode != "current" and result["returncode"] > 0 and result["member_diagnostic"]:
        return "selector_rejected"
    return "unexpected"


def observe(simulator: Path, fixture: Path, profile: dict) -> dict:
    expected = suite_results.expected_output(fixture).splitlines()
    source = fixture.read_text(encoding="utf-8").splitlines()
    result = {}
    with tempfile.TemporaryDirectory() as directory:
        test = Path(directory) / fixture.name
        shutil.copyfile(fixture, test)
        for mode, (selector, options) in MODES.items():
            [line] = [i for i, text in enumerate(source, 1)
                      if f"request_complete.{selector} ##0 gate;" in text]
            try:
                run = subprocess.run([str(simulator), *profile["arguments"], *options, "-top", fixture.stem, test.name],
                                     cwd=directory, env={**os.environ, **profile["environment"]},
                                     capture_output=True, text=True, errors="replace", timeout=60)
            except subprocess.TimeoutExpired:
                result[mode] = {"pass": False, "reason": "timed out"}
                continue
            messages = run_ghost.ANSI.sub("", run.stderr + "\n" + run.stdout).splitlines()
            where = re.compile(rf"\b{re.escape(test.name)}:{line}(?::\d+)?(?::|\s|$)")
            diagnostics = [message for message in messages if where.search(message) and MEMBER_ERROR.search(message)]
            trial = {"returncode": run.returncode, "stdout": run_ghost.normalize(run.stdout, profile).splitlines(),
                     "member_diagnostic": bool(diagnostics), "diagnostics": diagnostics, "selector_line": line}
            trial["outcome"] = verdict(mode, trial, expected)
            trial["pass"] = trial["outcome"] != "unexpected"
            result[mode] = trial
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    executable = shutil.which(args.simulator)
    if not executable:
        parser.error("Ghost simulator must be available")
    simulator = Path(executable).resolve()
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    fingerprint = digest(simulator)
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    trials = observe(simulator, fixture, profile)
    if (digest(simulator) != fingerprint or checker_digest() != checksum
            or suite_results.runner_digest("ghost") != runner or args.profile.read_bytes() != profile_bytes
            or suite_results.fingerprints([fixture]) != inputs):
        parser.exit(2, "Tool, checker, profile or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "binary_sha256": fingerprint,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    version = f"private build {fingerprint[:12]}"
    passed = all(trial["pass"] for trial in trials.values())
    result = ("pass", "") if passed else ("fail", "sequence method observation differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: result},
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "ghost", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "pass": passed, "trials": trials}},
    }, indent=2) + "\n", encoding="utf-8")
    for mode, trial in trials.items():
        print(mode, trial)
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

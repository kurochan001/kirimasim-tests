#!/usr/bin/env python3
"""Observe two illegal class accesses with indeterminate results."""

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
import run_verilator
import suite_results


PROFILE = "verilator-null-instance-access"
CHECKER = "tools/run_null_instance_access.py"
CASE = "ch8/test_class_null_instance_access_observation"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
DIAGNOSTIC_REQUIREMENTS = {"SV2023-8.4-EXTRACT-NULL-INSTANCE-ACCESS"}
DIAGNOSTIC_ANCHOR = "RUNTIME_NULL_OBJECT"
NULL_ACCESS = re.compile(rf"\b{DIAGNOSTIC_ANCHOR}\b|\bnull\b.*\b(?:handle|object|pointer)\b", re.I)
ERROR = re.compile(r"\b(?:error|fatal)\b", re.I)
MODES = ("field", "virtual")
OUTPUT_PREFIXES = ("live field=", "null handle=", "before null ", "null field result=", "null virtual result=")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def local_error(messages: str, fixture: Path, line: int) -> list[str]:
    location = re.compile(rf"\b{re.escape(fixture.name)}:{line}(?::\d+)?(?::|\s|$)")
    lines = run_ghost.ANSI.sub("", messages).splitlines()
    for index, message in enumerate(lines):
        if not ERROR.search(message) or not NULL_ACCESS.search(message):
            continue
        following = lines[index + 1:index + 3]
        if location.search(message):
            return [message]
        for entry in following:
            if entry.lstrip().startswith("at ") and location.search(entry):
                return [message, entry]
    return []


def classify(run: subprocess.CompletedProcess, expected: list[str], mode: str, diagnostics: list[str]) -> dict:
    output = [line for line in run_ghost.ANSI.sub("", run.stdout).splitlines()
              if line == "finished" or line.startswith(OUTPUT_PREFIXES)]
    if mode == "control":
        outcome = "control_matched" if run.returncode == 0 and output == expected else "unexpected"
    else:
        control_prefix = expected[:-1]
        start = [*control_prefix, f"before null {mode}"]
        returned = re.compile(rf"null {mode} result=(?:-?\d+|[xz])", re.I)
        outcome = "unexpected"
        # A localized diagnostic can precede the display in the selected branch.
        if run.returncode != 0 and diagnostics and output in ([], control_prefix, start):
            outcome = "diagnosed"
        elif (run.returncode == 0 and output[:len(start)] == start and len(output) == len(start) + 2
              and returned.fullmatch(output[-2]) and output[-1] == expected[-1]):
            outcome = "returned_indeterminate"
        elif run.returncode < 0 and output == start:
            outcome = "terminated_by_signal"
    return {"returncode": run.returncode, "stdout": output, "diagnostics": diagnostics, "outcome": outcome}


def observe(simulator: Path, fixture: Path, profile: dict | None) -> dict:
    expected = suite_results.expected_output(fixture).splitlines()
    source = fixture.read_text(encoding="utf-8").splitlines()
    result = {}
    with tempfile.TemporaryDirectory() as directory:
        test = Path(directory) / fixture.name
        shutil.copyfile(fixture, test)
        environment = os.environ
        if profile is not None:
            command = [str(simulator), *profile["arguments"], "-top", fixture.stem, test.name]
            environment = {**os.environ, **profile["environment"]}
        else:
            build = run_verilator.execute(
                [str(simulator), "--binary", "--timing", "-Wno-fatal", "--top-module", fixture.stem,
                 "-Mdir", "obj", "--prefix", "Vt", test.name],
                run_verilator.BUILD_TIMEOUT, cwd=directory,
            )
            if build.returncode != 0:
                raise RuntimeError(f"Verilator build failed\n{build.stderr}")
            command = [str(Path(directory) / "obj" / "Vt")]
        for mode in ("control", *MODES):
            options = [] if mode == "control" else [f"+observe_null_{mode}"]
            try:
                run = subprocess.run([*command, *options], cwd=directory, env=environment,
                                     capture_output=True, text=True, errors="replace", timeout=60)
            except subprocess.TimeoutExpired:
                result[mode] = {"outcome": "timed_out"}
                continue
            diagnostics = []
            if options:
                [line] = [i for i, text in enumerate(source, 1) if f'null {mode} result=' in text]
                diagnostics = local_error(run.stderr + "\n" + run.stdout, fixture, line)
            result[mode] = classify(run, expected, mode, diagnostics)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    simulator_options = parser.add_mutually_exclusive_group(required=True)
    simulator_options.add_argument("--ghost", help="Ghost executable")
    simulator_options.add_argument("--verilator", help="Verilator executable")
    parser.add_argument("--profile", type=Path, help="strict profile for Ghost")
    parser.add_argument("--json", type=Path, help="write Verilator execution evidence")
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    executable = shutil.which(args.ghost or args.verilator)
    if not executable:
        parser.error("the selected simulator must be available")
    simulator = Path(executable).resolve()
    if bool(args.ghost) != bool(args.profile) or (args.ghost and args.json):
        parser.error("use --profile with Ghost and --json with Verilator")
    tool = "ghost" if args.ghost else "verilator"
    profile_bytes = args.profile.read_bytes() if args.profile else None
    profile = json.loads(profile_bytes) if profile_bytes is not None else None
    if profile is not None and "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    fingerprint = digest(simulator)
    checksum = checker_digest()
    runner = suite_results.runner_digest(tool)
    version = (f"private build {fingerprint[:12]}" if args.ghost
               else suite_results.tool_version([str(simulator), "--version"]))
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        trials = observe(simulator, fixture, profile)
    except (RuntimeError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (digest(simulator) != fingerprint or checker_digest() != checksum
            or suite_results.runner_digest(tool) != runner
            or (args.profile is not None and args.profile.read_bytes() != profile_bytes)
            or suite_results.fingerprints([fixture]) != inputs):
        parser.exit(2, "Tool, checker, profile or fixture changed during qualification.\n")
    configuration = {"checker_sha256": checksum, "binary_sha256": fingerprint}
    if profile_bytes is not None:
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
    else:
        configuration["evidence_profile"] = PROFILE
    invalid = {trials[mode]["outcome"] for mode in MODES}
    complete = trials["control"]["outcome"] == "control_matched" and invalid <= {"diagnosed", "returned_indeterminate"}
    witnessed = complete and "diagnosed" in invalid
    if witnessed:
        result = ("pass", "")
    elif complete:
        result = ("known", "both accesses returned indeterminate results without a localized error")
    else:
        result = ("fail", "control or evidence of the attempted access was incomplete")
    if args.json:
        suite_results.write(args.json, tool, "Verilator", version, {CASE: result},
                            inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": tool, "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": result[0], "trials": trials}},
    }, indent=2) + "\n", encoding="utf-8")
    for mode, trial in trials.items():
        print(mode, trial)
    return int(not complete)


if __name__ == "__main__":
    raise SystemExit(main())

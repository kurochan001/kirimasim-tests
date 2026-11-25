#!/usr/bin/env python3
"""Compare observed directed FSM transitions in Ghost's coverage report."""

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


CHECKER = "tools/run_fsm_transition_coverage.py"
PROFILE = "ghost-fsm-transition-coverage"
CASE = "ch40/test_fsm_coverage_distinguishes_directed_transitions"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
HEADER = "=== FSM Coverage Report ==="
FOOTER = "=== End FSM Coverage Report ==="
INSTANCE = re.compile(r"FSM: ([\w.]+)(?: \(pragma enum \w+\))?")
TRANSITIONS = re.compile(r"Transitions \((\d+)/(\d+) covered\):")
EDGE = re.compile(r"(\w+) -> (\w+): (\d+) hits?")


def digest_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def checker_digest() -> str:
    return digest_bytes((suite_results.ROOT / CHECKER).read_bytes())


def report_edges(output: str, top: str) -> list[str]:
    lines = [line.strip() for line in run_ghost.ANSI.sub("", output).splitlines()]
    if lines.count(HEADER) != 1 or lines.count(FOOTER) != 1:
        raise ValueError("missing or duplicate FSM report boundary")
    begin, end = lines.index(HEADER), lines.index(FOOTER)
    if begin >= end:
        raise ValueError("reversed FSM report boundaries")

    instances = {}
    instance = None
    for line in lines[begin + 1:end]:
        if match := INSTANCE.fullmatch(line):
            path = match[1]
            if not path.startswith(top + ".") or path in instances:
                raise ValueError("unexpected or duplicate FSM instance")
            instance = {"covered": None, "edges": {}}
            instances[path] = instance
        elif match := TRANSITIONS.fullmatch(line):
            if instance is None or instance["covered"] is not None or int(match[1]) > int(match[2]):
                raise ValueError("invalid transition totals")
            instance["covered"] = int(match[1])
        elif match := EDGE.fullmatch(line):
            edge = f"{match[1]}->{match[2]}"
            count = int(match[3])
            if instance is None or instance["covered"] is None or edge in instance["edges"]:
                raise ValueError("misplaced or duplicate transition record")
            instance["edges"][edge] = count
        elif "->" in line:
            raise ValueError("malformed transition record")
    for instance in instances.values():
        if instance["covered"] != sum(count > 0 for count in instance["edges"].values()):
            raise ValueError("transition total does not match reported edges")
    return sorted(f"{path.removeprefix(top + '.')} {edge} {count}"
                  for path, instance in instances.items()
                  for edge, count in instance["edges"].items() if count > 0)


def probe(simulator: Path, fixture: Path, profile: dict) -> tuple[tuple[str, str], dict]:
    expected_states = suite_results.expected_output(fixture).splitlines()
    expected_edges = (fixture.parent / "directed_fsm_report/expected.txt").read_text(encoding="utf-8").splitlines()
    observations = {}
    for name, arguments in (("control", []), ("enabled", ["--fsm-coverage"])):
        with tempfile.TemporaryDirectory() as working:
            process = subprocess.run([str(simulator), *profile["arguments"], *arguments, str(fixture)],
                                     cwd=working, env={**os.environ, **profile["environment"]},
                                     capture_output=True, text=True, errors="replace", timeout=90)
        states = run_ghost.normalize(process.stdout, profile).splitlines()
        has_report = HEADER in process.stdout
        observations[name] = {"exit": process.returncode,
                              "completed": profile["trailer"] in process.stdout,
                              "expected_states": expected_states,
                              "observed_states": [line for line in states
                                                  if re.fullmatch(r"states=[0-9xz]+,[0-9xz]+", line)],
                              "report_present": has_report}
        if not observations[name]["completed"] or process.returncode != 0 or states != expected_states:
            return ("fail", f"{name} HDL state history differed or simulation did not complete"), observations
    try:
        edges = report_edges(process.stdout, fixture.stem)
    except ValueError as error:
        return ("fail", str(error)), observations
    observations["enabled"].update(expected_edges=expected_edges, observed_edges=edges)
    if edges != expected_edges:
        return ("fail", "the covered edges or hit counts differed"), observations
    return ("pass", ""), observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    if program is None:
        parser.error("Ghost executable is unavailable")
    simulator = Path(program).resolve()
    binary_hash = digest_bytes(simulator.read_bytes())
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints(list(CASES.values()))
    try:
        outcome, observations = probe(simulator, CASES[CASE], profile)
    except (OSError, subprocess.TimeoutExpired):
        outcome, observations = ("fail", "simulation could not complete"), {}
    if (binary_hash != digest_bytes(simulator.read_bytes()) or profile_bytes != args.profile.read_bytes()
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Simulator, runtime profile, checker or test input changed during execution.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "binary_sha256": binary_hash, "profile_sha256": digest_bytes(profile_bytes)}
    suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}",
                        {CASE: outcome}, inputs=inputs, runner_sha256=runner_hash, configuration=configuration)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": outcome[0],
                         "reason": outcome[1], **observations}},
    }, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: {outcome[0]}" + (f" ({outcome[1]})" if outcome[1] else ""))
    return int(outcome[0] != "pass")


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Check a Verilator configuration directive against its file-local controls."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_verilator
import suite_results


CHECKER = "tools/run_verilator_directive_extension.py"
PROFILE = "verilator-directive-extension"
CASE = "ch5/test_tool_directive_controls_only_named_file"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
ASSIGNMENT = "assign selected = source;"
TRUNCATION = re.compile(r"^%(Error|Warning)-WIDTHTRUNC: ([^:]+):(\d+):\d+:")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def diagnostics(stderr: str) -> tuple[list[dict], int]:
    truncations = []
    unrelated = 0
    for line in stderr.splitlines():
        if match := TRUNCATION.match(line):
            truncations.append({"severity": match[1].lower(),
                                "file": Path(match[2]).name, "line": int(match[3])})
        elif line.startswith("%Error") and not line.startswith("%Error: Exiting due to "):
            unrelated += 1
    return truncations, unrelated


def compile_trial(executable: Path, fixture: Path, assignment_line: int, trial: str) -> dict:
    source_name = "other_source.sv" if trial == "other_file" else fixture.name
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        shutil.copyfile(fixture, work / source_name)
        config_args = []
        if trial != "control":
            shutil.copyfile(fixture.parent / "directive_filter/waive.vlt", work / "waive.vlt")
            config_args = ["waive.vlt"]
        mode = ["--binary", "--Mdir", "obj", "-o", "probe"] if trial == "selected" else ["--lint-only"]
        result = run_verilator.execute(
            [str(executable), *mode, "--timing", "-Werror-WIDTHTRUNC",
             "--top-module", fixture.stem, *config_args, source_name],
            run_verilator.BUILD_TIMEOUT, cwd=directory,
        )
        truncations, unrelated = diagnostics(result.stderr)
        observation = {"exit": result.returncode, "source": source_name, "expected_line": assignment_line,
                       "truncations": truncations, "unrelated_errors": unrelated}
        if trial == "selected" and result.returncode == 0:
            runtime = run_verilator.execute(["./obj/probe"], run_verilator.RUN_TIMEOUT, cwd=directory)
            expected = suite_results.expected_output(fixture).splitlines()
            actual = [line for line in runtime.stdout.splitlines() if not run_verilator.BANNER.match(line)]
            observation.update(simulation_exit=runtime.returncode, expected=expected,
                               observed=[line for line in actual if re.fullmatch(r"selected=[0-9a-fxz]", line)],
                               simulation_matches=actual == expected)
        return observation


def assess(trials: dict) -> tuple[str, str]:
    for name in ("control", "other_file"):
        trial = trials[name]
        if (trial["exit"] <= 0 or trial["unrelated_errors"] or trial["truncations"] != [
                {"severity": "error", "file": trial["source"], "line": trial["expected_line"]}]):
            return "fail", f"{name} did not report truncation at the assignment"
    selected = trials["selected"]
    if selected["exit"] != 0 or selected["truncations"] or selected["unrelated_errors"]:
        return "fail", "the configured filename did not compile cleanly"
    if selected["simulation_exit"] != 0 or not selected["simulation_matches"]:
        return "fail", "the configured file's HDL output differed"
    return "pass", ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    executable = shutil.which(args.verilator)
    if executable is None:
        parser.error("Verilator is unavailable")
    launcher = Path(executable).resolve()
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    binaries = {"launcher": launcher}
    if backend is not None:
        binaries["compiler"] = Path(backend).resolve()
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    version = suite_results.tool_version([str(launcher), "--version"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("verilator")
    inputs = suite_results.fingerprints(list(CASES.values()))
    fixture = CASES[CASE]
    assignment_line, = (line for line, source in enumerate(fixture.read_text(encoding="utf-8").splitlines(), 1)
                        if source.strip() == ASSIGNMENT)
    try:
        trials = {trial: compile_trial(launcher, fixture, assignment_line, trial)
                  for trial in ("control", "selected", "other_file")}
        outcome = assess(trials)
    except (OSError, subprocess.TimeoutExpired):
        trials = {}
        outcome = "fail", "compiler or simulation did not complete"
    if (binary_hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Compiler, checker or test input changed during qualification.\n")
    config = {"evidence_profile": PROFILE, "checker_sha256": checker_hash, "binaries_sha256": binary_hashes}
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: outcome}, inputs=inputs,
                        runner_sha256=runner_hash, configuration=config)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "version": version, "configuration": config, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": outcome[0], "reason": outcome[1], **trials}},
    }, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: {outcome[0]}" + (f" ({outcome[1]})" if outcome[1] else ""))
    return int(outcome[0] != "pass")


if __name__ == "__main__":
    raise SystemExit(main())

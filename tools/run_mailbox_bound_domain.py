#!/usr/bin/env python3
"""Check legal mailbox bounds and record two out-of-domain inputs on two simulators."""

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


CHECKER = "tools/run_mailbox_bound_domain.py"
PROFILE = "ghost-verilator-mailbox-bound-domain"
CASE = "ch15/test_mailbox_bound_domain_observation"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
UNDEFINED_INPUT_REQUIREMENTS = {"SV2023-15.4.1-EXTRACT-NEGATIVE-BOUND-ILLEGAL"}
UNDEFINED_INPUT_ANCHOR = "entered_undefined_input"
BOUNDS = {"control": None, "minus_one": -1, "signed_minimum": -(2**31)}
BOUND_DIAGNOSTIC = re.compile(r"^(?=.*(?:warning|error))(?=.*mailbox)(?=.*(?:negative|bound)).*$", re.I)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    checksum = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    checksum.update(suite_results.runner_digest("verilator").encode())
    return checksum.hexdigest()


def measure(command: list, profile: dict | None, bound: int | None, expected: list[str], work: Path) -> dict:
    args = [] if bound is None else [f"+mailbox_bound={bound}"]
    environment = {**os.environ, **profile["environment"]} if profile is not None else None
    result = subprocess.run([*command, *args], cwd=work, env=environment, capture_output=True,
                            text=True, errors="replace", timeout=20)
    messages = run_ghost.ANSI.sub("", result.stdout + "\n" + result.stderr).splitlines()
    diagnostics = sum(BOUND_DIAGNOSTIC.fullmatch(line) is not None for line in messages)
    if profile is None:
        output = [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]
    else:
        output = run_ghost.normalize(result.stdout, profile).splitlines()
    observation = {"bound": bound, "exit": result.returncode, "stdout": output,
                   "bound_diagnostics": diagnostics}
    if bound is None:
        return {**observation, "pass": result.returncode == 0 and output == expected and diagnostics == 0}
    prefix = [*expected, f"before negative constructor bound={bound}"]
    entered_undefined_input = bound < 0 and output[:len(prefix)] == prefix
    return {**observation, "entered_undefined_input": entered_undefined_input, "pass": entered_undefined_input}


def observe(artifacts: dict, profile: dict, fixture: Path, work: Path) -> dict:
    shutil.copyfile(fixture, work / fixture.name)
    build = run_verilator.execute([str(artifacts["verilator"]), "--binary", "--timing", "-Wno-fatal",
                                   "--top-module", fixture.stem, "--prefix", "Vmailbox", fixture.name],
                                  120, cwd=str(work))
    if build.returncode:
        raise ValueError(f"Verilator build failed ({build.returncode})")
    commands = {
        "ghost": [artifacts["ghost"], *profile["arguments"], fixture.name],
        "verilator": [work / "obj_dir" / "Vmailbox"],
    }
    expected = suite_results.expected_output(fixture).splitlines()
    trials = {tool: {mode: measure(command, profile if tool == "ghost" else None, bound, expected, work)
                     for mode, bound in BOUNDS.items()} for tool, command in commands.items()}
    return {"build_exit": build.returncode, "trials": trials,
            "pass": all(result["pass"] for tool in trials.values() for result in tool.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", type=Path, required=True)
    parser.add_argument("--verilator", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    artifacts = {"ghost": args.ghost.resolve(), "verilator": args.verilator.absolute()}
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("Ghost and Verilator executables are required")
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    verilator_runner = suite_results.runner_digest("verilator")
    hashes = {name: digest(path) for name, path in artifacts.items()}
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = observe(artifacts, profile, fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Mailbox observation stopped ({error}).\n")
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("ghost") or inputs != suite_results.fingerprints([fixture])
            or verilator_runner != suite_results.runner_digest("verilator") or profile_bytes != args.profile.read_bytes()):
        parser.exit(2, "Tools or inputs changed during qualification.\n")

    version = f"private build {hashes['ghost'][:12]}"
    config = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
              "verilator_version": suite_results.tool_version([str(artifacts["verilator"]), "--version"]),
              "verilator_runner_sha256": verilator_runner, "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    verdict = ("pass", "") if result["pass"] else ("fail", "mailbox control or negative-bound entry observation differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=config, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": config, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **result}}}, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], CASE)
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

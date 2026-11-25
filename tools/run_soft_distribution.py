#!/usr/bin/env python3
"""Measure whether discarding an earlier soft equality preserves soft dist."""

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


PROFILE = "ghost-soft-distribution-weights"
CHECKER = "tools/run_soft_distribution.py"
CASE = "ch18/test_disable_soft_preserves_distribution_weights"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
NAMES = ("retained", "discarded", "baseline")
DRAWS = 512
SEEDS = (1, 73)
# Each interval excludes less than 3e-8 of the corresponding ideal binomial
# distribution. It is a regression screen, not an equality test of distributions.
WEIGHTS = {"equal": (1, 192, 320), "unequal": (7, 25, 108)}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    result = hashlib.sha256()
    for name in (CHECKER, "tools/run_ghost.py", "tools/run_verilator.py",
                 "tools/suite_results.py", "tools/normalize_output.py"):
        result.update(name.encode() + b"\0")
        result.update(bytes.fromhex(digest(suite_results.ROOT / name)))
    return result.hexdigest()


def evaluate(output: list[str], expected: list[str], mode: str) -> dict:
    weight, minimum, maximum = WEIGHTS[mode]
    if len(output) != 8 or output[4] != f"weight for 8={weight}":
        return {"pass": False, "output": output, "reason": "missing counts or wrong weight"}
    counts = {}
    for name, line in zip(NAMES, output[5:], strict=True):
        match = re.fullmatch(rf"{name}: (\d+) (\d+)", line)
        if match is None:
            return {"pass": False, "output": output, "reason": "malformed counts"}
        counts[name] = [int(value) for value in match.groups()]

    retained, discarded, baseline = (counts[name] for name in NAMES)
    checks = (
        retained == [DRAWS, 0],
        minimum <= discarded[0] <= maximum and sum(discarded) == DRAWS,
        minimum <= baseline[0] <= maximum and sum(baseline) == DRAWS,
    )
    outside = DRAWS * len(NAMES) - sum(sum(pair) for pair in counts.values())
    recomputed = [f"{label}={int(check)}" for label, check in
                  zip(("retained equality", "discarded weights", "baseline weights"), checks, strict=True)]
    recomputed.append(f"unexpected={outside}")
    agrees = outside >= 0 and all(sum(pair) <= DRAWS for pair in counts.values()) and output[:4] == recomputed
    return {"pass": agrees and recomputed == expected, "counts": counts, "unexpected": outside,
            "weight_for_8": weight, "expected_fives": [minimum, maximum], "transcript_matches_counts": agrees,
            "verdicts": dict(zip(("retained_equality", "discarded_weights", "baseline_weights"), checks, strict=True)),
            "output": output}


def run_mode(executable: Path, fixture: Path, mode: str, profile: dict | None) -> dict:
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        shutil.copyfile(fixture, work / fixture.name)
        expected = suite_results.expected_output(fixture).splitlines()
        defines = ["+define+UNEQUAL_WEIGHTS"] if mode == "unequal" else []
        if profile:
            command = [str(executable), *profile["arguments"], *defines, "-top", fixture.stem, fixture.name]
            environment = {**os.environ, **profile["environment"]}
        else:
            command = [str(executable), "--binary", "--timing", "-Wno-fatal", "-Wno-lint", "-Wno-style",
                       "--top-module", fixture.stem, "-Mdir", "obj", "--prefix", "Vsample",
                       *defines, fixture.name]
            try:
                build = run_verilator.execute(command, run_verilator.BUILD_TIMEOUT, cwd=directory)
            except subprocess.TimeoutExpired:
                return {"pass": False, "reason": "build timed out", "trials": {}}
            if build.returncode != 0:
                errors = [line for line in build.stderr.splitlines() if line.startswith("%Error")]
                return {"pass": False, "reason": "build failed", "returncode": build.returncode,
                        "errors": [run_verilator.neutral(line, directory) for line in errors], "trials": {}}
            command = [str(work / "obj" / "Vsample")]
            environment = None
        trials = {}
        for seed in SEEDS:
            simulator_seed = [] if profile else [f"+verilator+seed+{seed}"]
            options = [*command, *simulator_seed, f"+draw_seed={seed}", "+observe_counts"]
            try:
                run = subprocess.run(options, cwd=work, env=environment, capture_output=True,
                                     text=True, errors="replace", timeout=run_verilator.RUN_TIMEOUT)
            except subprocess.TimeoutExpired:
                trials[seed] = {"pass": False, "reason": "simulation timed out"}
                continue
            output = (run_ghost.normalize(run.stdout, profile).splitlines() if profile else
                      [line for line in run.stdout.splitlines() if not run_verilator.BANNER.match(line)])
            observation = evaluate(output, expected, mode)
            observation["returncode"] = run.returncode
            observation["pass"] &= run.returncode == 0
            if run.returncode:
                observation["stderr"] = run_verilator.neutral(run.stderr, directory).splitlines()
            trials[seed] = observation
        return {"pass": all(trial["pass"] for trial in trials.values()), "trials": trials}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=("ghost", "verilator"), required=True)
    parser.add_argument("--executable", required=True)
    parser.add_argument("--observations", required=True, type=Path)
    parser.add_argument("--profile", type=Path, help="Ghost runtime profile")
    parser.add_argument("--results", type=Path, help="Ghost coverage snapshot")
    args = parser.parse_args()
    program = shutil.which(args.executable)
    if program is None:
        parser.error("simulator executable is unavailable")
    executable = Path(program).resolve()
    if args.tool == "ghost" and (not args.profile or not args.results):
        parser.error("Ghost requires both --profile and --results")
    profile_bytes = args.profile.read_bytes() if args.tool == "ghost" else None
    profile = json.loads(profile_bytes) if profile_bytes is not None else None
    if profile is not None and "--lrm-strict" not in profile["arguments"]:
        parser.error("Ghost requires --lrm-strict")
    binaries = {"executable": executable}
    if args.tool == "verilator":
        backend = shutil.which(os.environ.get("VERILATOR_BIN", str(executable.with_name("verilator_bin"))))
        if backend:
            binaries["compiler"] = Path(backend).resolve()
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    version = (f"private build {binary_hashes['executable'][:12]}" if profile else
               suite_results.tool_version([str(executable), "--version"]))
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest(args.tool)
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    modes = {name: run_mode(executable, fixture, name, profile) for name in WEIGHTS}
    if (any(digest(path) != binary_hashes[name] for name, path in binaries.items())
            or checker_digest() != checker_hash or runner_hash != suite_results.runner_digest(args.tool)
            or suite_results.fingerprints([fixture]) != inputs
            or (profile and args.profile.read_bytes() != profile_bytes)):
        parser.exit(2, "Executable, checker, profile or test inputs changed during qualification.\n")
    configuration = {"checker_sha256": checker_hash, "binary_sha256": binary_hashes, "seeds": list(SEEDS)}
    passed = all(mode["pass"] for mode in modes.values())
    if profile:
        configuration.update(evidence_profile=PROFILE, profile_sha256=hashlib.sha256(profile_bytes).hexdigest())
        status = ("pass", "") if passed else ("fail", "equal or unequal soft distribution differed")
        suite_results.write(args.results, "ghost", "Ghost", version, {CASE: status}, inputs=inputs,
                            configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"tool": args.tool, "version": version, "configuration": configuration,
        "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "pass": passed, "modes": modes}}},
        indent=2) + "\n", encoding="utf-8")
    for name, mode in modes.items():
        for seed, trial in mode["trials"].items():
            print(f"{version} {name} seed={seed} counts={trial.get('counts')} pass={trial['pass']}")
        if not mode["trials"]:
            print(f"{version} {name}: {mode['reason']}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

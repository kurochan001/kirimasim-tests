#!/usr/bin/env python3
"""Replay pure controls and record side effects in coverage bin filters."""

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


PROFILE = "coverage-bin-effects"
CHECKER = "tools/run_coverage_bin_effects.py"
TARGETS = {
    "ch19/test_cg_point_with_side_effect_observation": "point",
    "ch19/test_cg_cross_with_side_effect_observation": "cross",
}
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in TARGETS}
MODES = {"pure": (), "effects": ("OBSERVE_BIN_EFFECTS",)}
SEEDS = (1, 73)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def record_run(result, output: list[str], expected: list[str], target: str, mode: str) -> dict:
    observation = {"run_exit": result.returncode, "stdout": output, "checks_match": False}
    if result.returncode != 0:
        return observation
    if mode == "pure":
        observation["checks_match"] = output == expected
        return observation
    if len(output) == len(expected) + 1 and output[:-1] == expected:
        effect = re.fullmatch(rf"effect {target}=(-?\d+|[+-]?(?:nan|inf)) evaluations=(-?\d+|[xz])",
                              output[-1], flags=re.IGNORECASE)
        if effect is not None:
            observation.update(checks_match=True, observed_percent=effect[1], observed_counter=effect[2])
    return observation


def verilator_observations(exe: str, fixture: Path, work: Path, target: str) -> dict:
    expected = suite_results.expected_output(fixture).splitlines()
    observations = {}
    for mode, defines in MODES.items():
        obj = work / mode
        build = run_verilator.execute([
            exe, "--binary", "--timing", "--coverage-user", "-Wno-fatal",
            "--top-module", fixture.stem, "--prefix", "Vt", "--Mdir", str(obj),
            *("-D" + define for define in defines), str(fixture),
        ], run_verilator.BUILD_TIMEOUT, cwd=str(work))
        warnings = sorted(set(re.findall(r"^%Warning-([A-Z0-9_]+):", build.stderr, re.M)))
        runs = []
        if build.returncode == 0:
            for seed in SEEDS:
                result = run_verilator.execute([
                    str(obj / "Vt"), "+verilator+rand+reset+2", f"+verilator+seed+{seed}",
                ], run_verilator.RUN_TIMEOUT, cwd=str(work))
                lines = [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]
                runs.append({"seed": seed, **record_run(result, lines, expected, target, mode)})
        observations[mode] = {"build_exit": build.returncode, "warning_codes": warnings, "runs": runs,
                              "pass": len(runs) == len(SEEDS) and all(run["checks_match"] for run in runs)}
    return observations


def ghost_observations(exe: str, fixture: Path, profile: dict, work: Path, target: str) -> dict:
    expected = suite_results.expected_output(fixture).splitlines()
    observations = {}
    for mode, defines in MODES.items():
        runs = []
        for attempt in (1, 2):
            result = subprocess.run([exe, *profile["arguments"], *("+define+" + d for d in defines), str(fixture)],
                                    cwd=work, env={**os.environ, **profile["environment"]},
                                    capture_output=True, text=True, errors="replace", timeout=30)
            lines = run_ghost.normalize(result.stdout, profile).splitlines()
            runs.append({"attempt": attempt, **record_run(result, lines, expected, target, mode)})
        observations[mode] = {"runs": runs, "pass": all(run["checks_match"] for run in runs)}
    return observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--ghost")
    parser.add_argument("--ghost-profile", type=Path)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    verilator = shutil.which(args.verilator)
    if verilator is None:
        parser.error("Verilator executable is required")
    if bool(args.ghost) != bool(args.ghost_profile):
        parser.error("provide both --ghost and --ghost-profile to also run Ghost")
    binaries = {"verilator": Path(verilator).absolute()}
    backend = binaries["verilator"].resolve().with_name("verilator_bin")
    if backend.is_file():
        binaries["verilator_backend"] = backend
    profile = None
    if args.ghost:
        ghost = shutil.which(args.ghost)
        if ghost is None:
            parser.error("Ghost executable is required")
        binaries["ghost"] = Path(ghost).absolute()
        binaries["ghost_profile"] = args.ghost_profile
        profile = json.loads(args.ghost_profile.read_text(encoding="utf-8"))
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
    fingerprints = {name: digest(path) for name, path in binaries.items()}
    inputs = suite_results.fingerprints(list(CASES.values()))
    version = suite_results.tool_version([verilator, "--version"])
    versions = {"verilator": version}
    if profile is not None:
        versions["ghost"] = f"private build {fingerprints['ghost'][:12]}"
    checker, runner = checker_digest(), suite_results.runner_digest("verilator")
    observations, verdicts = {}, {}
    try:
        for case, fixture in CASES.items():
            with tempfile.TemporaryDirectory() as directory:
                work = Path(directory)
                target = TARGETS[case]
                reference = verilator_observations(str(binaries["verilator"]), fixture, work, target)
                trial = {"inputs_sha256": inputs[case], "verilator": reference}
                if profile is not None:
                    trial["ghost"] = ghost_observations(str(binaries["ghost"]), fixture, profile, work, target)
                observations[case] = trial
                verdicts[case] = (("pass", "") if all(mode["pass"] for mode in reference.values())
                                  else ("fail", "pure control or observation was incomplete"))
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Coverage qualification stopped with {type(error).__name__}.\n")
    if (fingerprints != {name: digest(path) for name, path in binaries.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Tools, profile, checker or fixtures changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker,
                     "binary_sha256": {name: val for name, val in fingerprints.items() if name.startswith("verilator")},
                     "seeds": list(SEEDS)}
    suite_results.write(args.json, "verilator", "Verilator", version, verdicts,
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"versions": versions, "configuration": configuration,
        "artifact_sha256": fingerprints, "runner_sha256": runner, "tests": observations}, indent=2) + "\n",
        encoding="utf-8")
    for case, test in observations.items():
        for tool in versions:
            lines = [run["stdout"][-1] for run in test[tool]["effects"]["runs"] if run["checks_match"]]
            print(f"{case} {tool} {lines}")
    return int(any(verdict[0] != "pass" for verdict in verdicts.values()) or profile is not None
               and any(not mode["pass"] for test in observations.values() for mode in test["ghost"].values()))


if __name__ == "__main__":
    raise SystemExit(main())

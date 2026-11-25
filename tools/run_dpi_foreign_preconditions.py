#!/usr/bin/env python3
"""Replay ordinary controls and isolated foreign DPI precondition violations."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import run_verilator
import suite_results


CHECKER = "tools/run_dpi_foreign_preconditions.py"
PROFILE = "dpi-foreign-preconditions"
CASE = "ch35/test_dpi_foreign_precondition_observations"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
C_VARIANTS = {"normal": (), "input": ("-DDPI_ALTER_INPUT",), "pure": ("-DDPI_ALTER_PURE",),
              "context": ("-DDPI_ALTER_CONTEXT",)}
TRIALS = {"normal": ("normal", ()), "context_control": ("normal", ("+positive_context",)),
          "input": ("input", ()), "pure": ("pure", ()), "context": ("context", ()),
          "context_after_valid_call": ("context", ("+positive_context",))}
POSITIVE_CONTEXT = ("SV export visited input=13", "SV context=113")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def record(result, expected: list[str], mode: str) -> dict:
    lines = [line for line in result.stdout.splitlines() if line.startswith(("C ", "SV "))]
    diagnostic = run_ghost.ANSI.sub("", result.stdout + "\n" + result.stderr)
    diagnostics = [line for line in diagnostic.splitlines() if "exported_value" in line and "scope" in line.lower()]
    if mode == "normal":
        reached = result.returncode == 0 and lines == expected
    elif mode == "context_control":
        reached = result.returncode == 0 and lines == [*expected[:3], *POSITIVE_CONTEXT, expected[3]]
    else:
        # The restriction violation has an observable entry marker. Its subsequent result
        # belongs to this run and is left as an observation.
        prefixes = {
            "input": ["C input write requested"],
            "pure": [*expected[:2], "C pure state changed"],
            "context": [*expected[:3], "C noncontext export requested"],
            "context_after_valid_call": [*expected[:3], *POSITIVE_CONTEXT, "C noncontext export requested"],
        }
        prefix = prefixes[mode]
        reached = lines[:len(prefix)] == prefix
    return {"exit": result.returncode, "stdout": lines, "scope_diagnostics": diagnostics,
            "recorded": reached}


def verilator_observations(exe: Path, fixture: Path, work: Path, expected: list[str]) -> dict:
    base = [str(exe), "--timing", "-Wno-fatal", "--prefix", "Vt", "--top-module", fixture.stem]
    hdl = run_verilator.execute([*base, "--cc", "--Mdir", str(work / "hdl"), str(fixture)],
                                 run_verilator.BUILD_TIMEOUT, cwd=str(work))
    builds = {}
    for variant, flags in C_VARIANTS.items():
        options = [option for flag in flags for option in ("-CFLAGS", flag)]
        compile_result = run_verilator.execute([
            *base, "--binary", "--Mdir", str(work / variant), *options, str(fixture),
            str(fixture.with_suffix(".cpp")),
        ], run_verilator.BUILD_TIMEOUT, cwd=str(work))
        builds[variant] = compile_result.returncode
    trials = {}
    for mode, (variant, arguments) in TRIALS.items():
        if builds[variant] == 0:
            result = run_verilator.execute([str(work / variant / "Vt"), *arguments],
                                           run_verilator.RUN_TIMEOUT, cwd=str(work))
            trials[mode] = record(result, expected, mode)
    return {"hdl_only_exit": hdl.returncode, "builds": builds, "trials": trials}


def ghost_observations(tools: dict[str, Path], include: Path, fixture: Path, profile: dict,
                       work: Path, expected: list[str]) -> dict:
    source = fixture.with_suffix(".cpp")
    base = [str(tools["ghost"]), *profile["arguments"]]
    environment = {**os.environ, **profile["environment"]}
    hdl = subprocess.run([*base, "--compile-only", str(fixture)], cwd=work, env=environment,
                         capture_output=True, timeout=30)
    options = ("-undefined", "dynamic_lookup") if sys.platform == "darwin" else ()
    builds = {}
    for variant, flags in C_VARIANTS.items():
        compile_result = subprocess.run([
            str(tools["cxx"]), "-std=c++20", "-shared", "-fPIC", *options, *flags, f"-I{include}",
            str(source), "-o", str(work / (variant + ".so")),
        ], cwd=work, capture_output=True, timeout=30)
        builds[variant] = compile_result.returncode
    trials = {}
    for mode, (variant, arguments) in TRIALS.items():
        if builds[variant] == 0:
            result = subprocess.run([*base, "--lib", str(work / (variant + ".so")), str(fixture), *arguments],
                                    cwd=work, env=environment, capture_output=True,
                                    text=True, errors="replace", timeout=30)
            trials[mode] = record(result, expected, mode)
    return {"hdl_only_exit": hdl.returncode, "builds": builds, "trials": trials}


def complete(result: dict) -> bool:
    return (result["hdl_only_exit"] == 0 and set(result["trials"]) == set(TRIALS)
            and all(trial["recorded"] for trial in result["trials"].values()))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--ghost")
    parser.add_argument("--include", type=Path)
    parser.add_argument("--profile", type=Path)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    if any((args.ghost, args.include, args.profile)) and not all((args.ghost, args.include, args.profile)):
        parser.error("provide --ghost, --include and --profile together")
    programs = {"verilator": args.verilator}
    if args.ghost:
        programs.update(ghost=args.ghost, cxx=os.environ.get("CXX", "c++"))
    executables = {name: shutil.which(program) for name, program in programs.items()}
    if not all(executables.values()):
        parser.error("a simulator or C++ compiler is unavailable")
    tools = {name: Path(exe).absolute() for name, exe in executables.items()}
    launcher = tools["verilator"].resolve()
    backend = Path(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    if backend.is_file():
        tools["verilator_backend"] = backend.resolve()
    profile = None
    if args.ghost:
        include = args.include.resolve()
        tools.update(profile=args.profile, svdpi=include / "svdpi.h")
        if not all(path.is_file() for path in tools.values()):
            parser.error("the Ghost profile and DPI header are required")
        profile = json.loads(args.profile.read_text(encoding="utf-8"))
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
    hashes = {name: digest(path) for name, path in tools.items()}
    checker, runner = checker_digest(), suite_results.runner_digest("verilator")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    expected = suite_results.expected_output(fixture).splitlines()
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            observations = {"verilator": verilator_observations(tools["verilator"], fixture, work, expected)}
            if profile is not None:
                observations["ghost"] = ghost_observations(tools, include, fixture, profile, work, expected)
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"DPI precondition qualification stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("verilator") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools, checker, profile or fixture changed during qualification.\n")
    version = suite_results.tool_version([str(tools["verilator"]), "--version"])
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker,
                     "artifact_sha256": {name: value for name, value in hashes.items() if name.startswith("verilator")}}
    passed = complete(observations["verilator"])
    verdict = ("pass", "") if passed else ("fail", "DPI controls or precondition observations incomplete")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "artifact_sha256": hashes, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observations}}}, indent=2) + "\n", encoding="utf-8")
    for tool, observation in observations.items():
        print(tool, observation)
    return int(any(not complete(observation) for observation in observations.values()))


if __name__ == "__main__":
    raise SystemExit(main())

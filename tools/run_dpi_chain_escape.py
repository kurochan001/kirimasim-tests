#!/usr/bin/env python3
"""Compare normal DPI context restoration with an observed nonlocal C return."""

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


PROFILE = "dpi-chain-escape"
CHECKER = "tools/run_dpi_chain_escape.py"
CASE = "ch35/test_dpi_context_chain_escape_observation"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
MODES = {"normal": (), "escape": ("+escape",)}
LANDING = "C landing reached"
LANDING_EXIT = 77


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def observe_run(result, output: list[str], expected: list[str], mode: str) -> dict:
    if mode == "escape":
        # The C application emits the marker and exits at its landing branch.
        # This qualification describes the observed route through this fixture.
        matches = result.returncode == LANDING_EXIT and output == [*expected[:3], LANDING]
    else:
        matches = result.returncode == 0 and output == expected
    return {"exit": result.returncode, "stdout": output, "matches_observation": matches}


def ghost_trials(tools: dict[str, Path], fixture: Path, profile: dict, include: Path, work: Path) -> dict:
    library = work / "chain.so"
    flags = ("-undefined", "dynamic_lookup") if sys.platform == "darwin" else ()
    build = subprocess.run([str(tools["cc"]), "-shared", "-fPIC", *flags, f"-I{include}",
                            str(fixture.with_suffix(".c")), "-o", str(library)],
                           cwd=work, capture_output=True, timeout=30)
    trials = {}
    expected = suite_results.expected_output(fixture).splitlines()
    if build.returncode == 0:
        for mode, arguments in MODES.items():
            result = subprocess.run([str(tools["ghost"]), *profile["arguments"], "--lib", str(library),
                                     str(fixture), *arguments], cwd=work, capture_output=True,
                                    env={**os.environ, **profile["environment"]}, text=True,
                                    errors="replace", timeout=30)
            output = run_ghost.normalize(result.stdout, profile).splitlines()
            trials[mode] = observe_run(result, output, expected, mode)
    return {"compile_exit": build.returncode, "trials": trials}


def verilator_trials(verilator: Path, fixture: Path, work: Path) -> dict:
    obj = work / "obj"
    build = run_verilator.execute([str(verilator), "--binary", "--timing", "-Wno-fatal", "--prefix", "Vt",
                                    "--top-module", fixture.stem, "--Mdir", str(obj), str(fixture),
                                    str(fixture.with_suffix(".c"))], run_verilator.BUILD_TIMEOUT, cwd=str(work))
    trials = {}
    expected = suite_results.expected_output(fixture).splitlines()
    if build.returncode == 0:
        for mode, arguments in MODES.items():
            result = run_verilator.execute([str(obj / "Vt"), *arguments], run_verilator.RUN_TIMEOUT, cwd=str(work))
            output = [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]
            trials[mode] = observe_run(result, output, expected, mode)
    return {"compile_exit": build.returncode, "trials": trials}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--verilator")
    parser.add_argument("--include", required=True, type=Path)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    programs = {"ghost": args.ghost, "cc": os.environ.get("CC", "cc")}
    if args.verilator:
        programs["verilator"] = args.verilator
    executables = {name: shutil.which(program) for name, program in programs.items()}
    if not all(executables.values()):
        parser.error("a simulator or the C compiler is unavailable")
    tools = {name: Path(path).absolute() for name, path in executables.items()}
    if args.verilator:
        launcher = tools["verilator"].resolve()
        backend = Path(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
        if backend.is_file():
            tools["verilator_backend"] = backend.resolve()
    include = args.include.resolve()
    tools.update(profile=args.profile, svdpi=include / "svdpi.h")
    if not all(path.is_file() for path in tools.values()):
        parser.error("the Ghost profile or public DPI header is unavailable")
    hashes = {name: digest(path) for name, path in tools.items()}
    profile = json.loads(args.profile.read_text(encoding="utf-8"))
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            observed = {"ghost": ghost_trials(tools, fixture, profile, include, work)}
            if args.verilator:
                observed["verilator"] = verilator_trials(tools["verilator"], fixture, work)
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"DPI chain qualification stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("ghost") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools, checker, profile or fixture changed during qualification.\n")
    control = observed["ghost"]["trials"]
    matched = control.keys() == MODES.keys() and all(run["matches_observation"] for run in control.values())
    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "cc_version": suite_results.tool_version([str(tools["cc"]), "--version"])}
    if args.verilator:
        configuration["verilator_version"] = suite_results.tool_version([str(tools["verilator"]), "--version"])
    verdict = ("pass", "") if matched else ("fail", "DPI scope control or observed C landing differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], **observed}}}, indent=2) + "\n",
        encoding="utf-8")
    for tool, result in observed.items():
        print(tool, result)
    return int(not matched)


if __name__ == "__main__":
    raise SystemExit(main())

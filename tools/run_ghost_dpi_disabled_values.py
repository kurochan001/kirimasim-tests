#!/usr/bin/env python3
"""Observe values after disabled imports and verify the ordinary controls."""

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
import run_ghost_dpi_function_ack
import suite_results


PROFILE = "ghost-dpi-disabled-values"
CHECKER = "tools/run_ghost_dpi_disabled_values.py"
CASE = "ch35/test_dpi_disabled_transfer_values"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
KNOWN_WRAPPER = "function wrapper completed"
TRACKING = ("function caller supplied", "function caller existing")
ACK = "function acknowledged"
DISABLED_TASK = "C task cancel=1 export=1 disabled=1 out=201 io=182"
DISABLED_OUTER = "outer task cancel=1 export=1 disabled=1"
FUNCTION_WRITE = re.compile(r"C function cancel=1 disabled=([01]) out=202 io=193 value=203")
HDL_VALUE = r"(-?\d+|[xXzZ])"
PEERS = {"task": re.compile(rf"peer task={HDL_VALUE}/{HDL_VALUE}"),
         "function": re.compile(rf"peer function={HDL_VALUE}/{HDL_VALUE}/{HDL_VALUE}")}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    inputs = (CHECKER, run_ghost_dpi_function_ack.CHECKER)
    return hashlib.sha256("\n".join(digest(suite_results.ROOT / file) for file in inputs).encode()).hexdigest()


def record(exit_code: int, lines: list[str], expected: list[str], mode: str) -> dict:
    observation = {"exit": exit_code, "stdout": lines, "pass": False}
    if mode == "control":
        return {**observation, "pass": exit_code == 0 and lines == expected}
    controls = [line for line in lines if "cancel=0" in line or line.startswith(("task control=", "function control="))]
    function_flags = [match[1] == "1" for line in lines if (match := FUNCTION_WRITE.fullmatch(line))]
    tracking = [line for line in lines if line in TRACKING]
    peers = {name: [list(match.groups()) for line in lines if (match := pattern.fullmatch(line))]
             for name, pattern in PEERS.items()}
    other_workers = [line for line in lines if line in ("task worker continued", "function worker continued")]
    proper_function = len(function_flags) == 1 and lines.count(ACK) == int(function_flags[0])
    tracking_matches = (len(tracking) == 1 and function_flags == [True]) if mode == "tracked" else not tracking
    passed = (exit_code == 0 and controls == [line for line in expected if line != KNOWN_WRAPPER]
              and lines.count(DISABLED_TASK) == lines.count(DISABLED_OUTER) == 1
              and proper_function and tracking_matches and all(len(values) == 1 for values in peers.values())
              and not other_workers)
    return {**observation, "pass": passed, "function_disabled_flags": function_flags,
            "tracking": tracking, "acknowledgements": lines.count(ACK), "peer_values": peers,
            "continued_workers": other_workers, "wrapper_completions": lines.count(KNOWN_WRAPPER)}


def observe(tools: dict[str, Path], case: Path, profile: dict, include: Path, work: Path) -> dict:
    source = case.with_suffix(".cpp")
    compile_library = run_ghost_dpi_function_ack.compile_library
    libraries = {mode: compile_library(tools["cxx"], include, source, work, mode == "tracked")
                 for mode in ("native", "tracked")}
    expected = suite_results.expected_output(case).splitlines()
    trials = {}
    for mode in ("control", "native", "tracked"):
        library = libraries["tracked" if mode == "tracked" else "native"]
        plusargs = () if mode == "control" else ("+observe_disable",)
        result = subprocess.run([str(tools["ghost"]), *profile["arguments"], "--lib", str(library),
                                 str(case), *plusargs], cwd=work, env={**os.environ, **profile["environment"]},
                                capture_output=True, text=True, errors="replace", timeout=30)
        trials[mode] = record(result.returncode, run_ghost.normalize(result.stdout, profile).splitlines(), expected, mode)
    return trials


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    ghost, cxx = shutil.which(args.ghost), shutil.which(os.environ.get("CXX", "c++"))
    if not ghost or not cxx:
        parser.error("Ghost and a C++ compiler are required")
    include = args.include.resolve()
    tools = {"ghost": Path(ghost).absolute(), "cxx": Path(cxx).absolute(), "profile": args.profile,
             "svdpi": include / "svdpi.h", "function_frame_header": include / "sukimasim/dpi/dpi_disable_state.h"}
    if not all(path.is_file() for path in tools.values()):
        parser.error("the Ghost profile and DPI headers are required")
    hashes = {name: digest(path) for name, path in tools.items()}
    profile = json.loads(args.profile.read_text(encoding="utf-8"))
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            trials = observe(tools, fixture, profile, include, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"DPI disabled value qualification stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("ghost") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools, checker, profile or fixture changed during qualification.\n")
    passed = all(trial["pass"] for trial in trials.values())
    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "cxx_version": suite_results.tool_version([str(tools["cxx"]), "--version"])}
    verdict = ("pass", "") if passed else ("fail", "DPI controls or disabled-frame observations differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], "trials": trials}}}, indent=2) + "\n",
        encoding="utf-8")
    for mode, result in trials.items():
        print(mode, result)
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

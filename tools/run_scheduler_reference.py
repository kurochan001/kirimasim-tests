#!/usr/bin/env python3
"""Compare bounded SV scheduling traces with the choices in the reference model."""

import argparse
import hashlib
from itertools import permutations
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import run_ghost
import run_icarus
import run_verilator
import suite_results


CHECKER = "tools/run_scheduler_reference.py"
PROFILE = "icarus-scheduler-reference"
CASE = "ch4/test_reference_scheduler_trace_set"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
WRITES = {"control": (7,), "race": (3, 7), "reversed": (7, 3)}
NAMES = {"icarus": "Icarus Verilog", "ghost": "Ghost", "kirimasim": "kirimasim", "verilator": "Verilator"}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def reference_trace(active_writes: tuple[int, ...]) -> tuple[str, ...]:
    # Active drains before the #0 resumes. That continuation reads the last
    # write and captures it as the NBA RHS before overwriting the variable.
    winner = active_writes[-1]
    before_nba = f"inactive t=1 winner={winner} stage=0"
    stage, winner = winner, 9
    # The NBA update wakes the stage observer in Active. Its own NBA has to
    # drain before Postponed (and therefore before the next time slot).
    wakeup = f"wake t=1 stage={stage} winner={winner} settled=0"
    settled = stage + 10
    state = f"stage={stage} winner={winner} settled={settled}"
    return before_nba, wakeup, f"postponed t=1 {state}", f"next t=2 {state}"


def allowed_traces(mode: str) -> set[tuple[str, ...]]:
    return {reference_trace(order) for order in permutations(WRITES[mode])}


def observe(tool: str, binaries: dict[str, Path], profile: dict, fixture: Path, mode: str) -> dict:
    reverse = mode == "reversed"
    define = ["-DREVERSE_WRITERS"] if reverse else []
    plus_define = ["+define+REVERSE_WRITERS"] if reverse else []
    plusargs = ["+observe_race"] if mode != "control" else []
    environment = os.environ.copy()
    with tempfile.TemporaryDirectory() as directory:
        shutil.copyfile(fixture, Path(directory) / fixture.name)
        compiler = None
        if tool == "icarus":
            compiler = [str(binaries["iverilog"]), "-g2012", "-s", fixture.stem,
                        "-o", "design.vvp", *define, fixture.name]
            command = [str(binaries["vvp"]), "design.vvp", *plusargs]
        elif tool == "verilator":
            compiler = [str(binaries[tool]), "--binary", "--timing", "-Wno-fatal", "--top-module",
                        fixture.stem, "--prefix", "Vdesign", *define, fixture.name]
            command = ["obj_dir/Vdesign", *plusargs]
        elif tool == "ghost":
            environment.update(profile["environment"])
            command = [str(binaries[tool]), *profile["arguments"], *plus_define, fixture.name, *plusargs]
        else:
            command = [str(binaries[tool]), *plus_define, fixture.name, *plusargs]
        build_exit = None
        if compiler:
            execute = run_icarus.execute if tool == "icarus" else run_verilator.execute
            build = execute(compiler, 90, cwd=directory)
            build_exit = build.returncode
            if build_exit != 0:
                return {"build_exit": build_exit, "exit": None, "stdout": [], "matches_model": False}
        result = subprocess.run(command, cwd=directory, env=environment, capture_output=True,
                                text=True, errors="replace", timeout=20)
    output = result.stdout
    if tool == "ghost":
        output = run_ghost.normalize(output, profile)
    lines = [line for line in output.splitlines() if tool != "verilator" or not run_verilator.BANNER.match(line)]
    matches = result.returncode == 0 and tuple(lines) in allowed_traces(mode)
    return {"build_exit": build_exit, "exit": result.returncode, "stdout": lines, "matches_model": matches}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=NAMES, required=True)
    parser.add_argument("--simulator", type=Path, help="executable for Ghost, kirimasim, or Verilator")
    parser.add_argument("--iverilog-bin", type=Path, help="directory with iverilog and vvp")
    parser.add_argument("--profile", type=Path, help="Ghost strict runtime profile")
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    tool = args.tool
    if tool == "icarus":
        if args.iverilog_bin is None:
            parser.error("Icarus requires --iverilog-bin")
        binaries = {name: args.iverilog_bin.resolve() / name for name in ("iverilog", "vvp")}
    else:
        if args.simulator is None:
            parser.error(f"{tool} requires --simulator")
        binaries = {tool: args.simulator.absolute()}
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries.values()):
        parser.error("the required simulator executables are unavailable")
    if tool == "ghost" and args.profile is None:
        parser.error("Ghost requires --profile")
    profile_bytes = args.profile.read_bytes() if args.profile else b"{}"
    profile = json.loads(profile_bytes)
    if tool == "ghost" and "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")

    hashes = {name: digest(binary) for name, binary in binaries.items()}
    checksum, runner = checker_digest(), suite_results.runner_digest(tool)
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    if {tuple(suite_results.expected_output(fixture).splitlines())} != allowed_traces("control"):
        parser.exit(2, "The expected control disagrees with the reference model.\n")
    try:
        runs = {mode: observe(tool, binaries, profile, fixture, mode) for mode in WRITES}
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Scheduling observation stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(binary) for name, binary in binaries.items()}
            or checksum != checker_digest() or runner != suite_results.runner_digest(tool)
            or inputs != suite_results.fingerprints([fixture])
            or args.profile and profile_bytes != args.profile.read_bytes()):
        parser.exit(2, "Tool, checker, or inputs changed during qualification.\n")

    configuration = {"evidence_profile": PROFILE if tool == "icarus" else f"{tool}-scheduler-reference",
                     "checker_sha256": checksum, "artifact_sha256": hashes}
    if tool == "ghost":
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
        version = f"private build {hashes[tool][:12]}"
    elif tool == "icarus":
        version = suite_results.tool_version([str(binaries["iverilog"]), "-V"])
    else:
        version = suite_results.tool_version([str(binaries[tool]), "--version"])
    mismatches = [mode for mode, result in runs.items() if not result["matches_model"]]
    verdict = ("fail", f"traces outside the reference set: {', '.join(mismatches)}") if mismatches else ("pass", "")
    suite_results.write(args.json, tool, NAMES[tool], version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": verdict[0], "runs": runs,
                         "allowed": {mode: sorted(allowed_traces(mode)) for mode in WRITES}}},
    }, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], tool, CASE, verdict[1])
    return int(bool(mismatches))


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Check DPI output functions with different initialized storage at C entry."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import run_verilator
import suite_results


PROFILE = "verilator-dpi-output-initial"
CHECKER = "tools/run_dpi_output_initial.py"
CASE = "ch35/test_dpi_output_independent_of_initial_storage"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SYMBOL = "dpi_write_fresh_outputs"
SEEDS = (11, 19)
CALLER = {11: (901, 7.25), 19: (-502, 21.125)}
FRESH = {11: (35, 6.5), 19: (59, 10.5)}
REPLACEMENTS = {11: (-810, 201.25), 19: (407, -42.75)}
ENTRY = "DPI_OUTPUT_ENTRY "

LLDB_SCRIPT = """\
import json
from pathlib import Path
import struct
import lldb

recipe = json.loads(Path("recipe.json").read_text())
modify = False

def emit(data):
    print("DPI_OUTPUT_ENTRY " + json.dumps(data), flush=True)

def writable(process, address, size):
    region = lldb.SBMemoryRegionInfo()
    error = process.GetMemoryRegionInfo(address, region)
    return error.Success() and region.IsWritable() and address + size <= region.GetRegionEnd()

def observe(process, address, fmt, candidates, replacement):
    size = struct.calcsize(fmt)
    error = lldb.SBError()
    initial = process.ReadMemory(address, size, error)
    if not error.Success() or len(initial) != size:
        raise ValueError("formal buffer read failed")
    label = next((key for key, value in candidates.items()
                  if initial == struct.pack(fmt, value)), "other")
    if not modify:
        return label, False
    data = struct.pack(fmt, replacement)
    if process.WriteMemory(address, data, error) != size or not error.Success():
        raise ValueError("formal buffer write failed")
    check = process.ReadMemory(address, size, error)
    if not error.Success() or check != data or initial == data:
        raise ValueError("formal buffer did not change to the replacement")
    return label, True

def record(frame, location, internal_dict):
    process = frame.GetThread().GetProcess()
    target = process.GetTarget()
    arch = target.GetTriple().split("-")[0]
    registers = {
        "arm64": ("x0", "x1", "x2"), "arm64e": ("x0", "x1", "x2"),
        "aarch64": ("x0", "x1", "x2"), "x86_64": ("rdi", "rsi", "rdx"),
    }
    names = registers.get(arch)
    if not names or target.GetByteOrder() != lldb.eByteOrderLittle:
        emit({"problem": "unsupported DPI argument ABI"})
        return False
    seed, number, fraction = (frame.FindRegister(name).GetValueAsUnsigned() for name in names)
    seed &= 0xffffffff
    inputs = recipe.get(str(seed))
    if (not inputs or not number or not fraction or
            (number < fraction + 8 and fraction < number + 4) or
            not writable(process, number, 4) or not writable(process, fraction, 8)):
        emit({"problem": "invalid DPI formal buffer"})
        return False
    try:
        observed = [observe(process, address, fmt, candidates, replacement)
                    for address, fmt, candidates, replacement in zip(
                        (number, fraction), ("<i", "<d"), inputs["candidates"], inputs["replacements"])]
    except ValueError as error:
        emit({"problem": str(error)})
        return False
    emit({"seed": seed, "initial": [label for label, written in observed],
          "replacement_verified": [written for label, written in observed]})
    return False
"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    check = hashlib.sha256()
    for name in (CHECKER, "tools/run_ghost.py", "tools/run_verilator.py", "tools/suite_results.py",
                 "tools/normalize_output.py"):
        check.update(name.encode() + b"\0")
        check.update(bytes.fromhex(digest(suite_results.ROOT / name)))
    return check.hexdigest()


def recipe() -> dict:
    contents = {}
    for i, seed in enumerate(SEEDS):
        choices = [dict(caller=value, zero=0) for value in CALLER[seed]]
        if i:
            for options, previous in zip(choices, FRESH[SEEDS[i - 1]], strict=True):
                options["previous_output"] = previous
        contents[seed] = {"candidates": choices, "replacements": REPLACEMENTS[seed]}
    return contents


def matches(mode: str, entries: list[dict]) -> bool:
    modified = mode == "changed"
    return (tuple(entry.get("seed") for entry in entries) == SEEDS
            and all(entry.get("replacement_verified") == [modified, modified]
                    and len(entry.get("initial", [])) == 2
                    and all(label in ("caller", "zero", "previous_output", "other")
                            for label in entry["initial"]) for entry in entries))


def run_observations(binaries: dict[str, Path], fixture: Path, profile: dict | None) -> dict:
    source = suite_results.header(fixture)["dpi_c"].removeprefix("@")
    expected = suite_results.expected_output(fixture).splitlines()
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        shutil.copyfile(fixture, work / fixture.name)
        shutil.copyfile(fixture.parent / source, work / source)
        (work / "recipe.json").write_text(json.dumps(recipe()), encoding="utf-8")
        (work / "inspect_output.py").write_text(LLDB_SCRIPT, encoding="utf-8")
        simulator = str(binaries["simulator"])
        if profile:
            lookup = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
            build_command = [str(binaries["cc"]), "-g", "-shared", "-fPIC", *lookup, "-o", "output.so", source]
            command = [simulator, *profile["arguments"], "--lib", "output.so", "-top", fixture.stem, fixture.name]
            environment = {**os.environ, **profile["environment"]}
        else:
            build_command = [simulator, "--binary", "--timing", "-Wno-fatal", "-Wno-lint", "-Wno-style",
                             "--top-module", fixture.stem, "-Mdir", "obj", "--prefix", "Voutput",
                             fixture.name, source]
            command = [str(work / "obj" / "Voutput")]
            environment = None
        build = run_verilator.execute(build_command, run_verilator.BUILD_TIMEOUT, cwd=directory)
        if build.returncode != 0:
            return {"pass": False, "build_exit": build.returncode,
                    "diagnostics": run_verilator.neutral(build.stderr, directory).splitlines()[-12:]}

        trials = {}
        for mode in ("native", "changed"):
            lldb = [
                str(binaries["lldb"]), "--batch", "--no-lldbinit",
                "-o", "settings set target.disable-aslr false",
                "-o", "command script import inspect_output.py",
                "-o", f"script inspect_output.modify = {mode == 'changed'}",
                "-o", f"breakpoint set --skip-prologue false --name {SYMBOL}",
                "-o", "breakpoint command add -F inspect_output.record 1", "-o", "run", "--",
            ]
            result = subprocess.run([*lldb, *command], cwd=work, env=environment, capture_output=True,
                                    text=True, errors="replace", timeout=run_verilator.RUN_TIMEOUT)
            lines = result.stdout.splitlines()
            entries = [json.loads(line.removeprefix(ENTRY)) for line in lines if line.startswith(ENTRY)]
            exits = [int(match[1]) for line in lines
                     if (match := re.match(r"^Process \d+ exited with status = (-?\d+)(?: |$)", line))]
            stdout = [line for line in lines if line.startswith(("first value=", "second value="))]
            ok = result.returncode == 0 and exits == [0] and stdout == expected and matches(mode, entries)
            trials[mode] = {"pass": ok, "debugger_exit": result.returncode, "target_exits": exits,
                            "stdout": stdout, "formal_buffers": entries}
        return {"pass": all(trial["pass"] for trial in trials.values()), "trials": trials}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=("ghost", "verilator"), required=True)
    parser.add_argument("--executable", required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--profile", type=Path, help="Ghost runtime profile")
    parser.add_argument("--json", type=Path, help="Verilator behavioral coverage snapshot")
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    programs = {"simulator": args.executable, "lldb": args.lldb}
    if args.tool == "ghost":
        if not args.profile:
            parser.error("Ghost requires its runtime profile")
        programs["cc"] = os.environ.get("CC", "cc")
    elif not args.json:
        parser.error("Verilator requires --json")
    located = {name: shutil.which(path) for name, path in programs.items()}
    if None in located.values():
        parser.error("simulator, debugger and required compiler must be available")
    binaries = {name: Path(path).resolve() for name, path in located.items()}
    if args.tool == "verilator":
        backend = shutil.which(os.environ.get("VERILATOR_BIN",
                              str(binaries["simulator"].with_name("verilator_bin"))))
        if backend:
            binaries["backend"] = Path(backend).resolve()
    hashes = {name: digest(path) for name, path in binaries.items()}
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest(args.tool)
    profile_bytes = args.profile.read_bytes() if args.tool == "ghost" else None
    profile = json.loads(profile_bytes) if profile_bytes is not None else None
    version = (f"private build {hashes['simulator'][:12]}" if profile else
               suite_results.tool_version([str(binaries["simulator"]), "--version"]))
    debugger_version = suite_results.tool_version([str(binaries["lldb"]), "--version"])
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        observation = run_observations(binaries, fixture, profile)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        observation = {"pass": False, "error": type(error).__name__}
    if (hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest(args.tool)
            or inputs != suite_results.fingerprints([fixture])
            or (profile and args.profile.read_bytes() != profile_bytes)):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"checker_sha256": checker_hash, "binary_sha256": hashes, "debugger_version": debugger_version}
    if profile:
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
    else:
        configuration["evidence_profile"] = PROFILE
        status = ("pass", "") if observation["pass"] else ("fail", "DPI output storage observation differed")
        suite_results.write(args.json, "verilator", "Verilator", version, {CASE: status},
                            inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": args.tool, "version": version, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "replacements": REPLACEMENTS, **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    print(observation)
    return int(not observation["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

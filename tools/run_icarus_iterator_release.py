#!/usr/bin/env python3
"""Observe Icarus iterator cleanup without making an invalid VPI call."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_icarus
import suite_results


PROFILE = "icarus-iterator-release"
CHECKER = "tools/run_icarus_iterator_release.py"
CASE = "ch38/test_vpi_iterator_released_on_terminal_scan"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
MARKER = re.compile(r"^ITER_TEST (\w+)(?: (0x[0-9a-fA-F]+))?$")
CLEANUP = re.compile(r"^ITER_FREE (0x[0-9a-fA-F]+) (scan|other)$")
EXPECTED_EVENTS = [
    "early_open early",
    "drained_open drained",
    "explicit_release early",
    "cleanup early other",
    "explicit_done",
    "terminal_scan drained",
    "cleanup drained scan",
    "terminal_done",
]

LLDB_SCRIPT = """\
def record(frame, location, internal_dict):
    thread = frame.GetThread()
    arch = thread.GetProcess().GetTarget().GetTriple().split("-")[0]
    registers = {"arm64": "x0", "arm64e": "x0", "aarch64": "x0", "x86_64": "rdi"}
    register = registers.get(arch)
    if register is None:
        print("ITER_DEBUGGER unsupported target architecture", flush=True)
        return False
    address = frame.FindRegister(register).GetValueAsUnsigned()
    callers = tuple(thread.GetFrameAtIndex(i).GetFunctionName()
                    for i in range(1, min(thread.GetNumFrames(), 8)))
    if "check_iterators" not in callers:
        return False
    route = "scan" if "vpi_scan" in callers else "other"
    print(f"ITER_FREE {address:#x} {route}", flush=True)
    return False
"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def trace_events(lines: list[str]) -> list[str]:
    events = []
    handles = {}
    for line in lines:
        if marker := MARKER.fullmatch(line):
            phase, printed_address = marker.groups()
            address = int(printed_address, 16) if printed_address else None
            if phase in ("early_open", "drained_open") and address:
                role = phase.removesuffix("_open")
                if address in handles or role in handles.values():
                    raise ValueError("two live iterators were not distinct")
                handles[address] = role
            role = handles.get(address, "unrecognized")
            events.append(f"{phase} {role}" if address else phase)
        elif cleanup := CLEANUP.fullmatch(line):
            printed_address, route = cleanup.groups()
            if role := handles.get(int(printed_address, 16)):
                events.append(f"cleanup {role} {route}")
        elif line.startswith(("ITER_TEST ", "ITER_FREE ", "ITER_DEBUGGER ")):
            raise ValueError("malformed or unsupported debugger trace")
    return events


def observe(binaries: dict[str, Path], fixture: Path) -> dict:
    plugin = run_icarus.c_source(fixture, "vpi_c")
    if plugin is None:
        raise ValueError("fixture has no VPI application")
    expected = suite_results.expected_output(fixture).splitlines()
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        script = "inspect_iterator.py"
        (work / script).write_text(LLDB_SCRIPT, encoding="utf-8")
        shutil.copyfile(fixture, work / fixture.name)
        shutil.copyfile(plugin, work / plugin.name)
        for command, timeout in (
            ([binaries["iverilog-vpi"], "--name=app", plugin.name], run_icarus.VPI_BUILD_TIMEOUT),
            ([binaries["iverilog"], "-g2012", "-s", fixture.stem, "-o", "design.vvp", fixture.name],
             run_icarus.COMPILE_TIMEOUT),
        ):
            build = run_icarus.execute(list(map(str, command)), timeout, cwd=directory)
            if build.returncode != 0:
                return {"pass": False, "build_exit": build.returncode,
                        "diagnostics": run_icarus.neutral(build.stderr, directory).splitlines()}
        command = [
            str(binaries["lldb"]), "--batch", "--no-lldbinit",
            "-o", "settings set target.disable-aslr false",
            "-o", f"command script import {script}",
            "-o", "breakpoint set --skip-prologue false --name iterator_free_object",
            "-o", "breakpoint command add -F inspect_iterator.record 1",
            "-o", "run", "--", str(binaries["vvp"]), "-M.", "-mapp",
            "design.vvp", "+trace_iterators",
        ]
        result = run_icarus.execute(command, run_icarus.RUN_TIMEOUT, cwd=directory)
        output = result.stdout.splitlines()
        events = trace_events(output)
        exits = [int(match[1]) for line in output
                 if (match := re.match(r"^Process \d+ exited with status = (-?\d+)(?: |$)", line))]
        summary = [line for line in output if line.startswith(("early release=", "drained modules="))]
        passed = result.returncode == 0 and exits == [0] and events == EXPECTED_EVENTS and summary == expected
        return {"pass": passed, "debugger_exit": result.returncode, "target_exits": exits,
                "events": events, "expected_events": EXPECTED_EVENTS, "stdout": summary}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    debugger = shutil.which(args.lldb)
    if debugger is None:
        parser.error("LLDB is unavailable")
    bindir = args.iverilog_bin.resolve()
    binaries = {name: bindir / name for name in ("iverilog", "vvp", "iverilog-vpi")}
    binaries["lldb"] = Path(debugger).resolve()
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries.values()):
        parser.error("all compiler, runtime and debugger executables must be available")
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    version = suite_results.tool_version([str(binaries["iverilog"]), "-V"])
    debugger_version = suite_results.tool_version([str(binaries["lldb"]), "--version"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("icarus")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        observation = observe(binaries, fixture)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        observation = {"pass": False, "error": type(error).__name__}
    if (binary_hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("icarus")
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "binary_sha256": binary_hashes, "debugger_version": debugger_version}
    status = ("pass", "") if observation["pass"] else ("fail", "iterator cleanup trace differed")
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, {CASE: status},
                        inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}}},
        indent=2) + "\n", encoding="utf-8")
    print(observation)
    return int(not observation["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

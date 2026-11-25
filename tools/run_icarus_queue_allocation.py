#!/usr/bin/env python3
"""Verify the stochastic queue's status when one allocator call fails."""

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


PROFILE = "icarus-queue-allocation-failure"
CHECKER = "tools/run_icarus_queue_allocation.py"
CASE = "ch20/test_stochastic_queue_creation_out_of_memory"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
TARGET_QUEUE = (17, 257)
ALLOCATORS = ("realloc", "malloc")
FAILURE_OUTPUT = [
    "existing create=0",
    "existing add=0",
    "target create=7",
    "target lookup=2",
    "target retry=0",
    "target after retry length=0 status=0",
    "existing job=71,83 status=0",
]
MODULE = re.compile(r'^:vpi_module "([^"\n]*/system\.vpi)";$', re.M)
QUEUE_CALL = re.compile(r"^QUEUE_CREATE (\d+) (\d+)$")
ALLOCATED = re.compile(r"^QUEUE_NULL (malloc|realloc) (\d+) (True|False)$")
EXITED = re.compile(r"^Process \d+ exited with status = (-?\d+)(?: |$)")

LLDB_SCRIPT = """\
def arguments(thread):
    arch = thread.GetProcess().GetTarget().GetTriple().split("-")[0]
    if arch in ("arm64", "arm64e", "aarch64"):
        return ("x0", "x1", "x2")
    if arch == "x86_64":
        return ("rdi", "rsi", "rdx")
    raise ValueError("unsupported argument registers")


def at_queue(frame, location, internal_dict):
    thread = frame.GetThread()
    first, _, third = arguments(thread)
    queue_id = frame.FindRegister(first).GetValueAsUnsigned() & 0xffffffff
    capacity = frame.FindRegister(third).GetValueAsUnsigned() & 0xffffffff
    print(f"QUEUE_CREATE {queue_id} {capacity}", flush=True)
    if (queue_id, capacity) == queue_to_fail:
        target = thread.GetProcess().GetTarget()
        bp = target.BreakpointCreateByName(allocator)
        bp.SetScriptCallbackFunction("queue_fault.fail_allocator")
    return False


def fail_allocator(frame, location, internal_dict):
    thread = frame.GetThread()
    caller = thread.GetFrameAtIndex(1)
    if caller.GetFunctionName() != "create_queue" or caller.GetModule().GetFileSpec().GetFilename() != "system.vpi":
        return False
    first, second, _ = arguments(thread)
    size = frame.FindRegister(first if allocator == "malloc" else second).GetValueAsUnsigned()
    if size == 0:
        return False
    target = thread.GetProcess().GetTarget()
    location.GetBreakpoint().SetEnabled(False)
    null_pointer = target.CreateValueFromExpression("failed_allocation", "(void *)0")
    error = thread.ReturnFromFrame(frame, null_pointer)
    print(f"QUEUE_NULL {allocator} {size} {error.Success()}", flush=True)
    return False
"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def observe_fault(binaries: dict, directory: str, allocator: str) -> dict:
    command = [
        str(binaries["lldb"]), "--batch", "--no-lldbinit",
        "-o", "settings set target.disable-aslr false",
        "-o", "command script import queue_fault.py",
        "-o", f"script queue_fault.allocator = {allocator!r}; queue_fault.queue_to_fail = {TARGET_QUEUE!r}",
        "-o", "breakpoint set --skip-prologue false --name create_queue --shlib system.vpi",
        "-o", "breakpoint command add -F queue_fault.at_queue 1",
        "-o", "run", "--", str(binaries["vvp"]), "design.vvp",
    ]
    result = run_icarus.execute(command, run_icarus.RUN_TIMEOUT, cwd=directory)
    lines = (result.stdout + "\n" + result.stderr).splitlines()
    queues, injections = [], []
    for line in lines:
        if match := QUEUE_CALL.fullmatch(line):
            queues.append((int(match[1]), int(match[2])))
        elif match := ALLOCATED.fullmatch(line):
            injections.append({"allocator": match[1], "bytes": int(match[2]), "returned_null": match[3] == "True",
                               "queue": queues[-1] if queues else None})
    exits = [int(match[1]) for line in lines if (match := EXITED.match(line))]
    output = [line for line in lines if line.startswith(("existing ", "target "))]
    qualified = (result.returncode == 0 and len(exits) == 1
                 and queues in ([(99, 3), TARGET_QUEUE], [(99, 3), TARGET_QUEUE, (17, 1)])
                 and len(injections) == 1 and injections[0]["allocator"] == allocator
                 and injections[0]["queue"] == TARGET_QUEUE
                 and injections[0]["bytes"] > 0 and injections[0]["returned_null"])
    return {
        "qualified": qualified,
        "pass": qualified and exits == [0] and output == FAILURE_OUTPUT and queues[-1] == (17, 1),
        "debugger_exit": result.returncode,
        "target_exits": exits,
        "queue_calls": queues,
        "allocator_calls": injections,
        "stdout": output,
        "diagnostics": [line for line in lines if "ran out of memory" in line],
    }


def observe(binaries: dict, fixture: Path) -> dict:
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        (work / "queue_fault.py").write_text(LLDB_SCRIPT, encoding="utf-8")
        shutil.copyfile(fixture, work / fixture.name)
        build = run_icarus.execute(
            [str(binaries["iverilog"]), "-g2012", "-s", fixture.stem, "-o", "design.vvp", fixture.name],
            run_icarus.COMPILE_TIMEOUT, cwd=directory,
        )
        if build.returncode != 0:
            raise ValueError(f"Icarus build failed\n{build.stderr}")
        modules = MODULE.findall((work / "design.vvp").read_text(encoding="utf-8"))
        if len(modules) != 1:
            raise ValueError("the selected system.vpi was not identifiable")
        module = Path(modules[0])
        module_hash = digest(module)
        control = run_icarus.execute([str(binaries["vvp"]), "design.vvp"], run_icarus.RUN_TIMEOUT, cwd=directory)
        expected = suite_results.expected_output(fixture).splitlines()
        output = control.stdout.splitlines()
        baseline = {"returncode": control.returncode, "stdout": output,
                    "pass": control.returncode == 0 and output == expected}
        trials = {allocator: observe_fault(binaries, directory, allocator) for allocator in ALLOCATORS}
        if module_hash != digest(module):
            raise ValueError("system.vpi changed during qualification")
        return {"system_vpi_sha256": module_hash, "control": baseline, "allocation_failures": trials,
                "expected_failure_stdout": FAILURE_OUTPUT}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    debugger = shutil.which(args.lldb)
    if not debugger:
        parser.error("LLDB is unavailable")
    binaries = {name: args.iverilog_bin.resolve() / name for name in ("iverilog", "vvp")}
    binaries["lldb"] = Path(debugger).resolve()
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries.values()):
        parser.error("Icarus compiler, runtime and debugger executables are required")
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("icarus")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    version = suite_results.tool_version([str(binaries["iverilog"]), "-V"])
    try:
        observation = observe(binaries, fixture)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (binary_hashes != {name: digest(path) for name, path in binaries.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("icarus") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Compiler, runtime, debugger, checker or fixture changed during qualification.\n")
    trials = observation["allocation_failures"]
    qualified = observation["control"]["pass"] and all(trial["qualified"] for trial in trials.values())
    if qualified:
        passed = all(trial["pass"] for trial in trials.values())
        status = ("pass", "") if passed else ("fail", "allocation failure did not return status 7 and leave the queue absent")
    else:
        status = ("unsupported", "control or targeted allocation failure could not be verified")
    config = {"evidence_profile": PROFILE, "checker_sha256": checksum, "binary_sha256": binary_hashes,
              "system_vpi_sha256": observation["system_vpi_sha256"],
              "debugger_version": suite_results.tool_version([str(binaries["lldb"]), "--version"])}
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, {CASE: status},
                        inputs=inputs, configuration=config, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "icarus", "version": version, "configuration": config, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": status[0], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    for allocator, trial in trials.items():
        print(allocator, trial)
    return {"pass": 0, "fail": 1, "unsupported": 2}[status[0]]


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Trace calls to vpi_release_handle while retaining an unrelated valid handle."""

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


CHECKER = "tools/run_icarus_live_handle_release.py"
PROFILE = "icarus-live-handle-release"
CASE = "ch38/test_vpi_release_only_live_handles"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
TARGET_EXIT = re.compile(r"^Process \d+ exited with status = (-?\d+)\b", re.M)
SHARING = re.compile(r"^handle sharing observed=([01])$")
TRACE_SCRIPT = """\
def count_release(frame, location, internal_dict):
    thread = frame.GetThread()
    arch = thread.GetProcess().GetTarget().GetTriple().split('-')[0]
    registers = {'arm64': 'x0', 'arm64e': 'x0', 'aarch64': 'x0', 'x86_64': 'rdi'}
    register = frame.FindRegister(registers[arch]) if arch in registers else None
    if register is None or not register.IsValid():
        print('VPI_RELEASE_CALL unavailable', flush=True)
    else:
        print(f'VPI_RELEASE_CALL nonnull={int(register.GetValueAsUnsigned() != 0)}', flush=True)
    return False
"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def observe(tools: dict[str, Path], fixture: Path, work: Path) -> dict:
    design = work / fixture.name
    application = work / fixture.with_suffix(".c").name
    shutil.copyfile(fixture, design)
    shutil.copyfile(fixture.with_suffix(".c"), application)
    builds = {}
    for name, argv in (
        ("vpi", [tools["iverilog-vpi"], "--name=app", application.name]),
        ("hdl", [tools["iverilog"], "-g2012", "-s", fixture.stem, "-o", "design.vvp", design.name]),
    ):
        result = run_icarus.execute(list(map(str, argv)), 30, cwd=str(work))
        builds[name] = result.returncode
        if result.returncode != 0:
            return {"builds": builds, "pass": False}

    script = work / "probe.py"
    script.write_text(TRACE_SCRIPT, encoding="utf-8")
    debug = run_icarus.execute([
        str(tools["lldb"]), "--batch", "--no-lldbinit", "-o", "settings set target.disable-aslr false",
        "-o", f"command script import {script}", "-o", "breakpoint set --skip-prologue false --name vpi_release_handle",
        "-o", "breakpoint command add -F probe.count_release 1", "-o", "run", "--",
        str(tools["vvp"]), "-M.", "-mapp", "design.vvp", "+observe_sharing",
    ], 60, cwd=str(work))
    lines = debug.stdout.splitlines()
    target_exits = [int(value) for value in TARGET_EXIT.findall(debug.stdout)]
    trace = [line for line in lines if line.startswith("VPI_RELEASE_CALL ")]
    sharing = [int(match[1]) for line in lines if (match := SHARING.fullmatch(line))]
    output = [line for line in lines if line.startswith(("hdl bus=", "early child=", "retained net="))]
    expected = suite_results.expected_output(fixture).splitlines()
    passed = (debug.returncode == 0 and target_exits == [0] and output == expected
              and trace == ["VPI_RELEASE_CALL nonnull=1"] and len(sharing) == 1)
    return {"builds": builds, "debugger_exit": debug.returncode, "target_exits": target_exits,
            "release_trace": trace, "sharing_observations": sharing, "stdout": output, "pass": passed}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    lldb = shutil.which(args.lldb)
    if lldb is None:
        parser.error("LLDB is required")
    bindir = args.iverilog_bin.resolve()
    tools = {name: bindir / name for name in ("iverilog", "iverilog-vpi", "vvp")}
    tools["lldb"] = Path(lldb).absolute()
    if not all(path.is_file() and os.access(path, os.X_OK) for path in tools.values()):
        parser.error("Icarus and LLDB executables are required")
    hashes = {name: digest(path) for name, path in tools.items()}
    checker, runner = checker_digest(), suite_results.runner_digest("icarus")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            outcome = observe(tools, fixture, Path(directory))
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI release qualification stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("icarus") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools, checker or fixture changed during qualification.\n")
    version = suite_results.tool_version([str(tools["iverilog"]), "-V"])
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "lldb_version": suite_results.tool_version([str(tools["lldb"]), "--version"])}
    verdict = ("pass", "") if outcome["pass"] else ("fail", "VPI release trace or retained handle observation differed")
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], **outcome}}}, indent=2) + "\n",
        encoding="utf-8")
    print(outcome)
    return int(not outcome["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

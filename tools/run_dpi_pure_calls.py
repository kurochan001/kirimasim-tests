#!/usr/bin/env python3
"""Observe legal pure DPI calls and two persistent-state misuse probes."""

import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from run_dpi_output_initial import digest
import run_verilator
import suite_results


PROFILES = {"ghost": "ghost-dpi-pure-calls", "verilator": "verilator-dpi-pure-calls"}
CHECKER = "tools/run_dpi_pure_calls.py"
CASE = "ch35/test_dpi_pure_call_optimization"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
PURE, LOCAL, GLOBAL = "dpi_pure_lookup", "dpi_local_history", "dpi_global_history"
MODES = {"unobserved": [], "visible": ["+define+OBSERVE_NET_VALUE"],
         "static_local": ["+define+OBSERVE_STATIC_LOCAL_AS_PURE"],
         "global": ["+define+OBSERVE_GLOBAL_AS_PURE"]}
MISUSE = {"static_local": LOCAL, "global": GLOBAL}
HIT = re.compile(r"^DPI_PURE_HIT (\w+) (\d+)$")
LLDB_SCRIPT = """\
def record(frame, location, internal_dict):
    arch = frame.GetThread().GetProcess().GetTarget().GetTriple().split("-")[0]
    register = {"arm64": "x0", "arm64e": "x0", "aarch64": "x0", "x86_64": "rdi"}.get(arch)
    if register is None:
        print("DPI_PURE_PROBE_ERROR unsupported target ABI", flush=True)
        return False
    seed = frame.FindRegister(register).GetValueAsUnsigned() & 0xffffffff
    print(f"DPI_PURE_HIT {frame.GetFunctionName()} {seed}", flush=True)
    return False
"""


def checker_digest() -> str:
    check = hashlib.sha256()
    for name in (CHECKER, "tools/run_dpi_output_initial.py", "tools/run_verilator.py", "tools/suite_results.py"):
        check.update(name.encode() + b"\0")
        check.update(bytes.fromhex(digest(suite_results.ROOT / name)))
    return check.hexdigest()


def counts_from(lines: list[str]) -> dict:
    counts = {name: Counter() for name in (PURE, LOCAL, GLOBAL)}
    for line in lines:
        if match := HIT.fullmatch(line):
            name, seed = match.groups()
            if name not in counts:
                raise ValueError("unexpected foreign symbol")
            counts[name][seed] += 1
        elif line.startswith(("DPI_PURE_HIT ", "DPI_PURE_PROBE_ERROR ")):
            raise ValueError("invalid debugger observation")
    return {name: dict(seeds) for name, seeds in counts.items()}


def matches(mode: str, counts: dict, stdout: list[str], expected: list[str], exits: list[int]) -> bool:
    pure = counts[PURE]
    if (not {"7", "11"} <= pure.keys() <= {"7", "11", "19", "29"}
            or any(count < 1 for count in pure.values())):
        return False
    if mode in MISUSE:
        # The changed declaration violates the foreign-code precondition.
        # Require evidence of reaching that call, without judging its result.
        seed = "3" if mode == "static_local" else "13"
        return (len(exits) == 1 and stdout[:2] == expected[:2]
                and counts[MISUSE[mode]].get(seed, 0) >= 1)
    visible = mode == "visible"
    lines = [*expected, "visible: 89"] if visible else expected
    return (exits == [0] and stdout == lines and counts[LOCAL] == {"3": 3}
            and counts[GLOBAL] == {"13": 3} and (not visible or pure.get("29", 0) >= 1))


def observe(binaries: dict[str, Path], fixture: Path, profile: dict | None, mode: str) -> dict:
    foreign = suite_results.header(fixture)["dpi_c"].removeprefix("@")
    expected = suite_results.expected_output(fixture).splitlines()
    defines = MODES[mode]
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        shutil.copyfile(fixture, work / fixture.name)
        shutil.copyfile(fixture.parent / foreign, work / foreign)
        (work / "inspect_pure.py").write_text(LLDB_SCRIPT, encoding="utf-8")
        simulator = str(binaries["simulator"])
        if profile:
            lookup = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
            build = [str(binaries["cc"]), "-g", "-shared", "-fPIC", *lookup, "-o", "pure.so", foreign]
            command = [simulator, *profile["arguments"], *defines, "--lib", "pure.so",
                       "-top", fixture.stem, fixture.name]
            environment = {**os.environ, **profile["environment"]}
        else:
            build = [simulator, "-O3", "--binary", "--timing", "-Wno-fatal", "-Wno-lint", "-Wno-style",
                     "--top-module", fixture.stem, "-Mdir", "obj", "--prefix", "Vpure",
                     *defines, fixture.name, foreign]
            command = [str(work / "obj" / "Vpure")]
            environment = None
        result = run_verilator.execute(build, run_verilator.BUILD_TIMEOUT, cwd=directory)
        if result.returncode != 0:
            return {"pass": False, "build_exit": result.returncode,
                    "diagnostics": run_verilator.neutral(result.stderr, directory).splitlines()[-12:]}
        lldb = [str(binaries["lldb"]), "--batch", "--no-lldbinit",
                "-o", "settings set target.disable-aslr false", "-o", "command script import inspect_pure.py",
                "-o", f"breakpoint set --skip-prologue false --name {PURE} --name {LOCAL} --name {GLOBAL}",
                "-o", "breakpoint command add -F inspect_pure.record 1", "-o", "run", "--"]
        result = subprocess.run([*lldb, *command], env=environment, cwd=work, capture_output=True,
                                text=True, errors="replace", timeout=run_verilator.RUN_TIMEOUT)
        lines = result.stdout.splitlines()
        counts = counts_from(lines)
        exits = [int(match[1]) for line in lines
                 if (match := re.match(r"^Process \d+ exited with status = (-?\d+)(?: |$)", line))]
        stdout = [line for line in lines if line.startswith(
            ("pure: ", "before history calls", "local history: ", "global history: ", "visible: "))]
        passed = result.returncode == 0 and matches(mode, counts, stdout, expected, exits)
        return {"pass": passed, "target_exits": exits, "debugger_exit": result.returncode,
                "stdout": stdout, "c_entries": counts}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=tuple(PROFILES), required=True)
    parser.add_argument("--executable", required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--profile", type=Path, help="Ghost runtime profile")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    programs = {"simulator": args.executable, "lldb": args.lldb}
    if args.tool == "ghost":
        if not args.profile:
            parser.error("Ghost requires its runtime profile")
        programs["cc"] = os.environ.get("CC", "cc")
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
    trials = {}
    for name in MODES:
        try:
            trials[name] = observe(binaries, fixture, profile, name)
        except (OSError, ValueError, subprocess.TimeoutExpired) as error:
            trials[name] = {"pass": False, "error": type(error).__name__}
        print(name, trials[name])
    if (hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest(args.tool)
            or inputs != suite_results.fingerprints([fixture])
            or (profile and args.profile.read_bytes() != profile_bytes)):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILES[args.tool], "checker_sha256": checker_hash,
                     "binary_sha256": hashes, "debugger_version": debugger_version}
    if profile:
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
    passed = all(trial["pass"] for trial in trials.values())
    status = ("pass", "") if passed else ("fail", "DPI pure call observation differed")
    suite_results.write(args.json, args.tool, "Ghost" if profile else "Verilator", version, {CASE: status},
                        inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": args.tool, "version": version, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "pass": passed, "trials": trials}},
    }, indent=2) + "\n", encoding="utf-8")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

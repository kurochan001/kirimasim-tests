#!/usr/bin/env python3
"""Verify native file and external-state operations in DPI purity probes."""

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

from run_dpi_output_initial import digest
import run_verilator
import suite_results


PROFILES = {"ghost": "ghost-dpi-pure-io", "verilator": "verilator-dpi-pure-io"}
CHECKER = "tools/run_dpi_pure_io.py"
FILES = "ch35/test_dpi_pure_file_access_observation"
EXTERNAL = "ch35/test_dpi_pure_external_state_observation"
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (FILES, EXTERNAL)}
FILE_OPERATIONS = ("entry", "tmpfile", "fputc", "fseek", "fgetc", "fclose")
OPERATIONS = {
    FILES: {"dpi_file_direct": FILE_OPERATIONS, "dpi_file_indirect": FILE_OPERATIONS},
    EXTERNAL: {
        "dpi_env_pid": ("entry", "getenv", "getpid", "setenv", "getenv", "unsetenv"),
        "dpi_shared_socket": ("entry", "mmap", "socketpair", "send", "recv", "close", "close", "munmap"),
    },
}
MODES = {"ordinary": [], "direct": ["+define+PROBE_DIRECT"], "indirect": ["+define+PROBE_INDIRECT"]}
HIT = re.compile(r"^DPI_IO (\w+) (\w+)$")

LLDB_SCRIPT = """\
import json
from pathlib import Path

operations = json.loads(Path("operations.json").read_text())

def symbol(frame):
    raw = frame.GetFunctionName() or ""
    return raw.lstrip(":_").split("(", 1)[0].split("$", 1)[0].split("@", 1)[0]

def record(frame, location, internal_dict):
    name = symbol(frame)
    if name in operations:
        print(f"DPI_IO {name} entry", flush=True)
        return False
    thread = frame.GetThread()
    for i in range(1, min(thread.GetNumFrames(), 12)):
        owner = symbol(thread.GetFrameAtIndex(i))
        if owner in operations:
            if name in operations[owner]:
                print(f"DPI_IO {owner} {name}", flush=True)
            break
    return False
"""


def checker_digest() -> str:
    check = hashlib.sha256()
    for name in (CHECKER, "tools/run_dpi_output_initial.py", "tools/run_verilator.py", "tools/suite_results.py"):
        check.update(name.encode() + b"\0")
        check.update(bytes.fromhex(digest(suite_results.ROOT / name)))
    return check.hexdigest()


def events_from(lines: list[str], operations: dict) -> dict:
    found = {owner: [] for owner in operations}
    for line in lines:
        if not line.startswith("DPI_IO "):
            continue
        match = HIT.fullmatch(line)
        if not match or match[1] not in operations or match[2] not in operations[match[1]]:
            raise ValueError("invalid debugger event")
        owner, event = match.groups()
        found[owner].append(event)
    return found


def matches(case: str, mode: str, found: dict, stdout: list[str], expected: list[str], exits: list[int]) -> bool:
    operations = OPERATIONS[case]
    if found.keys() != operations.keys():
        return False
    if mode == "ordinary":
        return (exits == [0] and stdout == expected
                and all(found[owner] == list(calls) * 2 for owner, calls in operations.items()))
    # These variants violate a foreign-code precondition. Record the result
    # without using it as an oracle for the language requirement.
    direct, indirect = operations
    owner = direct if mode == "direct" else indirect
    calls = list(operations[owner])
    return (len(exits) == 1 and stdout[:2] == [expected[0], f"{mode} declared pure"]
            and found[owner][:len(calls)] == calls)


def observe(binaries: dict[str, Path], case: str, profile: dict | None, mode: str) -> dict:
    fixture = CASES[case]
    foreign = suite_results.header(fixture)["dpi_c"].removeprefix("@")
    expected = suite_results.expected_output(fixture).splitlines()
    operations = OPERATIONS[case]
    defines = MODES[mode]
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        shutil.copyfile(fixture, work / fixture.name)
        shutil.copyfile(fixture.parent / foreign, work / foreign)
        (work / "inspect_io.py").write_text(LLDB_SCRIPT, encoding="utf-8")
        (work / "operations.json").write_text(json.dumps(operations), encoding="utf-8")
        simulator = str(binaries["simulator"])
        if profile:
            lookup = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
            build = [str(binaries["cc"]), "-g", "-O0", "-shared", "-fPIC", *lookup, "-o", "io.so", foreign]
            command = [simulator, *profile["arguments"], *defines, "--lib", "io.so",
                       "-top", fixture.stem, fixture.name]
            environment = {**os.environ, **profile["environment"]}
        else:
            build = [simulator, "--binary", "--timing", "-Wno-fatal", "-Wno-lint", "-Wno-style",
                     "-CFLAGS", "-g -fno-inline -fno-optimize-sibling-calls",
                     "--top-module", fixture.stem, "-Mdir", "obj",
                     "--prefix", "Vprobe", *defines, fixture.name, foreign]
            command = [str(work / "obj" / "Vprobe")]
            environment = None
        result = run_verilator.execute(build, run_verilator.BUILD_TIMEOUT, cwd=directory)
        if result.returncode != 0:
            return {"pass": False, "build_exit": result.returncode,
                    "diagnostics": run_verilator.neutral(result.stderr, directory).splitlines()[-12:]}
        symbols = sorted(set(operations) | {op for calls in operations.values() for op in calls if op != "entry"})
        locations = " ".join(f"--name {name}" for name in symbols)
        lldb = [str(binaries["lldb"]), "--batch", "--no-lldbinit",
                "-o", "settings set target.disable-aslr false", "-o", "command script import inspect_io.py",
                "-o", f"breakpoint set --skip-prologue false {locations}",
                "-o", "breakpoint command add -F inspect_io.record 1", "-o", "run", "--"]
        result = subprocess.run([*lldb, *command], env=environment, cwd=work, capture_output=True,
                                text=True, errors="replace", timeout=run_verilator.RUN_TIMEOUT)
        lines = result.stdout.splitlines()
        found = events_from(lines, operations)
        exits = [int(match[1]) for line in lines
                 if (match := re.match(r"^Process \d+ exited with status = (-?\d+)(?: |$)", line))]
        stdout = [line for line in lines if line == expected[0] or line.endswith("declared pure")
                  or line.startswith(("direct=", "env="))]
        passed = result.returncode == 0 and matches(case, mode, found, stdout, expected, exits)
        return {"pass": passed, "target_exits": exits, "debugger_exit": result.returncode,
                "stdout": stdout, "native_events": found}


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
    fixtures = list(CASES.values())
    inputs = suite_results.fingerprints(fixtures)
    verdicts, records = {}, {}
    for case in CASES:
        trials = {}
        for mode in MODES:
            try:
                trials[mode] = observe(binaries, case, profile, mode)
            except (OSError, ValueError, subprocess.TimeoutExpired) as error:
                trials[mode] = {"pass": False, "error": type(error).__name__}
            print(case, mode, trials[mode])
        passed = all(trial["pass"] for trial in trials.values())
        verdicts[case] = ("pass", "") if passed else ("fail", "DPI I/O observation differed")
        records[case] = {"inputs_sha256": inputs[case], "pass": passed, "trials": trials}
    if (hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest(args.tool)
            or inputs != suite_results.fingerprints(fixtures)
            or (profile and args.profile.read_bytes() != profile_bytes)):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILES[args.tool], "checker_sha256": checker_hash,
                     "binary_sha256": hashes, "debugger_version": debugger_version}
    if profile:
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
    suite_results.write(args.json, args.tool, "Ghost" if profile else "Verilator", version, verdicts,
                        inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": args.tool, "version": version, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": records,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in verdicts.values()))


if __name__ == "__main__":
    raise SystemExit(main())

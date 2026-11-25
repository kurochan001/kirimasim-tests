#!/usr/bin/env python3
"""Observe Ghost's runtime handle and callback tables across activation teardown."""

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

import suite_results


CHECKER = "tools/run_ghost_vpi_runtime_release.py"
PROFILE = "ghost-vpi-runtime-release"
CASE = "ch37/test_vpi_frame_and_thread_handle_release"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
HANDLE_ORDER = ["frame", "thread", "stamp", "vector", "bit", "frame_callback", "thread_callback"]
PHASE = re.compile(r"RELEASE phase=(\d+) persistent=([01])")
BRANCH = re.compile(r"RELEASE branch=([01]) table=([01]{7}) manager=([01]{2}) thread-live=([01])")
EXITED = re.compile(r"^Process \d+ exited with status = (-?\d+)(?: |$)")
LLDB_SCRIPT = """\
def capture(frame, location, internal_dict):
    process = frame.GetThread().GetProcess()
    architecture = process.GetTarget().GetTriple().split("-")[0]
    register = {"arm64": "x0", "arm64e": "x0", "aarch64": "x0", "x86_64": "rdi"}.get(architecture)
    if register is None:
        return False
    manager = frame.FindRegister(register).GetValueAsUnsigned()
    if manager:
        result = frame.EvaluateExpression(
            f"((int (*)(void*))remember_release_manager)((void*){manager})"
        )
        if result.GetError().Success() and result.GetValueAsUnsigned() == 1:
            location.GetBreakpoint().SetEnabled(False)
            print("RELEASE live manager captured", flush=True)
    return False
"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def expected_samples() -> list[dict]:
    both_live = ("1111111", "11", True)
    thread_only = ("0100001", "01", True)
    ended = ("0000000", "00", False)
    states = ((both_live, both_live), (thread_only, both_live), (ended, thread_only), (ended, ended))
    return [
        {"phase": phase, "persistent": True, "branches": [
            {"index": index, "table": table, "manager": manager, "thread_live": live}
            for index, (table, manager, live) in enumerate(branches)
        ]}
        for phase, branches in enumerate(states, 1)
    ]


def evaluate(lines: list[str], expected_output: list[str], debugger_exit: int) -> dict:
    ordinary, samples, exits = [], [], []
    capture_count = 0
    in_sample = False
    ordered = True
    for line in lines:
        if line == "RELEASE live manager captured":
            capture_count += 1
        elif match := PHASE.fullmatch(line):
            phase = int(match[1])
            ordered &= bool(ordinary) and ordinary[-1] == f"sample {phase} module-state=53"
            samples.append({"phase": phase, "persistent": match[2] == "1", "branches": []})
            in_sample = True
        elif match := BRANCH.fullmatch(line):
            ordered &= in_sample
            if samples:
                samples[-1]["branches"].append({"index": int(match[1]), "table": match[2],
                                                 "manager": match[3], "thread_live": match[4] == "1"})
        elif line.startswith(("arm ", "distinct ", "sample ", "worker ", "branch ", "frame ", "thread ")):
            ordinary.append(line)
            in_sample = False
        elif match := EXITED.match(line):
            exits.append(int(match[1]))
    shape = [(sample["phase"], [branch["index"] for branch in sample["branches"]]) for sample in samples]
    qualified = (capture_count == 1 and debugger_exit == 0 and exits == [0] and ordinary == expected_output
                 and ordered and shape == [(phase, [0, 1]) for phase in range(1, 5)])
    verdict = "unsupported"
    if qualified:
        verdict = "pass" if samples == expected_samples() else "fail"
    return {"status": verdict, "debugger_exit": debugger_exit, "target_exits": exits,
            "manager_captures": capture_count, "ordinary_output": ordinary, "samples": samples}


def run(artifacts: dict, include_dirs: list[Path], profile: dict, fixture: Path, work: Path) -> dict:
    c_source = fixture.parent / suite_results.header(fixture)["vpi_c"].removeprefix("@")
    executable = artifacts["simulator"]
    library = work / "witness.so"
    linker_options = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else ["-ldl"]
    compiled = subprocess.run(
        [str(artifacts["compiler"]), "-DGHOST_HANDLE_PROBE", "-shared", "-fPIC",
         *[f"-I{directory}" for directory in include_dirs], "-o", str(library), str(c_source), *linker_options],
        cwd=work, capture_output=True, text=True, errors="replace", timeout=60,
    )
    if compiled.returncode != 0:
        raise ValueError("could not compile the runtime handle witness")
    (work / "release_trace.py").write_text(LLDB_SCRIPT, encoding="utf-8")
    command = [
        str(artifacts["lldb"]), "--batch", "--no-lldbinit", "-o", "settings set target.disable-aslr false",
        "-o", "command script import release_trace.py",
        "-o", "breakpoint set --skip-prologue false --name sukimasim::vpi::VPICallbackManager::getCallbackInfo",
        "-o", "breakpoint command add -F release_trace.capture 1", "-o", "run", "--",
        str(executable), *profile["arguments"], "--lib", str(library), "-top", fixture.stem, str(fixture),
    ]
    result = subprocess.run(command, cwd=work, env={**os.environ, **profile["environment"]},
                            capture_output=True, text=True, errors="replace", timeout=90)
    expected = suite_results.expected_output(fixture).splitlines()
    return evaluate(result.stdout.splitlines(), expected, result.returncode)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    paths = {"simulator": shutil.which(args.ghost), "lldb": shutil.which(args.lldb),
             "compiler": shutil.which(os.environ.get("CC", "cc"))}
    if not all(paths.values()):
        parser.error("Ghost, LLDB and a C compiler are required")
    artifacts = {name: Path(path).absolute() for name, path in paths.items()}
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    include = args.include.resolve()
    include_dirs = [include, *(include / child for child in profile["include_subdirs"])]
    for name in ("sv_vpi_user.h", "vpi_user.h"):
        header = next((directory / name for directory in include_dirs if (directory / name).is_file()), None)
        if header is None:
            parser.error(f"{name} is unavailable")
        artifacts[name] = header
    fingerprints = {name: digest(path) for name, path in artifacts.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observations = run(artifacts, include_dirs, profile, fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (fingerprints != {name: digest(path) for name, path in artifacts.items()}
            or checksum != checker_digest() or runner != suite_results.runner_digest("ghost")
            or profile_bytes != args.profile.read_bytes() or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, profile, witness, or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "artifact_sha256": fingerprints,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(),
                     "debugger_version": suite_results.tool_version([str(artifacts["lldb"]), "--version"])}
    version = f"private build {fingerprints['simulator'][:12]}"
    status = observations["status"]
    reason = {"pass": "", "fail": "runtime handle observations differed",
              "unsupported": "runtime handle observations could not be qualified"}[status]
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: (status, reason)},
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "ghost", "version": version, "configuration": configuration, "runner_sha256": runner,
        "handle_order": HANDLE_ORDER, "expected_samples": expected_samples(),
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observations}},
    }, indent=2) + "\n", encoding="utf-8")
    print(status, CASE)
    return {"pass": 0, "fail": 1, "unsupported": 2}[status]


if __name__ == "__main__":
    raise SystemExit(main())

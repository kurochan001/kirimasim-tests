#!/usr/bin/env python3
"""Compare plain and nested-file invocations through Ghost's public VPI."""

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
import suite_results


CHECKER = "tools/run_vpi_vlog_option_files.py"
PROFILE = "ghost-vpi-vlog-option-files"
CASE = "ch38/test_vpi_vlog_info_nested_option_files"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def probe(simulator: Path, compiler: Path, header: Path, fixture: Path, profile: dict) -> dict:
    files = fixture.parent / "vlog_nested_files"
    plugin = fixture.parent / suite_results.header(fixture)["vpi_c"].removeprefix("@")
    expected = {
        "control": suite_results.expected_output(fixture).splitlines(),
        "nested": (files / "nested.expected").read_text(encoding="utf-8").splitlines(),
    }
    with tempfile.TemporaryDirectory() as temporary:
        working = Path(temporary)
        library = working / "vlog_options.so"
        undefined = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
        build = subprocess.run(
            [str(compiler), "-shared", "-fPIC", *undefined, "-Wall", "-Wextra", "-Werror",
             f"-I{header.parent}", "-o", str(library), str(plugin)],
            cwd=working, capture_output=True, text=True, errors="replace", timeout=60,
        )
        records = {"plugin_build_exit": build.returncode}
        if build.returncode != 0:
            return records
        shutil.copyfile(fixture, working / fixture.name)
        for name in ("outer.f", "inner.f"):
            shutil.copyfile(files / name, working / name)
        invoke = [str(simulator), *profile["arguments"], "--lib", str(library),
                  *suite_results.run_args(fixture)]
        for mode, arguments in (("control", [fixture.name]), ("nested", ["-f", "outer.f"])):
            process = subprocess.run(
                [*invoke, *arguments], cwd=working, capture_output=True, text=True,
                errors="replace", env={**os.environ, **profile["environment"]}, timeout=90,
            )
            output = run_ghost.normalize(process.stdout, profile).splitlines()
            records[mode] = {
                "exit": process.returncode,
                "completed": profile["trailer"] in process.stdout,
                "expected": expected[mode],
                "observed": [line for line in output if line.startswith(("vlog: ", "options: ", "applied="))],
                "matches": output == expected[mode],
            }
        return records


def assess(observations: dict) -> tuple[str, str]:
    if observations.get("plugin_build_exit") != 0:
        return "fail", "VPI application did not build"
    for mode in ("control", "nested"):
        run = observations[mode]
        if run["exit"] != 0 or not run["completed"]:
            return "fail", f"{mode} simulation did not complete"
        if not run["matches"]:
            if mode == "nested" and "options: flat outer filename" in run["observed"]:
                return "fail", "argv after -f is the filename string"
            return "fail", f"{mode} option object or HDL control differed"
    return "pass", ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--include", required=True, type=Path, help="directory containing vpi_user.h")
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    simulator = shutil.which(args.simulator)
    compiler = shutil.which(os.environ.get("CC", "cc"))
    header = args.include.resolve() / "vpi_user.h"
    if simulator is None or compiler is None or not header.is_file():
        parser.error("Ghost, a C compiler and vpi_user.h are required")
    profile_bytes = args.profile.read_bytes()
    private_profile = json.loads(profile_bytes)
    inputs = suite_results.fingerprints(list(CASES.values()))
    toolchain = {"simulator": Path(simulator).resolve(), "compiler": Path(compiler).resolve(),
                 "header": header, "profile": args.profile}
    hashes = {part: digest(path) for part, path in toolchain.items()}
    if hashes["profile"] != hashlib.sha256(profile_bytes).hexdigest():
        parser.exit(2, "Runtime profile changed before execution.\n")
    checker = checker_digest()
    runner = suite_results.runner_digest("ghost")
    try:
        observations = probe(toolchain["simulator"], toolchain["compiler"], header, CASES[CASE], private_profile)
        outcome = assess(observations)
    except (OSError, subprocess.TimeoutExpired):
        observations = {}
        outcome = "fail", "build or simulation could not complete"
    if (hashes != {part: digest(path) for part, path in toolchain.items()}
            or checker != checker_digest() or runner != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Tool, test input or checker changed during execution.\n")

    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker,
                     "binary_sha256": hashes["simulator"], "profile_sha256": hashes["profile"]}
    suite_results.write(args.json, "ghost", "Ghost", f"private build {hashes['simulator'][:12]}",
                        {CASE: outcome}, inputs=inputs, runner_sha256=runner, configuration=configuration)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "configuration": configuration, "sha256": hashes, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "status": outcome[0],
                         "reason": outcome[1], **observations}},
    }, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: {outcome[0]}" + (f" ({outcome[1]})" if outcome[1] else ""))
    return int(outcome[0] != "pass")


if __name__ == "__main__":
    raise SystemExit(main())

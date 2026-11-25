#!/usr/bin/env python3
"""Check native handle types and system-task context at the DPI boundary."""

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


CHECKER = "tools/run_dpi_vpi_boundaries.py"
HANDLES = "ch35/test_dpi_and_vpi_handles_use_distinct_apis"
SYSTEM_TASK = "ch35/test_dpi_does_not_inherit_outer_vpi_system_task"
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (HANDLES, SYSTEM_TASK)}
PROFILES = {"ghost": "ghost-dpi-system-task-boundary", "verilator": "verilator-dpi-vpi-handle-types"}
CASE_BY_TOOL = {"ghost": SYSTEM_TASK, "verilator": HANDLES}
TYPE_TRIALS = {
    "dpi_as_vpi": ("DPI_API_WITH_VPI_SIGNATURE", "dpi_api_with_vpi_signature = &svDimensions;"),
    "vpi_as_dpi": ("VPI_API_WITH_DPI_SIGNATURE", "vpi_api_with_dpi_signature = &vpi_release_handle;"),
}
NESTED_OUTPUT = "nested DPI call=0 error=1"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def command(arguments: list, cwd: Path, environment: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(arguments, cwd=cwd, env=environment, capture_output=True, text=True,
                          errors="replace", timeout=60)


def native_types(compiler: str, fixture: Path, include: Path) -> dict:
    source = Path(suite_results.header(fixture)["dpi_c"].removeprefix("@"))
    flags = [compiler, "-std=c++17", "-fsyntax-only", "-I", str(include)]
    control = command([*flags, source.name], fixture.parent)
    source_lines = (fixture.parent / source).read_text(encoding="utf-8").splitlines()
    result = {}
    for variant, (define, statement) in TYPE_TRIALS.items():
        [line] = [number for number, text in enumerate(source_lines, 1) if statement in text]
        output = command([*flags, f"-D{define}", source.name], fixture.parent)
        expected_location = rf"\b{re.escape(source.name)}:{line}(?::\d+)?:\s*error:"
        diagnostics = [text for text in output.stderr.splitlines() if re.search(expected_location, text)]
        diagnosed = any("svOpenArrayHandle" in text and "vpiHandle" in text for text in diagnostics)
        result[variant] = {"returncode": output.returncode, "line": line, "diagnostics": diagnostics,
                           "pass": output.returncode > 0 and diagnosed}
    return {"control_exit": control.returncode, "trials": result,
            "pass": control.returncode == 0 and all(trial["pass"] for trial in result.values())}


def system_task_trials(simulator: str, compiler: str, fixture: Path,
                       headers: dict, profile: dict, cwd: Path) -> dict:
    source = Path(suite_results.header(fixture)["dpi_c"].removeprefix("@"))
    design = cwd / fixture.name
    shutil.copyfile(fixture, design)
    library = cwd / "libtest.so"
    platform_flags = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    locations = list(dict.fromkeys(path.parent for path in headers.values()))
    compiled = command([compiler, "-shared", "-fPIC", *platform_flags, *[f"-I{d}" for d in locations],
                        "-o", str(library), str(fixture.parent / source)], cwd)
    if compiled.returncode != 0:
        return {"pass": False, "qualified": False, "build_exit": compiled.returncode,
                "diagnostics": compiled.stderr.replace(str(fixture.parent) + "/", "").splitlines()}
    launcher = [simulator, *profile["arguments"], "--lib", str(library), "-top", fixture.stem, design.name]
    environment = {**os.environ, **profile["environment"]}
    expected = suite_results.expected_output(fixture).splitlines()
    expected_nested = [*expected[:-1], NESTED_OUTPUT, expected[-1]]
    trials = {}
    for mode, args in (("control", []), ("nested", ["+observe_nested_dpi"])):
        observed = command([*launcher, *args], cwd, environment)
        stdout = run_ghost.normalize(observed.stdout, profile).splitlines()
        trials[mode] = {"returncode": observed.returncode, "stdout": stdout,
                        "pass": observed.returncode == 0 and stdout == (expected if mode == "control" else expected_nested)}
    nested = trials["nested"]
    output = nested["stdout"]
    qualified = (trials["control"]["pass"] and nested["returncode"] == 0 and len(output) == len(expected_nested)
                 and output[:-2] == expected[:-1] and output[-1] == expected[-1]
                 and re.fullmatch(r"nested DPI call=[01] error=[01]", output[-2]) is not None)
    return {"pass": qualified and nested["pass"], "qualified": qualified, "build_exit": compiled.returncode,
            "trials": trials, "expected_nested_stdout": expected_nested}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    simulators = parser.add_mutually_exclusive_group(required=True)
    simulators.add_argument("--verilator")
    simulators.add_argument("--ghost")
    parser.add_argument("--include", type=Path, help="root of Ghost's public headers")
    parser.add_argument("--profile", type=Path, help="strict Ghost runtime profile")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    tool = "ghost" if args.ghost else "verilator"
    found = shutil.which(args.ghost or args.verilator)
    compiler = shutil.which(os.environ.get("CC", "cc") if args.ghost else os.environ.get("CXX", "c++"))
    if not (found and compiler):
        parser.error("the selected simulator and required native compiler must be available")
    executable = str(Path(found).absolute())
    compiler = str(Path(compiler).absolute())
    artifacts = {"simulator": Path(found).resolve(), "compiler": Path(compiler).resolve()}
    profile_bytes = None
    if args.ghost:
        if not (args.include and args.profile):
            parser.error("Ghost requires --include and --profile")
        include = args.include.resolve()
        profile_bytes = args.profile.read_bytes()
        profile = json.loads(profile_bytes)
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        include_dirs = [include, *(include / subdir for subdir in profile["include_subdirs"])]
    else:
        if args.include or args.profile:
            parser.error("--include and --profile apply to Ghost")
        root = Path(suite_results.tool_version([executable, "-getenv", "VERILATOR_ROOT"]))
        if not root.is_absolute():
            parser.error("Verilator must provide an absolute VERILATOR_ROOT")
        include_dirs = [root / "include" / "vltstd"]
    headers = {name: next((d / name for d in include_dirs if (d / name).is_file()), None)
               for name in ("svdpi.h", "vpi_user.h")}
    if not all(headers.values()):
        parser.error("both public DPI and VPI headers must be available")
    artifacts.update(headers)
    hashes = {name: digest(path) for name, path in artifacts.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest(tool)
    case = CASE_BY_TOOL[tool]
    fixture = CASES[case]
    inputs = suite_results.fingerprints([fixture])
    try:
        if args.ghost:
            version = f"private build {hashes['simulator'][:12]}"
            with tempfile.TemporaryDirectory() as directory:
                observation = system_task_trials(executable, compiler, fixture, headers, profile, Path(directory))
        else:
            version = suite_results.tool_version([executable, "--version"])
            types = native_types(compiler, fixture, include_dirs[0])
            matched, reason = run_verilator.run(fixture, executable, 1, run_verilator.install_prefix(executable))
            observation = {"pass": types["pass"] and matched, "native": types,
                           "simulation": {"pass": matched, "reason": reason}}
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest(tool) or inputs != suite_results.fingerprints([fixture])
            or (args.profile is not None and args.profile.read_bytes() != profile_bytes)):
        parser.exit(2, "Tool, inputs or checker changed during qualification.\n")
    config = {"evidence_profile": PROFILES[tool], "checker_sha256": checksum, "artifact_sha256": hashes,
              "compiler_version": suite_results.tool_version([compiler, "--version"])}
    if profile_bytes is not None:
        config["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
    if observation["pass"]:
        verdict = ("pass", "")
    elif observation.get("qualified", True):
        verdict = ("fail", "DPI and VPI boundary observations differed")
    else:
        verdict = ("unsupported", "system-task control or nested call could not be verified")
    suite_results.write(args.json, tool, "Ghost" if args.ghost else "Verilator", version, {case: verdict},
                        inputs=inputs, configuration=config, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": tool, "version": version, "configuration": config, "runner_sha256": runner,
        "tests": {case: {"inputs_sha256": inputs[case], "status": verdict[0], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    print(case, observation)
    return {"pass": 0, "fail": 1, "unsupported": 2}[verdict[0]]


if __name__ == "__main__":
    raise SystemExit(main())

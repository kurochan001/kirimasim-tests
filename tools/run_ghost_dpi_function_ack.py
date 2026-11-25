#!/usr/bin/env python3
"""Check DPI function acknowledgement after an exported function disables its caller."""

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
import suite_results


CHECKER = "tools/run_ghost_dpi_function_ack.py"
PROFILE = "ghost-dpi-function-ack"
ACK = "ch35/test_dpi_import_function_acknowledges_disable"
OMIT = "ch35/test_dpi_import_function_rejects_omitted_acknowledgement"
TASK_CASES = (
    "ch35/test_dpi_import_task_rejects_wrong_status_after_disable",
    "ch35/test_dpi_import_task_rejects_disable_status_after_normal_return",
    "ch35/test_dpi_disabled_import_task_cannot_call_another_export",
)
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (ACK, OMIT, *TASK_CASES)}
TRACKING = ("DPI_ACK_TRACKING supplied worker", "DPI_ACK_TRACKING existing worker")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def compile_library(compiler: Path, include: Path, source: Path, work: Path, track_worker: bool) -> Path:
    mode = "tracked" if track_worker else "native"
    library = work / f"{source.stem}-{mode}.so"
    flags = ["-DGHOST_DPI_FUNCTION_ACK_PROBE"] if track_worker else []
    if sys.platform == "darwin":
        flags += ["-undefined", "dynamic_lookup"]
    result = subprocess.run([str(compiler), "-x", "c++", "-std=c++20", "-shared", "-fPIC", "-Wall", "-Wextra", "-Werror",
                             *flags, f"-I{include}", "-o", str(library), str(source)],
                            cwd=work, capture_output=True, timeout=60)
    if result.returncode:
        raise ValueError("could not compile the DPI acknowledgement witness")
    return library


def run_fixture(ghost: Path, library: Path, fixture: Path, profile: dict, work: Path,
                require_tracking: bool) -> dict:
    sources, includes = suite_results.files(fixture)
    result = subprocess.run(
        [str(ghost), *profile["arguments"], "--lib", str(library), *[f"+incdir+{d}" for d in includes],
         "-top", fixture.stem, *map(str, sources), str(fixture)],
        cwd=work, env={**os.environ, **profile["environment"]},
        capture_output=True, text=True, errors="replace", timeout=90,
    )
    lines = run_ghost.normalize(result.stdout, profile).splitlines()
    tracking = [line for line in lines if line.startswith("DPI_ACK_TRACKING ")]
    output = [line for line in lines if not line.startswith("DPI_ACK_TRACKING ")]
    expected = suite_results.expected_output(fixture).splitlines()
    diagnostic = suite_results.header(fixture).get("expected_stderr_regex")
    fatal = bool(diagnostic and re.search(diagnostic, result.stdout + "\n" + result.stderr))
    expected_exit = result.returncode > 0 if diagnostic else result.returncode == 0
    prefix = expected[:5] if require_tracking else expected
    has_tracking = not require_tracking or (len(tracking) == 1 and tracking[0] in TRACKING)
    qualified = has_tracking and result.returncode >= 0 and output[:len(prefix)] == prefix
    return {"exit": result.returncode, "stdout": output, "tracking": tracking, "qualified": qualified,
            "fatal_diagnostic": fatal, "pass": qualified and expected_exit and output == expected
            and (not diagnostic or fatal)}


def observe(tools: dict, include: Path, profile: dict, work: Path) -> tuple[dict, dict]:
    fixture = CASES[ACK]
    application = fixture.parent / suite_results.header(fixture)["dpi_c"].removeprefix("@")
    libraries = {mode: compile_library(tools["compiler"], include, application, work, mode == "tracked")
                 for mode in ("native", "tracked")}
    observation = {}
    results = {}
    for case in (ACK, OMIT):
        modes = {mode: run_fixture(tools["ghost"], library, CASES[case], profile, work, require_tracking=True)
                 for mode, library in libraries.items()}
        tracked = modes["tracked"]
        status = "unsupported"
        if tracked["qualified"]:
            status = "pass" if tracked["pass"] else "fail"
        observation[case] = {"status": status, **modes}
        reason = {"pass": "", "fail": "DPI function acknowledgement observations differed",
                  "unsupported": "the disabled function precondition was not observed"}[status]
        results[case] = (status, reason)
    task_fixture = CASES[TASK_CASES[0]]
    task_source = task_fixture.parent / suite_results.header(task_fixture)["dpi_c"].removeprefix("@")
    task_library = compile_library(tools["compiler"], include, task_source, work, track_worker=False)
    for case in TASK_CASES:
        check = run_fixture(tools["ghost"], task_library, CASES[case], profile, work, require_tracking=False)
        status = "unsupported"
        if check["qualified"]:
            status = "pass" if check["pass"] else "fail"
        observation[case] = {"status": status, **check}
        reason = {"pass": "", "fail": "DPI task protocol observations differed",
                  "unsupported": "the DPI task protocol stimulus could not be confirmed"}[status]
        results[case] = (status, reason)
    return observation, results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--include", required=True, type=Path)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    ghost = shutil.which(args.ghost)
    compiler = shutil.which(os.environ.get("CXX", "c++"))
    if ghost is None or compiler is None:
        parser.error("Ghost and a C++ compiler are required")
    include = args.include.resolve()
    tools = {"ghost": Path(ghost).absolute(), "compiler": Path(compiler).absolute(),
             "svdpi.h": include / "svdpi.h",
             "dpi_disable_state.h": include / "sukimasim/dpi/dpi_disable_state.h"}
    if not all(path.is_file() for path in tools.values()):
        parser.error("the Ghost ABI headers are unavailable")
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    hashes = {name: digest(path) for name, path in tools.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    fixtures = list(CASES.values())
    inputs = suite_results.fingerprints(fixtures)
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation, results = observe(tools, include, profile, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (hashes != {name: digest(path) for name, path in tools.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("ghost") or profile_bytes != args.profile.read_bytes()
            or inputs != suite_results.fingerprints(fixtures)):
        parser.exit(2, "Tool, checker, or inputs changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "artifact_sha256": hashes,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    version = f"private build {hashes['ghost'][:12]}"
    suite_results.write(args.json, "ghost", "Ghost", version, results, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {case: {"inputs_sha256": inputs[case], **result} for case, result in observation.items()},
    }, indent=2) + "\n", encoding="utf-8")
    for case, (status, _) in results.items():
        print(status, case)
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

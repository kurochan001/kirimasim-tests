#!/usr/bin/env python3
"""Run VPI object-model contrasts through the public compatibility macros."""

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
import run_vpi_compatibility_headers as headers
import suite_results


CHECKER = "tools/run_vpi_legacy_applicability.py"
CLASS = "ch36/test_vpi_legacy_class_interface_views"
REAL = "ch36/test_vpi_legacy_real_array_root_types"
LEGACY = ("1364v1995", "1364v2001", "1364v2005")
REF_OBJECT_MODES = ("1800v2005", "1800v2009")
MODES = (*LEGACY, *REF_OBJECT_MODES, "1800v2023")
CASES = {CLASS: "vpi_iterate", REAL: "vpi_get"}
PROFILES = {mode: f"vpi-legacy-applicability-{mode}" for mode in MODES}
CLASS_SCOPES = "scopes defn=1 typespec=1 plain=1 plain_classes=0"
CLASS_DEFN_EMPTY = "defn iter=0 count=0 virtual=0 ref=0 actual=0 name_mask=0"
TYPESPEC_CURRENT = "typespec iter=1 count=2 virtual=2 ref=0 actual=0 name_mask=3"
CLASS_CONNECTIONS = "interface connections=1,0"
REAL_ROOT_LEGACY = "real_view root=1 root_real=1 root_array=0 scalar_real=1 high_real=1 low_real=1"
REAL_ROOT_CURRENT = "real_view root=1 root_real=0 root_array=1 scalar_real=1 high_real=1 low_real=1"
REAL_ROOT_HIDDEN = "real_view root=0 root_real=0 root_array=0 scalar_real=1 high_real=0 low_real=0"
INT_TIME_LEGACY = "other_views int_var=1 int_array=0 time_var=1 time_array=0"
INT_TIME_CURRENT = "other_views int_var=0 int_array=1 time_var=0 time_array=1"
REAL_VALUES = "vpi=2.25,1.75,-0.50"
HDL_VALUES = "hdl=2.25,1.75,-0.50,11,7"


def checker_digest() -> str:
    checksum = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    checksum.update(suite_results.runner_digest("ghost").encode())
    checksum.update(headers.checker_digest().encode())
    return checksum.hexdigest()


def class_output(mode: str) -> tuple[str, ...]:
    if mode in REF_OBJECT_MODES:
        defn = "defn iter=1 count=2 virtual=0 ref=2 actual=2 name_mask=3"
        typespec = "typespec iter=1 count=2 virtual=0 ref=2 actual=2 name_mask=3"
    else:
        defn, typespec = CLASS_DEFN_EMPTY, TYPESPEC_CURRENT
    return CLASS_SCOPES, defn, typespec, CLASS_CONNECTIONS


def acceptable_real_output(mode: str) -> tuple[tuple[str, ...], ...]:
    if mode == "1364v1995":
        # The design is modern. An implementation can expose its current array
        # view or omit it in this mode; a legacy vpiRealVar root is inapplicable.
        return (
            (REAL_ROOT_CURRENT, INT_TIME_LEGACY, REAL_VALUES, HDL_VALUES),
            (REAL_ROOT_HIDDEN, INT_TIME_LEGACY, "vpi=2.25,0.00,0.00", HDL_VALUES),
        )
    if mode in LEGACY:
        return ((REAL_ROOT_LEGACY, INT_TIME_LEGACY, REAL_VALUES, HDL_VALUES),)
    return ((REAL_ROOT_CURRENT, INT_TIME_CURRENT, REAL_VALUES, HDL_VALUES),)


def assess(case: str, mode: str, output: str) -> tuple[str, str]:
    lines = output.splitlines()
    abi = f"abi={CASES[case]}_{headers.effective(mode)}"
    if not lines or lines[0] != abi:
        return "fail", "wrong compatibility entry point"
    observations = tuple(lines[1:])
    expected = (class_output(mode),) if case == CLASS else acceptable_real_output(mode)
    if observations in expected:
        return "pass", ""
    if case == REAL and mode == "1364v1995" and observations == (
        REAL_ROOT_LEGACY, INT_TIME_LEGACY, REAL_VALUES, HDL_VALUES
    ):
        return "fail", "real array root reported as vpiRealVar in 1364-1995"
    return "fail", "object model or HDL control differs"


def run_case(executable: Path, cc: Path, include: Path, profile: dict,
             fixture: Path, case: str, mode: str) -> tuple[tuple[str, str], dict]:
    plugin = fixture.parent / suite_results.header(fixture)["vpi_c"].removeprefix("@")
    undefined = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    with tempfile.TemporaryDirectory() as directory:
        library = Path(directory) / "mode.so"
        try:
            build = subprocess.run(
                [str(cc), "-shared", "-fPIC", *undefined, "-I", str(include),
                 f"-DVPI_COMPATIBILITY_VERSION_{mode}=1", "-o", str(library), str(plugin)],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
            if build.returncode:
                return ("fail", "VPI application did not compile"), {"c_exit": build.returncode}
            result = subprocess.run(
                [str(executable), *profile["arguments"], "--lib", str(library),
                 "-top", suite_results.top_module(fixture), str(fixture)],
                cwd=directory, env={**os.environ, **profile["environment"]},
                capture_output=True, text=True, errors="replace", timeout=90,
            )
        except (OSError, subprocess.TimeoutExpired):
            return ("fail", "build or run could not complete"), {}
    output = run_ghost.normalize(result.stdout, profile)
    messages = run_ghost.ANSI.sub("", result.stdout + result.stderr)
    failure = suite_results.judge_run(fixture, result.returncode, messages)
    verdict = ("fail", "simulation did not complete") if failure else assess(case, mode, output)
    # Publish only the fixture's tagged observations.
    observations = [line for line in output.splitlines() if line.startswith(
        ("abi=", "scopes ", "defn ", "typespec ", "interface connections=", "real_view ", "other_views ", "vpi=", "hdl="))]
    return verdict, {"c_exit": 0, "sim_exit": result.returncode, "observations": observations}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--include", type=Path, required=True, help="directory containing the VPI headers")
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json-dir", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    compiler = shutil.which(os.environ.get("CC", "cc"))
    include = args.include.resolve()
    paths = {name: include / name for name in ("vpi_user.h", "sv_vpi_user.h", "vpi_compatibility.h")}
    if program is None or compiler is None or not all(path.is_file() for path in paths.values()):
        parser.error("Ghost, a C compiler and all public VPI headers are required")
    executable, cc = Path(program).resolve(), Path(compiler).resolve()
    paths.update({"simulator": executable, "compiler": cc})
    hashes = headers.artifacts_digest(paths)
    profile_bytes = args.profile.read_bytes()
    profile_hash = hashlib.sha256(profile_bytes).hexdigest()
    profile = json.loads(profile_bytes)
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    observations, summaries = {}, {}
    for mode in MODES:
        observations[mode], summaries[mode] = {}, {}
        for case, fixture in fixtures.items():
            outcome, detail = run_case(executable, cc, include, profile, fixture, case, mode)
            summaries[mode][case] = outcome
            observations[mode][case] = {"verdict": outcome[0], "reason": outcome[1], **detail}
    if (hashes != headers.artifacts_digest(paths) or profile_bytes != args.profile.read_bytes()
            or checker != checker_digest() or runner != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Tool, public headers, checker or input changed during measurement.\n")
    for mode, results in summaries.items():
        suite_results.write(args.json_dir / f"{mode}.json", "ghost", "Ghost",
                            f"private build {hashes['simulator'][:12]}", results,
                            inputs=inputs, runner_sha256=runner,
                            configuration={"evidence_profile": PROFILES[mode], "checker_sha256": checker,
                                           "binary_sha256": hashes["simulator"], "profile_sha256": profile_hash})
        for case, (status, why) in results.items():
            print(f"{mode} {case}: {status}" + (f" ({why})" if why else ""))
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "checker_sha256": checker, "runner_sha256": runner, "sha256": hashes, "profile_sha256": profile_hash,
        "compiler": suite_results.tool_version([str(cc), "--version"]),
        "inputs_sha256": inputs, "modes": observations,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for cases in summaries.values() for status, _ in cases.values()))


if __name__ == "__main__":
    raise SystemExit(main())

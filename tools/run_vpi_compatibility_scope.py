#!/usr/bin/env python3
"""Verify a legacy VPI partition, then compare observed and migrated object views."""

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
import run_icarus
import suite_results


CHECKER = "tools/run_vpi_compatibility_scope.py"
PROFILE = "vpi-compatibility-scope"
CASE = "ch36/test_vpi_compatibility_scope_and_migration"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
COMPATIBLE_TOP = "vpi_mode_compatible_top"
MODERN_PARTITION = "vpi_mode_modern_partition"
LEGACY_ABI = "abi=vpi_get_1364v2001 scalar=1 value=17"
LIBRARIES = {
    "legacy": ("-DVPI_COMPATIBILITY_VERSION_1364v2001=1", "-DVPI_LEGACY_REAL_ADAPTER=1"),
    "recent": ("-DVPI_COMPATIBILITY_VERSION_1800v2023=1",),
    "migrated": (),
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def check_scope(tools: dict[str, Path], fixture: Path, sources: list[Path], work: Path) -> dict:
    legacy, modern, compatible = sources
    old = [str(tools["iverilog"]), "-g2001", "-tnull", "-s"]
    subset = run_icarus.execute([*old, COMPATIBLE_TOP, str(legacy), str(compatible)], 30, cwd=str(work))
    rejected = run_icarus.execute([*old, MODERN_PARTITION, str(modern)], 30, cwd=str(work))
    modern_build = subprocess.run([str(tools["slang"]), "--std=1800-2023", "-q", *map(str, sources),
                                   str(fixture)], cwd=work, capture_output=True, timeout=30)
    class_line = next(n for n, line in enumerate(modern.read_text(encoding="utf-8").splitlines(), 1)
                      if line.strip().startswith("class "))
    diagnostics = [line.replace(str(modern), modern.name) for line in rejected.stderr.splitlines()]
    class_error = any(f"{modern.name}:{class_line}:" in line and "syntax error" in line for line in diagnostics)
    return {"compatible_2001_exit": subset.returncode, "modern_2001_exit": rejected.returncode,
            "modern_2001_class_diagnostic": class_error, "modern_2001_diagnostics": diagnostics,
            "full_2023_exit": modern_build.returncode,
            "pass": subset.returncode == 0 and rejected.returncode > 0 and class_error and modern_build.returncode == 0}


def ghost_runs(tools: dict[str, Path], fixture: Path, sources: list[Path], profile: dict,
               include: Path, work: Path) -> dict:
    legacy, _, compatible = sources
    application = fixture.with_suffix(".c")
    libraries = {mode: work / (mode + ".so") for mode in LIBRARIES}
    link = ("-undefined", "dynamic_lookup") if sys.platform == "darwin" else ()
    builds = {}
    for name, flags in LIBRARIES.items():
        build = subprocess.run([str(tools["cc"]), "-shared", "-fPIC", *link, *flags,
                                f"-I{include}", str(application), "-o", str(libraries[name])],
                               cwd=work, capture_output=True, timeout=30)
        builds[name] = build.returncode
    expected = suite_results.expected_output(fixture).splitlines()
    legacy_control = ["hdl legacy=17", LEGACY_ABI]
    recent_control = [expected[0], "abi=vpi_get_1800v2012 scalar=1 value=17", *expected[2:]]
    trials = {}
    full_design = [*sources, fixture]
    for name, mode, top, design in (
        ("compatible", "legacy", COMPATIBLE_TOP, [legacy, compatible]),
        ("mixed_legacy", "legacy", fixture.stem, full_design),
        ("recent", "recent", fixture.stem, full_design),
        ("migrated", "migrated", fixture.stem, full_design),
    ):
        if builds[mode] != 0:
            continue
        result = subprocess.run([str(tools["ghost"]), *profile["arguments"], "--lib", str(libraries[mode]),
                                 "-top", top, *map(str, design)], cwd=work,
                                env={**os.environ, **profile["environment"]}, capture_output=True,
                                text=True, errors="replace", timeout=30)
        lines = run_ghost.normalize(result.stdout, profile).splitlines()
        if name == "mixed_legacy":
            # Enter the modern partition without prescribing its visibility or object model.
            checked = lines[:3] == [expected[0], LEGACY_ABI, "modern partition queried"]
        else:
            controls = {"compatible": legacy_control, "recent": recent_control, "migrated": expected}
            checked = result.returncode == 0 and lines == controls[name]
        trials[name] = {"exit": result.returncode, "stdout": lines, "checked": checked}
    return {"builds": builds, "trials": trials,
            "pass": len(trials) == 4 and all(trial["checked"] for trial in trials.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--iverilog", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    programs = {name: shutil.which(command) for name, command in (
        ("ghost", args.ghost), ("iverilog", args.iverilog), ("slang", args.slang), ("cc", os.environ.get("CC", "cc")),
    )}
    if not all(programs.values()):
        parser.error("Ghost, Icarus Verilog, Slang and a C compiler are required")
    tools = {name: Path(path).absolute() for name, path in programs.items()}
    include = args.include.resolve()
    tools.update({name: include / name for name in ("vpi_user.h", "sv_vpi_user.h", "vpi_compatibility.h")})
    tools["profile"] = args.profile
    if not all(path.is_file() for path in tools.values()):
        parser.error("the Ghost profile and public VPI compatibility headers are required")
    hashes = {name: digest(path) for name, path in tools.items()}
    profile = json.loads(args.profile.read_text(encoding="utf-8"))
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    sources, _ = suite_results.files(fixture)
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            scope = check_scope(tools, fixture, sources, work)
            observed = ghost_runs(tools, fixture, sources, profile, include, work)
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI mode qualification stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("ghost") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools, checker, profile or fixture changed during qualification.\n")
    matched = scope["pass"] and observed["pass"]
    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "icarus_version": suite_results.tool_version([str(tools["iverilog"]), "-V"]),
                     "slang_version": suite_results.tool_version([str(tools["slang"]), "--version"])}
    verdict = ("pass", "") if matched else ("fail", "VPI scope, migration or observation differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], "scope": scope, "ghost": observed}}},
        indent=2) + "\n", encoding="utf-8")
    print(scope)
    for trial, evidence in observed["trials"].items():
        print(trial, evidence)
    return int(not matched)


if __name__ == "__main__":
    raise SystemExit(main())

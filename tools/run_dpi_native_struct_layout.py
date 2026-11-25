#!/usr/bin/env python3
"""Check the DPI round trip and compare C layouts compiled from the same declaration."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_ghost
import suite_results


PROFILE = "dpi-native-struct-layout"
CHECKER = "tools/run_dpi_native_struct_layout.py"
CASE = "ch35/test_dpi_unpacked_struct_native_layout"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
TARGETS = ("arm64-apple-macos", "x86_64-unknown-linux-gnu", "i386-unknown-linux-gnu")
MEMBERS = ("marker", "serial", "short_field", "ratio", "last")
LAYOUT_IR = re.compile(r"^@dpi_struct_layout = .*constant \[7 x i32\] \[([^\]]+)\]", re.M)
TRIPLE_IR = re.compile(r'^target triple = "([^"]+)"$', re.M)
CONTROLS = {
    "native_serial": ("dst->serial = 6000000003LL;", "dst->serial = 3LL;",
                      "native reply=1", "native reply=0"),
    "canonical_mask": ("dst[1].bval = src[1].bval & 3u;", "dst[1].bval = 0u;",
                       "canonical reply packet=1 grid=1", "canonical reply packet=0 grid=0"),
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def c_layout(compiler: str, source: Path, work: Path, target: str | None) -> dict:
    options = ["-target", target] if target else []
    build = subprocess.run([
        compiler, *options, "-ffreestanding", "-std=c11", "-Werror", "-DDPI_STRUCT_LAYOUT_PROBE",
        "-S", "-emit-llvm", str(source), "-o", "-",
    ], capture_output=True, text=True, cwd=work, timeout=30)
    observed = {"compile_exit": build.returncode, "pass": False}
    layout = LAYOUT_IR.search(build.stdout)
    triple = TRIPLE_IR.search(build.stdout)
    if build.returncode != 0 or layout is None or triple is None:
        return observed
    values = [int(raw) for raw in re.findall(r"\bi32 (\d+)\b", layout[1])]
    if len(values) != len(MEMBERS) + 2:
        return observed
    offsets, size, alignment = values[:-2], values[-2], values[-1]
    valid = ((target is None or triple[1].startswith(target))
             and offsets[0] == 0 and sorted(set(offsets)) == offsets and offsets[-1] < size
             and alignment > 0 and size % alignment == 0)
    return {**observed, "triple": triple[1], "offsets": dict(zip(MEMBERS, offsets, strict=True)),
            "sizeof": size, "alignment": alignment, "pass": valid}


def ghost_runs(ghost: str, fixture: Path, include: Path, profile: dict, work: Path) -> dict:
    status, reason = run_ghost.run(fixture, ghost, include, profile)
    reference = {"matches": status == "pass", "reason": reason}
    probe = work / fixture.name
    shutil.copyfile(fixture, probe)
    source = fixture.with_suffix(".c").read_text(encoding="utf-8")
    expected = suite_results.expected_output(fixture)
    controls = {}
    for name, (before, after, good_line, bad_line) in CONTROLS.items():
        if source.count(before) != 1 or expected.count(good_line) != 1:
            raise ValueError(f"control anchor changed for {name}")
        probe.with_suffix(".c").write_text(source.replace(before, after), encoding="utf-8")
        probe.with_suffix(".expected").write_text(expected.replace(good_line, bad_line), encoding="utf-8")
        status, reason = run_ghost.run(probe, ghost, include, profile)
        controls[name] = {"matches_isolated_fault": status == "pass", "reason": reason}
    return {"reference": reference, "controls": controls}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--include", required=True, type=Path)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--clang", default="clang")
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    programs = {name: shutil.which(command) for name, command in (
        ("ghost", args.ghost), ("clang", args.clang), ("native_cc", os.environ.get("CC", "cc")),
    )}
    if not all(programs.values()):
        parser.error("Ghost, Clang and the native C compiler are required")
    artifacts = {name: Path(exe).absolute() for name, exe in programs.items()}
    include = args.include.resolve()
    artifacts["svdpi.h"] = include / "svdpi.h"
    artifacts["profile"] = args.profile
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("DPI header and Ghost profile are required")
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    hashes = {name: digest(path) for name, path in artifacts.items()}
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            source = fixture.with_suffix(".c")
            layouts = {"native_clang_target": c_layout(str(artifacts["clang"]), source, work, None)}
            layouts.update({target: c_layout(str(artifacts["clang"]), source, work, target) for target in TARGETS})
            runs = ghost_runs(str(artifacts["ghost"]), fixture, include, profile, work)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"DPI layout qualification stopped with {type(error).__name__}.\n")
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("ghost") or profile_bytes != args.profile.read_bytes()
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, header, checker, profile or fixture changed during qualification.\n")
    shapes = {(tuple(layout["offsets"].values()), layout["sizeof"], layout["alignment"])
              for target, layout in layouts.items() if target in TARGETS and layout["pass"]}
    layout_matches = all(layout["pass"] for layout in layouts.values()) and len(shapes) > 1
    matched = (layout_matches and runs["reference"]["matches"]
               and all(control["matches_isolated_fault"] for control in runs["controls"].values()))
    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "clang_version": suite_results.tool_version([str(artifacts["clang"]), "--version"]),
                     "native_cc_version": suite_results.tool_version([str(artifacts["native_cc"]), "--version"])}
    verdict = ("pass", "") if matched else ("fail", "DPI transfer or C layout observations differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], "c_layouts": layouts,
                                                   "distinct_target_layouts": len(shapes), "ghost": runs}}},
        indent=2) + "\n", encoding="utf-8")
    for target, layout in layouts.items():
        print(target, layout)
    print(runs)
    return int(not matched)


if __name__ == "__main__":
    raise SystemExit(main())

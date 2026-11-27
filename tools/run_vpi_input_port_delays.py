#!/usr/bin/env python3
"""Measure native VPI port access and replay its geometry and delays using explicit models."""

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


CHECKER = "tools/run_vpi_input_port_delays.py"
PROFILE = "input-port-delay-reference"
CASE = "ch37/test_vpi_indexed_ports_and_input_delays"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
PORT_DIMENSIONS = re.compile(
    r"input wire \[(\d+):(\d+)\] single_index, input wire "
    r"\[(\d+):(\d+)\]\[(\d+):(\d+)\] multi_index"
)
DELAY_VALUES = re.compile(
    r"s_vpi_time values\[2\] = \{\{vpiSimTime, 0, (\d+), 0\.0\}, \{vpiSimTime, 0, (\d+), 0\.0\}\};"
)
REFERENCE_LOOKUP = """static vpiHandle bit_at_offset(vpiHandle port, int offset)
{
    vpiHandle iterator = vpi_iterate(vpiBit, port), item;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        if (vpi_get(vpiOffset, item) == offset) {
            vpi_release_handle(iterator);
            return item;
        }
    }
    return NULL;
}

static int packed_offset(int index, int msb, int lsb)
{
    return lsb <= index && index <= msb ? index - lsb : -1;
}

static vpiHandle reference_index(vpiHandle port, PLI_INT32 index)
{
    int offset = packed_offset(index, SINGLE_HIGH, SINGLE_LOW);
    return offset < 0 ? NULL : bit_at_offset(port, offset);
}

static vpiHandle reference_multi_index(vpiHandle port, PLI_INT32 count, const PLI_INT32 *indices)
{
    if (count != 2)
        return NULL;
    int outer = packed_offset(indices[0], OUTER_HIGH, OUTER_LOW);
    int inner = packed_offset(indices[1], INNER_HIGH, INNER_LOW);
    if (outer < 0 || inner < 0)
        return NULL;
    int inner_width = INNER_HIGH - INNER_LOW + 1;
    return bit_at_offset(port, outer * inner_width + inner);
}

"""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("ghost")).encode()).hexdigest()


def replace_once(source: str, before: str, after: str) -> str:
    if source.count(before) != 1:
        raise ValueError(f"expected one projection anchor: {before}")
    return source.replace(before, after, 1)


def project_sources(sv: str, c: str) -> tuple[str, str, tuple, tuple]:
    dimensions = PORT_DIMENSIONS.search(sv)
    values = DELAY_VALUES.findall(c)
    if dimensions is None or len(values) != 2:
        raise ValueError("expected two declared port shapes and one input delay replacement")
    shapes = tuple(map(int, dimensions.groups()))
    single_high, single_low, outer_high, outer_low, inner_high, inner_low = shapes
    if single_high < single_low or outer_high < outer_low or inner_high < inner_low:
        raise ValueError("the projected port directions must be descending")
    rise, fall = map(int, values[1])
    multidimensional = f"[{outer_high}:{outer_low}][{inner_high}:{inner_low}] multi_index"
    width = (outer_high - outer_low + 1) * (inner_high - inner_low + 1)
    # Flatten the VPI-facing port only. The actual at the caller stays multidimensional.
    sv = replace_once(sv, f"input wire {multidimensional}", f"input wire [{width - 1}:0] multi_index")
    sv = replace_once(sv, "assign seen = direct;", f"assign #({rise}, {fall}) seen = direct;")
    names = ("SINGLE_HIGH", "SINGLE_LOW", "OUTER_HIGH", "OUTER_LOW", "INNER_HIGH", "INNER_LOW")
    bounds = "".join(f"#define {name} {bound}\n" for name, bound in zip(names, shapes, strict=True))
    index_probe = "static void examine_indices("
    c = replace_once(c, index_probe, bounds + "\n" + REFERENCE_LOOKUP + index_probe)
    c = c.replace("vpi_handle_by_multi_index(", "reference_multi_index(")
    c = c.replace("vpi_handle_by_index(", "reference_index(")
    return sv, c, shapes, (rise, fall)


def observe(ghost: str, compiler: str, include: Path, profile: dict, work: Path,
            name: str, sv: str, c: str) -> dict:
    directory = work / name
    directory.mkdir()
    source = directory / "test.sv"
    application = directory / "test.c"
    library = directory / "probe.so"
    source.write_text(sv, encoding="utf-8")
    application.write_text(c, encoding="utf-8")
    darwin = ("-undefined", "dynamic_lookup") if sys.platform == "darwin" else ()
    build = subprocess.run([compiler, "-shared", "-fPIC", *darwin, f"-I{include}",
                            "-o", str(library), str(application)],
                           cwd=directory, capture_output=True, text=True, timeout=30)
    if build.returncode:
        return {"compile_exit": build.returncode}
    run = subprocess.run(
        [ghost, *profile["arguments"], "--lib", str(library), "-top", suite_results.top_module(CASES[CASE]),
         str(source)],
        env={**os.environ, **profile["environment"]}, cwd=directory,
        capture_output=True, text=True, errors="replace", timeout=30,
    )
    return {"compile_exit": 0, "exit": run.returncode,
            "stdout": run_ghost.normalize(run.stdout, profile).splitlines()}


def matching(run: dict, expected: list[str]) -> bool:
    return run == {"compile_exit": 0, "exit": 0, "stdout": expected}


def qualify(ghost: str, compiler: str, include: Path, profile: dict, work: Path) -> dict:
    fixture = CASES[CASE]
    sv = fixture.read_text(encoding="utf-8")
    c = fixture.with_suffix(".c").read_text(encoding="utf-8")
    expected = suite_results.expected_output(fixture).splitlines()
    projected_sv, projected_c, shapes, delays = project_sources(sv, c)
    rise, fall = delays
    native = observe(ghost, compiler, include, profile, work, "native", sv, c)
    projected = observe(ghost, compiler, include, profile, work, "projected", projected_sv, projected_c)
    reverse_c = replace_once(projected_c, "indices[0], OUTER_HIGH", "indices[1], OUTER_HIGH")
    reverse_c = replace_once(reverse_c, "indices[1], INNER_HIGH", "indices[0], INNER_HIGH")
    wrong_order = observe(ghost, compiler, include, profile, work, "wrong_order", projected_sv, reverse_c)
    bypass = replace_once(projected_sv, f"assign #({rise}, {fall}) seen = direct;", "assign seen = direct;")
    missing_delay = observe(ghost, compiler, include, profile, work, "missing_delay", bypass, projected_c)

    wrong_order_expected = expected.copy()
    wrong_order_expected[5] = "multi high=0 low=0 distinct=0 reversed=0"
    missing_delay_expected = expected.copy()
    missing_delay_expected[6] = "rise before=1 peer=1"
    missing_delay_expected[8] = "fall before=0 peer=0"
    missing_delay_expected[10] = "edge ticks rise=10 fall=20"
    checks = {
        "native_delay_storage_and_adjacent_port": native.get("exit") == 0
        and native.get("stdout", [])[:4] == expected[:4],
        "reference_geometry_and_waveform": matching(projected, expected),
        "reversed_multi_index_detected": matching(wrong_order, wrong_order_expected),
        "immediate_propagation_detected": matching(missing_delay, missing_delay_expected),
    }
    return {"declared_bounds": shapes, "programmed_delays": delays, "native": native,
            "native_matches": matching(native, expected), "projected": projected,
            "wrong_order": wrong_order, "missing_delay": missing_delay, "checks": checks,
            "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    ghost = shutil.which(args.ghost)
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if ghost is None or compiler is None:
        parser.error("Ghost and a C compiler are required")
    include = args.include.resolve()
    artifacts = {"ghost": Path(ghost).resolve(), "cc": Path(compiler).resolve(),
                 "profile": args.profile, "vpi_user.h": include / "vpi_user.h",
                 "sv_vpi_user.h": include / "sv_vpi_user.h"}
    fingerprints = {key: digest(path) for key, path in artifacts.items()}
    profile = json.loads(args.profile.read_bytes())
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    inputs = suite_results.input_digest(CASES[CASE])
    checker = checker_digest()
    with tempfile.TemporaryDirectory() as directory:
        result = qualify(str(artifacts["ghost"]), str(artifacts["cc"]), include, profile, Path(directory))
    if (inputs != suite_results.input_digest(CASES[CASE]) or checker != checker_digest()
            or fingerprints != {key: digest(path) for key, path in artifacts.items()}):
        parser.exit(2, "The qualification inputs changed during execution.\n")
    record = {"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": fingerprints,
              "tests": {CASE: {"inputs_sha256": inputs, **result}}}
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    for check, verdict in result["checks"].items():
        print(f"{check}: {'PASS' if verdict else 'FAIL'}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

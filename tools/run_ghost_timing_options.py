#!/usr/bin/env python3
"""Qualify timing option semantics using explicit checks and real Ghost events."""

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


CHECKER = "tools/run_ghost_timing_options.py"
PROFILE = "timing-option-reference"
VECTOR = "ch31/test_vector_timing_check_expansion"
NEGATIVE = {kind: f"ch31/test_negative_{kind}_delayed_condition_roles" for kind in ("setuphold", "recrem")}
CASES = {name: suite_results.ROOT / "tests" / (name + ".sv") for name in (VECTOR, *NEGATIVE.values())}
VECTOR_LINES = "    $width(posedge data, 3, 0, notifier);\n    $setup(data, posedge clk, 3, notifier);"
TESTED_BLOCK = re.compile(r"(?ms)^  // Begin tested timing check\n.*?^  // End tested timing check\n")
GUARD_BLOCK = re.compile(r"(?ms)^  // Begin guard timing check\n.*?^  // End guard timing check\n")
DISABLED_OUTPUT = [
    "early data=1 delayed=1",
    "clock raw=1 delayed=1",
    "condition raw=0 explicit=0",
    "before valid=0 swapped=0 outside=0",
    "after valid=0 swapped=0 outside=0 explicit=0 raw=0",
]


def checker_digest() -> str:
    checksum = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    checksum.update(suite_results.runner_digest("ghost").encode())
    return checksum.hexdigest()


def observe(executable: Path, profile: dict, directory: Path, source: str, *,
            library: Path | None = None, include_source: str | None = None,
            arguments: tuple[str, ...] = ()) -> dict:
    directory.mkdir()
    (directory / "test.sv").write_text(source, encoding="utf-8")
    command = [str(executable), *profile["arguments"]]
    if library is not None:
        command.extend(("--lib", str(library)))
    if include_source is not None:
        (directory / "condition_edges.svh").write_text(include_source, encoding="utf-8")
        command.append("+incdir+.")
    run = subprocess.run([*command, "test.sv", *arguments], cwd=directory,
                         env={**os.environ, **profile["environment"]}, capture_output=True,
                         text=True, errors="replace", timeout=25)
    return {"exit": run.returncode, "stdout": run_ghost.normalize(run.stdout, profile).splitlines()}


def matches(run: dict, expected: list[str]) -> bool:
    return run == {"exit": 0, "stdout": expected}


def expand_vector(source: str) -> tuple[str, int, int]:
    ports = re.search(r"module vector_timing_cell\(input logic \[(\d+):0\] data, "
                      r"input logic \[(\d+):0\] clk\);", source)
    if ports is None or source.count(VECTOR_LINES) != 1:
        raise ValueError("could not identify vector timing dimensions and statements")
    data_bits, clock_bits = 1 + int(ports[1]), 1 + int(ports[2])
    widths = [f"    $width(posedge data[{data}], 3, 0, notifier);" for data in range(data_bits)]
    setups = [f"    $setup(data[{data}], posedge clk[{clock}], 3, notifier);"
              for data in range(data_bits) for clock in range(clock_bits)]
    return source.replace(VECTOR_LINES, "\n".join(widths + setups), 1), data_bits, clock_bits


def vector_checks(ghost: Path, profile: dict, work: Path, library: Path) -> dict:
    fixture = CASES[VECTOR]
    source = fixture.read_text(encoding="utf-8")
    expanded, width, clock_bits = expand_vector(source)
    baseline = observe(ghost, profile, work / "native_vector", source, library=library)
    setup = width * clock_bits
    total = width + setup
    expected = [f"width={width} setup={setup} shared={total} callback=1",
                f"pulse=0 width={width} setup={setup} distinct={total} unrelated=0",
                "pulse=1 width=1 setup=1 distinct=2 unrelated=0"]
    matrix = {}
    for data in range(width):
        for clock in range(clock_bits):
            args = (f"+data_bit={data}", f"+clk_bit={clock}")
            actual = observe(ghost, profile, work / f"expanded_{data}_{clock}", expanded,
                             library=library, arguments=args)
            matrix[f"{data},{clock}"] = {"actual": actual, "pass": matches(actual, expected)}

    affected = f"$setup(data[{width - 1}], posedge clk[{clock_bits - 1}], 3, notifier);"
    duplicate_pair = expanded.replace(affected,
                                      f"$setup(data[{width - 1}], posedge clk[0], 3, notifier);")
    duplicate = observe(ghost, profile, work / "duplicate_pair", duplicate_pair, library=library,
                         arguments=(f"+data_bit={width - 1}", f"+clk_bit={clock_bits - 1}"))
    separate_notifier = expanded.replace("  reg notifier = 0;", "  reg notifier = 0, other_notifier = 0;")
    separate_notifier = separate_notifier.replace(affected, affected.replace("notifier", "other_notifier"))
    separate = observe(ghost, profile, work / "separate_notifier", separate_notifier, library=library)
    controls = {
        "duplicate_pair_detected": matches(duplicate, [*expected[:2], "pulse=1 width=1 setup=0 distinct=1 unrelated=0"]),
        "separate_notifier_detected": matches(separate, [f"width={width} setup={setup} shared={total - 1} callback=1",
                                                       *expected[1:]]),
    }
    return {"dimensions": [width, clock_bits], "native_vector": baseline, "expected_expanded": expected,
            "expanded_cases": matrix, "mutations": controls, "mutation_runs": [duplicate, separate],
            "pass": (matches(baseline, suite_results.expected_output(fixture).splitlines())
                     and all(row["pass"] for row in matrix.values()) and all(controls.values()))}


def project_negative(source: str, kind: str, *, enabled: bool, delay_conditions: bool = False) -> str:
    if enabled:
        # A negative first limit shifts the clock; a negative second limit shifts data.
        tested = (
            "  localparam int CLOCK_DELAY = FIRST < 0 ? -FIRST : 0;\n"
            "  localparam int DATA_DELAY = SECOND < 0 ? -SECOND : 0;\n"
            "  localparam int WINDOW = FIRST + SECOND;\n"
            "  assign #(CLOCK_DELAY) shifted_clock = clock;\n"
            "  assign #(DATA_DELAY) shifted_data = data;\n"
        )
        stamp, check = "stamp", "check_now"
        if delay_conditions:
            tested += "  wire #2 wrong_stamp = stamp;\n  wire #2 wrong_check = check_now;\n"
            stamp, check = "wrong_stamp", "wrong_check"
        data_first = f"posedge shifted_data &&& ((SECOND < 0) && {stamp})"
        clock_first = f"posedge shifted_clock &&& ((FIRST < 0) && {stamp})"
        data_second = f"posedge shifted_data &&& {check}"
        clock_second = f"posedge shifted_clock &&& {check}"
        if kind == "setuphold":
            positive = (f"    $setup({data_first}, {clock_second}, WINDOW, notifier);\n"
                        f"    $hold({clock_first}, {data_second}, WINDOW, notifier);\n")
        else:
            positive = (f"    $recovery({data_first}, {clock_second}, WINDOW, notifier);\n"
                        f"    $removal({data_second}, {clock_first}, WINDOW, notifier);\n")
        tested += "  specify\n" + positive + "  endspecify\n"
        guard = "  assign #8 delayed_clock = clock;\n"
    else:
        tested = "  assign shifted_clock = clock;\n  assign shifted_data = data;\n"
        guard = "  assign delayed_clock = clock;\n"
    replaced, tested_count = TESTED_BLOCK.subn(lambda _: tested, source)
    replaced, guard_count = GUARD_BLOCK.subn(lambda _: guard, replaced)
    if (tested_count, guard_count) != (1, 1):
        raise ValueError("expected one tested and one guard timing check")
    return replaced


def negative_checks(ghost: Path, profile: dict, work: Path, kind: str, fixture: Path) -> dict:
    wrapper = fixture.read_text(encoding="utf-8")
    guard_source = fixture.parent / "negative_timing_fixtures/condition_edges.svh"
    shared = guard_source.read_text(encoding="utf-8")
    expected = suite_results.expected_output(fixture).splitlines()
    native = observe(ghost, profile, work / f"{kind}_native", wrapper, include_source=shared)
    enabled = observe(ghost, profile, work / f"{kind}_enabled", wrapper,
                      include_source=project_negative(shared, kind, enabled=True))
    disabled = observe(ghost, profile, work / f"{kind}_disabled", wrapper,
                       include_source=project_negative(shared, kind, enabled=False))
    wrong = observe(ghost, profile, work / f"{kind}_delayed_conditions", wrapper,
                    include_source=project_negative(shared, kind, enabled=True, delay_conditions=True))
    wrong_conditions_distinguished = (
        wrong["exit"] == 0 and wrong["stdout"][:3] == expected[:3]
        and wrong["stdout"][3:] == ["before valid=0 swapped=0 outside=0",
                                    "after valid=0 swapped=0 outside=0 explicit=1 raw=0"]
    )
    return {"native": native, "native_matches_enabled": matches(native, expected),
            "reference_enabled": enabled, "reference_disabled": disabled,
            "expected_enabled": expected, "expected_disabled": DISABLED_OUTPUT,
            "delayed_conditions_mutation": wrong, "delayed_conditions_distinguished": wrong_conditions_distinguished,
            "pass": matches(enabled, expected) and matches(disabled, DISABLED_OUTPUT) and wrong_conditions_distinguished}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True, type=Path)
    parser.add_argument("--include", required=True, type=Path, help="Ghost VPI include directory")
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    ghost, include = args.ghost.resolve(), args.include.resolve()
    compiler = shutil.which(os.environ.get("CC", "cc"))
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if not (ghost.is_file() and compiler and all((include / name).is_file() for name in ("vpi_user.h", "sv_vpi_user.h"))
            and "--lrm-strict" in profile["arguments"]):
        parser.error("Ghost, its VPI headers, a C compiler and its strict profile are required")
    inputs = {case: suite_results.input_digest(fixture) for case, fixture in CASES.items()}
    binary = hashlib.sha256(ghost.read_bytes()).hexdigest()
    checker = checker_digest()
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        library = work / "timing.so"
        link = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
        build = subprocess.run([compiler, "-shared", "-fPIC", *link, f"-I{include}",
                                str(CASES[VECTOR].with_suffix(".c")), "-o", str(library)],
                               cwd=work, capture_output=True, text=True, timeout=30)
        if build.returncode:
            parser.exit(2, f"The timing observer could not be built (exit {build.returncode}).\n")
        results = {VECTOR: vector_checks(ghost, profile, work, library)}
        for kind, name in NEGATIVE.items():
            results[name] = negative_checks(ghost, profile, work, kind, CASES[name])
    if (checker != checker_digest() or binary != hashlib.sha256(ghost.read_bytes()).hexdigest()
            or profile_bytes != args.profile.read_bytes()
            or any(inputs[case] != suite_results.input_digest(fixture) for case, fixture in CASES.items())):
        parser.exit(2, "Tools or inputs changed during the timing check.\n")
    for case, result in results.items():
        result["inputs_sha256"] = inputs[case]
        print(f"{case}: {'pass' if result['pass'] else 'fail'}")
    record = {"profile": PROFILE, "checker_sha256": checker, "ghost_sha256": binary,
              "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(), "tests": results}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    return int(not all(result["pass"] for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

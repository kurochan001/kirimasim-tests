#!/usr/bin/env python3
"""Exercise a run-wide VPI default adapter and real compile-bound Ghost entry points."""

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


CHECKER = "tools/run_vpi_host_default_modes.py"
PROFILE = "vpi-host-default-reference"
CASE = "ch36/test_vpi_host_default_and_compile_bound_modes"
REVERSED = "ch36/test_vpi_host_default_reversed_library_order"
CASES = {case: suite_results.ROOT / "tests" / f"{case}.sv" for case in (CASE, REVERSED)}
HOST_DEFAULT = "KIRIMASIM_TEST_HOST_VPI_DEFAULT"
UNBOUND = ("unbound-one", "unbound-two")
FIXED = {"compile-bound-1995": "1364v1995", "compile-bound-2023": "1800v2023"}
OBSERVATION = re.compile(
    r"^([a-z0-9-]+) array=(-?\d+) word=(-?\d+) value=(-?\d+) variables=(\d+)$", re.M
)
CURRENT = (116, 48, 47, 7)
LEGACY = (29, 30, 47, 1)
AMBIGUOUS = (-1, -1, 47, 0)
MODES = {"current": CURRENT, "legacy": LEGACY}


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("ghost")).encode()).hexdigest()


def build(command: list[str], work: Path) -> None:
    result = subprocess.run(command, cwd=work, capture_output=True, text=True, timeout=30)
    if result.returncode:
        raise ValueError(f"the compiler exited {result.returncode}: {result.stderr.strip()}")


def build_applications(compiler: str, include: Path, helper: Path, work: Path) -> dict:
    command = [compiler, "-dynamiclib", "-std=c11", "-Wall", "-Wextra", "-Werror",
               "-undefined", "dynamic_lookup", "-I", str(include)]
    adapter = work / "host-default.dylib"
    build([*command, str(helper / "dispatcher.c"), "-o", str(adapter)], work)
    source = str(helper / "application.c")
    groups = {"native": {}, "adapted": {}, "bound": {}}
    for family in ("native", "adapted"):
        dependencies = (str(adapter),) if family == "adapted" else ()
        for label in UNBOUND:
            library = work / f"{family}-{label}.dylib"
            build([*command, f'-DTEST_APPLICATION="{label}"', source, *dependencies,
                   "-o", str(library)], work)
            groups[family][label] = library
    for label, version in FIXED.items():
        library = work / f"{label}.dylib"
        build([*command, f'-DTEST_APPLICATION="{label}"', f"-DVPI_COMPATIBILITY_VERSION_{version}=1",
               source, "-o", str(library)], work)
        groups["bound"][label] = library
    modified = work / "change-environment.dylib"
    build([*command, f'-DTEST_APPLICATION="{UNBOUND[0]}"', "-DTEST_CHANGE_ENVIRONMENT=1",
           source, str(adapter), "-o", str(modified)], work)
    return {"adapter": adapter, "changed_environment": modified, **groups}


def observe(ghost: str, profile: dict, work: Path, source: Path, libraries: dict, mode: str) -> dict:
    args = [token for library in libraries.values() for token in ("--lib", str(library))]
    result = subprocess.run([ghost, *profile["arguments"], *args, str(source)], cwd=work,
                            env={**os.environ, **profile["environment"], HOST_DEFAULT: mode},
                            capture_output=True, text=True, errors="replace", timeout=45)
    observations = OBSERVATION.findall(result.stdout)
    values = {label: tuple(map(int, ints)) for label, *ints in observations}
    output = [line for line in result.stdout.splitlines()
              if OBSERVATION.fullmatch(line) or line.startswith("environment changed=")]
    diagnostics = [line for line in result.stderr.splitlines() if line.startswith("host default")]
    complete = len(observations) == len(libraries) and set(values) == libraries.keys()
    return {"exit": result.returncode, "applications_complete": complete, "values": values, "output": output,
            "diagnostics": diagnostics, "libraries_sha256": {label: digest(lib) for label, lib in libraries.items()}}


def expected_values(unbound: tuple) -> dict:
    return dict.fromkeys(UNBOUND, unbound) | {"compile-bound-1995": LEGACY, "compile-bound-2023": CURRENT}


def matches(record: dict, values: dict, diagnostics: list[str] | None = None) -> bool:
    return (record["exit"] == 0 and record["applications_complete"] and record["values"] == values
            and record["diagnostics"] == (diagnostics or []))


def change_observed(record: dict, new_mode: str) -> bool:
    order = [line.split()[0] for line in record["output"] if OBSERVATION.fullmatch(line)]
    event = f"environment changed={new_mode}"
    if record["output"].count(event) != 1 or order[:2] != list(UNBOUND):
        return False
    position = record["output"].index(event)
    return position == 1 and record["output"][position + 1].startswith(UNBOUND[1] + " ")


def qualify(ghost: str, profile: dict, source: Path, work: Path, built: dict) -> dict:
    artifacts = {"adapter": built["adapter"], "changed_environment": built["changed_environment"],
                 **{f"{family}/{label}": path for family in ("native", "adapted", "bound")
                    for label, path in built[family].items()}}
    fingerprints = {name: digest(path) for name, path in artifacts.items()}
    native = built["native"] | built["bound"]
    adapted = built["adapted"] | built["bound"]
    changed = adapted | {UNBOUND[0]: built["changed_environment"]}
    native_runs = {mode: observe(ghost, profile, work, source, native, mode) for mode in MODES}
    adapted_runs = {mode: observe(ghost, profile, work, source, adapted, mode) for mode in MODES}
    changed_runs = {mode: observe(ghost, profile, work, source, changed, mode) for mode in MODES}
    ambiguous = observe(ghost, profile, work, source, adapted, "legacy,current")
    checks = {
        "native_unbound_and_bound_controls": all(matches(row, expected_values(CURRENT))
                                                 for row in native_runs.values()),
        "host_setting_changes_both_unbound_apps": all(
            matches(adapted_runs[mode], expected_values(values)) for mode, values in MODES.items()),
        "same_libraries_in_both_default_modes": adapted_runs["current"]["libraries_sha256"]
        == adapted_runs["legacy"]["libraries_sha256"]
        == {label: fingerprints[f"adapted/{label}"] if label in UNBOUND else fingerprints[f"bound/{label}"]
            for label in adapted},
        "compile_bound_apps_keep_their_modes": all(
            record["values"].get("compile-bound-1995") == LEGACY
            and record["values"].get("compile-bound-2023") == CURRENT
            for record in [*native_runs.values(), *adapted_runs.values(), *changed_runs.values(), ambiguous]),
        "host_default_unchanged_after_environment_edit": all(
            matches(changed_runs[mode], expected_values(values))
            and change_observed(changed_runs[mode], "legacy" if mode == "current" else "current")
            for mode, values in MODES.items()),
        "ambiguous_host_selection_rejected": matches(
            ambiguous, expected_values(AMBIGUOUS), ["host default requires exactly one compatibility mode"]),
        "built_artifacts_unchanged": fingerprints == {name: digest(path) for name, path in artifacts.items()},
    }
    return {"native": native_runs, "adapted": adapted_runs, "changed_environment": changed_runs,
            "ambiguous": ambiguous, "application_sha256": fingerprints,
            "checks": checks, "pass": all(checks.values())}


def qualify_load_order(ghost: str, profile: dict, source: Path, work: Path, built: dict) -> dict:
    applications = {"original": built["adapted"],
                    "reversed": {name: built["adapted"][name] for name in reversed(UNBOUND)}}
    runs = {order: {mode: observe(ghost, profile, work, source, libraries, mode) for mode in MODES}
            for order, libraries in applications.items()}
    fingerprint = {name: digest(path) for name, path in built["adapted"].items()}
    expected = {mode: dict.fromkeys(UNBOUND, (array, word, 83, variables))
                for mode, (array, word, _, variables) in MODES.items()}
    checks = {
        "same_unbound_binaries_in_each_run": all(row["libraries_sha256"] == fingerprint
                                                for group in runs.values() for row in group.values()),
        "reported_order_matches_library_order": all(list(row["values"]) == list(applications[order])
                                                     for order, group in runs.items() for row in group.values()),
        "both_load_orders_use_one_default_without_compile_bound_apps": all(
            matches(row, expected[mode]) for group in runs.values() for mode, row in group.items()),
    }
    return {"load_orders": runs, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    if sys.platform != "darwin":
        parser.error("the reference adapter requires Mach-O two-level symbol binding")
    ghost = shutil.which(args.ghost)
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if ghost is None or compiler is None:
        parser.error("Ghost and a C compiler are required")
    include = args.include.resolve()
    artifacts = {"ghost": Path(ghost).resolve(), "cc": Path(compiler).resolve(), "profile": args.profile,
                 "vpi_user.h": include / "vpi_user.h", "vpi_compatibility.h": include / "vpi_compatibility.h"}
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("both VPI headers and the Ghost profile are required")
    hashes = {key: digest(path) for key, path in artifacts.items()}
    profile = json.loads(args.profile.read_bytes())
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    inputs = {case: suite_results.input_digest(source) for case, source in CASES.items()}
    checker = checker_digest()
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            built = build_applications(str(artifacts["cc"]), include, CASES[CASE].parent / "vpi_host_default", work)
            ghost = str(artifacts["ghost"])
            results = {CASE: qualify(ghost, profile, CASES[CASE], work, built),
                       REVERSED: qualify_load_order(ghost, profile, CASES[REVERSED], work, built)}
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI compatibility qualification stopped: {error}\n")
    if (hashes != {key: digest(path) for key, path in artifacts.items()} or checker != checker_digest()
            or inputs != {case: suite_results.input_digest(source) for case, source in CASES.items()}):
        parser.exit(2, "Qualification inputs changed during the run.\n")
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
        "compiler_version": suite_results.tool_version([str(artifacts["cc"]), "--version"]),
        "tests": {case: {"inputs_sha256": inputs[case], **result} for case, result in results.items()},
    }, indent=2) + "\n", encoding="utf-8")
    for case, result in results.items():
        for check, passed in result["checks"].items():
            print(f"{case} {check}: {'PASS' if passed else 'FAIL'}")
    return int(any(not result["pass"] for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

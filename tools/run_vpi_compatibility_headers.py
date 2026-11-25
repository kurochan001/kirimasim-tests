#!/usr/bin/env python3
"""Check supported mode selection and its diagnostics against public VPI headers."""

import argparse
import hashlib
from itertools import combinations
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

import suite_results


PROFILE = "vpi-compatibility-headers"
CHECKER = "tools/run_vpi_compatibility_headers.py"
DIAGNOSTIC_REQUIREMENTS = {"SV2023-36.12.2.1-EXTRACT-ONE-CONSISTENT-MODE"}
DIAGNOSTIC_ANCHOR = "VPI_COMPATIBILITY_VERSION|compatibility mode"
CASES = {
    "ch36/test_vpi_public_header_shares_one_legacy_mode_with_callbacks": "1364v2001",
    "ch36/test_vpi_public_header_shares_one_recent_mode_with_callbacks": "1800v2023",
}
MODES = (
    "1364v1995", "1364v2001", "1364v2005", "1800v2005",
    "1800v2009", "1800v2012", "1800v2017", "1800v2023",
)
LANGUAGES = (("c", "CC", "cc"), ("c++", "CXX", "c++"))
ROUTINES = (
    "vpi_compare_objects", "vpi_control", "vpi_get", "vpi_get_str", "vpi_get_value",
    "vpi_handle", "vpi_handle_by_index", "vpi_handle_by_multi_index", "vpi_handle_by_name",
    "vpi_handle_multi", "vpi_iterate", "vpi_put_value", "vpi_register_cb", "vpi_scan",
)
MODE_PROBE = '#include "vpi_user.h"\nmode_probe vpi_get\n'
SELECTED = re.compile(r"^mode_probe vpi_get_(\w+)$", re.M)
ROUTINE_PROBE = "\n".join(f"mode_routine {name}" for name in ROUTINES)
REBOUND_ROUTINE = re.compile(r"^mode_routine (\w+)$", re.M)
MODE_ERROR = re.compile(
    rf"^(?=.*\bvpi_(?:user|compatibility)\.h\b)(?=.*\berror\b)(?=.*(?:{DIAGNOSTIC_ANCHOR}))"
    r".*(?:only one|more than one|multiple|mutually exclusive|conflicting)", re.I | re.M
)
GUARD_ERROR = re.compile(
    r"^(?=.*\bvpi_compatibility\.h\b)(?=.*\berror\b).*(?:only be included|already included|repeated inclusion"
    r"|do not include|VPI_COMPATIBILITY_H)", re.I | re.M
)
SUPPLIED_MODE = ("-DCOMPATIBILITY_FROM_FLAGS=1", "-DCOMPATIBILITY_SEPARATE_SOURCES=1")


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def compile_source(compiler: str, language: str, include: Path, modes: tuple[str, ...],
                   source: str, *, action: tuple[str, ...] = ("-E", "-P"),
                   flags: tuple[str, ...] = (), cwd: Path | None = None) -> subprocess.CompletedProcess:
    definitions = [f"-DVPI_COMPATIBILITY_VERSION_{mode}=1" for mode in modes]
    return subprocess.run([compiler, *action, "-x", language, "-I", str(include), *flags, *definitions, "-"],
                          input=source, capture_output=True, text=True, cwd=cwd, timeout=60)


def effective(mode: str) -> str:
    return "1800v2012" if mode in ("1800v2017", "1800v2023") else mode


def result_code(result: subprocess.CompletedProcess, pattern: re.Pattern) -> str:
    if result.returncode < 0:
        return "crashed"
    if result.returncode:
        return "diagnosed" if pattern.search(result.stderr) else "other_error"
    match = SELECTED.search(result.stdout)
    return f"selected_{match[1]}" if match else "accepted_without_selection"


def check_mode(result: subprocess.CompletedProcess) -> str:
    status = result_code(result, MODE_ERROR)
    if status.startswith("selected_"):
        suffix = status.removeprefix("selected_")
        if REBOUND_ROUTINE.findall(result.stdout) != [f"{name}_{suffix}" for name in ROUTINES]:
            return "inconsistent_routine_selection"
    return status


def inspect_source(path: Path, fixture_mode: str, compiler: str, language: str, include: Path) -> dict:
    original = path.read_text(encoding="utf-8")
    probe = (original + "\nmode_probe vpi_get\n#ifdef VPI_COMPATIBILITY_H\nmode_guard_present\n#endif\n"
             + ROUTINE_PROBE + "\n")

    def preprocess(source: str, *modes: str):
        return compile_source(compiler, language, include, modes, source, flags=SUPPLIED_MODE, cwd=path.parent)

    singles = {mode: check_mode(preprocess(probe, mode)) for mode in MODES}
    pairs = {f"{first}+{second}": check_mode(preprocess(probe, first, second))
             for first, second in combinations(MODES, 2)}
    valid = preprocess(probe, fixture_mode)
    reentry = preprocess(probe + '\n#include "vpi_compatibility.h"\n', fixture_mode)
    preguarded = preprocess("#define VPI_COMPATIBILITY_H 1\n" + probe, fixture_mode)
    guard_attempts = {"reentry": result_code(reentry, GUARD_ERROR), "predefined": result_code(preguarded, GUARD_ERROR)}
    compiled = compile_source(compiler, language, include, (fixture_mode,), original,
                              action=("-fsyntax-only",), flags=SUPPLIED_MODE, cwd=path.parent)
    checks = {
        "single_modes_match": all(status == f"selected_{effective(mode)}" for mode, status in singles.items()),
        "all_original_pairs_rejected": all(status == "diagnosed" for status in pairs.values()),
        "one_effective_branch": all(
            status == "diagnosed" or effective(first) == effective(second) and status == f"selected_{effective(first)}"
            for (first, second), status in zip(combinations(MODES, 2), pairs.values())
        ),
        "public_header_sets_guard": valid.returncode == 0 and "mode_guard_present" in valid.stdout.splitlines(),
        "guarded_reentry_rejected": guard_attempts["reentry"] == "diagnosed",
        "predefined_guard_rejected": guard_attempts["predefined"] == "diagnosed",
        "valid_source_compiles": compiled.returncode == 0,
    }
    return {"single_modes": singles, "pairs": pairs, "guard_attempts": guard_attempts, "checks": checks}


def artifacts_digest(paths: dict[str, Path]) -> dict:
    return {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in paths.items()}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--include", required=True, type=Path, help="directory with the two VPI public headers")
    parser.add_argument("--json", required=True, type=Path, help="write qualification results")
    args = parser.parse_args()
    include = args.include.resolve()
    drivers = {language: shutil.which(os.environ.get(variable, fallback))
               for language, variable, fallback in LANGUAGES}
    if not all(drivers.values()):
        parser.error("C and C++ compilers are required")
    files = {name: include / name for name in ("vpi_user.h", "vpi_compatibility.h")}
    if not all(path.is_file() for path in files.values()):
        parser.error("both vpi_user.h and vpi_compatibility.h are required")
    drivers = {lang: str(Path(path).absolute()) for lang, path in drivers.items()}
    files.update({lang: Path(path) for lang, path in drivers.items()})
    hashes, checker = artifacts_digest(files), checker_digest()
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    results = {}
    for case, fixture in fixtures.items():
        fields = suite_results.header(fixture)
        sources = {"application": fixture.parent / fields["vpi_c"].removeprefix("@"),
                   "callback": fixture.parent / fields["files"]}
        results[case] = {"inputs_sha256": inputs[case], "languages": {
            lang: {role: inspect_source(path, CASES[case], driver, lang, include)
                   for role, path in sources.items()}
            for lang, driver in drivers.items()
        }}
    if (hashes != artifacts_digest(files) or checker != checker_digest()
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Compiler, headers, checker or fixture changed during qualification.\n")
    record = {"profile": PROFILE, "checker_sha256": checker, "sha256": hashes,
              "compilers": {lang: suite_results.tool_version([exe, "--version"]) for lang, exe in drivers.items()},
              "tests": results}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    differences = 0
    for case, result in results.items():
        for lang, roles in result["languages"].items():
            for role, observation in roles.items():
                checks = observation["checks"]
                differences += len(checks) - sum(checks.values())
                print(f"{case} {lang} {role}: {sum(checks.values())}/{len(checks)} checks match")
    return int(differences > 0)


if __name__ == "__main__":
    raise SystemExit(main())

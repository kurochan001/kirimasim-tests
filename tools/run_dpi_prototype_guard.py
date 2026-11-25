#!/usr/bin/env python3
"""Check the public DPI header's declaration macros with the C preprocessor."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

import suite_results


PROFILE = "verilator-dpi-prototype-guard"
CHECKER = "tools/run_dpi_prototype_guard.py"
CASE = "ch35/test_svdpi_h_prototype_guard"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
LANGUAGES = (("c", "CC", "cc"), ("c++", "CXX", "c++"))
MODES = {
    "default": ([], "", "", "DPI_EXTERN DPI_DLLISPEC", "DPI_EXTERN DPI_DLLESPEC"),
    "caller_extern": (["-DPROBE_CALLER_EXTERN"], "probe_caller_extern", "probe_caller_extern",
                      "DPI_EXTERN DPI_DLLISPEC", "DPI_EXTERN DPI_DLLESPEC"),
    "caller_prototypes": (["-DPROBE_CALLER_PROTOTYPES"], "probe_caller_import", "",
                          "probe_caller_import", "probe_caller_export"),
}
DEFINITION = re.compile(r"^#define (DPI_PROTOTYPES|DPI_EXTERN|XXTERN|EETERN)(?:[ \t]+(.*))?$", re.M)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def inspect(driver: str, language: str, header: Path, source: Path, mode: str) -> dict:
    flags, prefix, external, importer, exporter = MODES[mode]
    try:
        proc = subprocess.run(
            [driver, "-x", language, "-E", "-dD", "-Werror", "-I", str(header.parent), *flags, source.name],
            cwd=source.parent, capture_output=True, text=True, errors="replace", timeout=60,
        )
    except subprocess.TimeoutExpired:
        return {"pass": False, "problem": "preprocessing timed out"}
    definitions = [(name, " ".join(replacement.split())) for name, replacement in DEFINITION.findall(proc.stdout)]
    expected = dict(DPI_EXTERN=[external], XXTERN=[importer], EETERN=[exporter])
    active = {name: [value for macro, value in definitions if macro == name] for name in expected}
    declaration = re.search(r"^([^\n]*?)\bconst\s+char\s*\*\s*svDpiVersion\s*\(", proc.stdout, re.M)
    actual_prefix = " ".join(declaration[1].split()) if declaration else None
    guard_definitions = [value for name, value in definitions if name == "DPI_PROTOTYPES"]
    header_selected = any(line.startswith("# ") and f'"{header}"' in line for line in proc.stdout.splitlines())
    passed = (proc.returncode == 0 and header_selected and active == expected and actual_prefix == prefix
              and len(guard_definitions) == 1)
    return {
        "pass": passed,
        "returncode": proc.returncode,
        "selected_svdpi_h": header_selected,
        "declaration_macros": definitions,
        "svDpiVersion_prefix": actual_prefix,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    tool = parser.add_mutually_exclusive_group(required=True)
    tool.add_argument("--verilator", help="Verilator executable associated with the public header")
    tool.add_argument("--comparison-include", type=Path, help="directory of a comparison tool's svdpi.h")
    parser.add_argument("--json", type=Path, help="write Verilator execution evidence")
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    fixture = CASES[CASE]
    fields = suite_results.header(fixture)
    source = fixture.parent / fields["dpi_c"].removeprefix("@")
    drivers = {language: shutil.which(os.environ.get(env, default)) for language, env, default in LANGUAGES}
    if not all(drivers.values()):
        parser.error("C and C++ preprocessors are required")
    artifacts = {language: Path(driver) for language, driver in drivers.items()}
    runner = None
    if args.verilator:
        executable = shutil.which(args.verilator)
        if not executable:
            parser.error("the specified Verilator executable is not available")
        artifacts["verilator"] = Path(executable)
        root = Path(suite_results.tool_version([executable, "-getenv", "VERILATOR_ROOT"]))
        if not root.is_absolute():
            parser.error("Verilator must report an absolute VERILATOR_ROOT")
        include = root / "include" / "vltstd"
        version = suite_results.tool_version([executable, "--version"])
        runner = suite_results.runner_digest("verilator")
    else:
        if args.json:
            parser.error("--json requires --verilator")
        include = args.comparison_include
        version = None
    # Keep the path printed by the preprocessor and hash the referenced file.
    header = include.resolve() / "svdpi.h"
    if not header.is_file():
        parser.error("svdpi.h must be present in the selected include directory")
    artifacts["svdpi_h"] = header
    artifact_hashes = {name: digest(path) for name, path in artifacts.items()}
    checker = checker_digest()
    inputs = suite_results.fingerprints([fixture])
    trials = {language: {mode: inspect(driver, language, header, source, mode) for mode in MODES}
              for language, driver in drivers.items()}
    if (inputs != suite_results.fingerprints([fixture]) or checker != checker_digest()
            or artifact_hashes != {name: digest(path) for name, path in artifacts.items()}
            or runner is not None and runner != suite_results.runner_digest("verilator")):
        parser.exit(2, "Compiler, header, checker or fixture changed during qualification.\n")
    passed = all(result["pass"] for modes in trials.values() for result in modes.values())
    configuration = {"checker_sha256": checker, "artifact_sha256": artifact_hashes}
    if runner is not None:
        configuration["evidence_profile"] = PROFILE
    record = {
        "version": version,
        "configuration": configuration,
        "compilers": {language: suite_results.tool_version([driver, "--version"])
                      for language, driver in drivers.items()},
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "pass": passed, "trials": trials}},
    }
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    if args.json:
        status = ("pass", "") if passed else ("fail", "DPI declaration macros differed")
        suite_results.write(args.json, "verilator", "Verilator", version, {CASE: status},
                            inputs=inputs, configuration=configuration, runner_sha256=runner)
    for language, modes in trials.items():
        for mode, result in modes.items():
            print(f"{language} {mode}: {'pass' if result['pass'] else 'failed'}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

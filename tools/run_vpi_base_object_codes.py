#!/usr/bin/env python3
"""Check Annex K's reservation against the SystemVerilog extension object-type namespace."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import suite_results


CHECKER = "tools/run_vpi_base_object_codes.py"
PROFILE = "vpi-base-object-code-reference"
CASE = "ch36/test_vpi_base_object_code_reservations"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
OBJECTS = re.compile(r"^/\*+[ \t]*OBJECT TYPES[ \t*]+/$", re.M)
RELATIONSHIPS = re.compile(r"^/\*+[ \t]*(?:methods\b|one-to-one\b).*?\*/$", re.M | re.I)
OBJECT_MACRO = re.compile(r"^#define[ \t](vpi\w+)[ \t]+([^\n]+)", re.M)
BASE_MACRO = re.compile(r"^#define[ \t]+(vpi\w+)[ \t]+", re.M)
IDENTIFIER = re.compile(r"vpi\w+")
BOUNDARY_CONTROLS = {
    "vpiBeforeBaseReservation": "(2 - 2)",
    "vpiFirstBaseReservation": "(2 - 1)",
    "vpiLastBaseReservation": "(0x100 + 43)",
    "vpiAfterBaseReservation": "(3 * 100)",
}
BOUNDARY_COLLISIONS = {"vpiFirstBaseReservation": 1, "vpiLastBaseReservation": 299}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def object_section(header: str) -> tuple[int, int]:
    start = OBJECTS.search(header)
    end = RELATIONSHIPS.search(header, start.end()) if start else None
    if start is None or end is None:
        raise ValueError("missing object-type or relationship heading in sv_vpi_user.h")
    return start.end(), end.start()


def object_declarations(header: str) -> dict[str, str]:
    begin, end = object_section(header)
    # Primary vpi defines have one space after #define in these headers.
    # The indented Icarus array subtype values are return selectors.
    declarations = {}
    for name, raw in OBJECT_MACRO.findall(header[begin:end]):
        value = re.split(r"/\*|//", raw, maxsplit=1)[0].strip()
        if name in declarations:
            raise ValueError(f"duplicate extension object declaration: {name}")
        declarations[name] = value
    if "vpiPackage" not in declarations and len(declarations) < 10:
        raise ValueError("could not identify extension object declarations")
    return declarations


def compiled_values(command: list[str], names: set[str], work: Path, header: str) -> dict[str, int]:
    source = ['#include <stdio.h>', f'#include "{header}"', 'int main(void) {']
    source.extend(f'printf("{name} %d\\n", (int)({name}));' for name in sorted(names))
    source.extend(("return 0;", "}"))
    binary = work / "object_codes"
    build = subprocess.run([*command, "-I", str(work), "-o", str(binary), "-"], capture_output=True,
                           input="\n".join(source), text=True, timeout=30)
    if build.returncode:
        raise ValueError(f"could not evaluate {header} with {command[2]}:\n{build.stderr}")
    observed = subprocess.check_output([str(binary)], text=True, cwd=work, timeout=30)
    values = {name: int(value) for name, value in map(str.split, observed.splitlines())}
    if set(values) != names:
        raise ValueError("the compiler probe did not report all object codes")
    return values


def observe(command: list[str], work: Path, header: str, base_names: set[str]) -> dict:
    objects = object_declarations(header)
    alias_targets = {raw for raw in objects.values() if IDENTIFIER.fullmatch(raw) and raw in base_names}
    (work / "object_extension.h").write_text(header, encoding="utf-8")
    values = compiled_values(command, objects.keys() | alias_targets, work, "object_extension.h")
    base_values = compiled_values(command, alias_targets, work, "vpi_user.h")
    reserved = {name: values[name] for name in objects if 1 <= values[name] <= 299}
    aliases = {name: objects[name] for name in reserved
               if objects[name] in alias_targets and values[name] == base_values[objects[name]]}
    collisions = {name: value for name, value in reserved.items() if name not in aliases}
    return {"object_type_codes": {name: values[name] for name in sorted(objects)},
            "base_aliases": aliases, "reserved_collisions": collisions}


def qualify(include: Path, compiler: str, language: str, standard: str, work: Path) -> dict:
    command = [compiler, "-x", language, f"-std={standard}", "-I", str(include)]
    base_header = '#include "vpi_user.h"\n'
    base_macros = subprocess.check_output([*command, "-E", "-dM", "-"],
                                          input=base_header, text=True, timeout=30)
    base_names = set(BASE_MACRO.findall(base_macros))
    if not {"vpiConstant", "vpiModule", "vpiReg"} <= base_names:
        raise ValueError("the base VPI object declarations were not found")
    header = (include / "sv_vpi_user.h").read_text(encoding="utf-8")
    baseline = observe(command, work, header, base_names)
    _, end = object_section(header)
    controls = "".join(f"#define {key} {value}\n" for key, value in BOUNDARY_CONTROLS.items())
    seeded = observe(command, work, header[:end] + controls + header[end:], base_names)
    codes = seeded["object_type_codes"]
    checks = {
        "extension_allocations_respect_base_reservation": not baseline["reserved_collisions"],
        "base_object_aliases_keep_their_legacy_values": bool(baseline["base_aliases"])
        and all(seeded["base_aliases"].get(name) == target for name, target in baseline["base_aliases"].items()),
        "inclusive_boundaries_detected": seeded["reserved_collisions"]
        == {**baseline["reserved_collisions"], **BOUNDARY_COLLISIONS}
        and codes["vpiBeforeBaseReservation"] == 0 and codes["vpiAfterBaseReservation"] == 300,
    }
    return {"checks": checks, "baseline": baseline,
            "boundary_codes": {name: codes[name] for name in BOUNDARY_CONTROLS},
            "boundary_collisions": seeded["reserved_collisions"], "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--headers", action="append", required=True,
                        help="named directory containing vpi_user.h and sv_vpi_user.h (NAME=PATH)")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    specs = [arg.partition("=") for arg in args.headers]
    if any(not label or not sep or not path for label, sep, path in specs):
        parser.error("--headers must use NAME=PATH")
    includes = {label: Path(path).resolve() for label, _, path in specs}
    if len(includes) != len(specs):
        parser.error("supply a unique name for each header set")
    compilers = {
        "c": (shutil.which(os.environ.get("CC", "cc")), "c11"),
        "c++": (shutil.which(os.environ.get("CXX", "c++")), "c++17"),
    }
    if not all(path for path, _ in compilers.values()):
        parser.error("C and C++ compilers are required")
    artifacts = {f"{label}/{header}": include / header for label, include in includes.items()
                 for header in ("vpi_user.h", "sv_vpi_user.h")}
    artifacts.update({language: Path(path).resolve() for language, (path, _) in compilers.items()})
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("each header set must contain both public VPI headers")
    hashes = {key: digest(path) for key, path in artifacts.items()}
    inputs, checker = suite_results.input_digest(CASES[CASE]), checker_digest()
    versions = {language: suite_results.tool_version([path, "--version"])
                for language, (path, _) in compilers.items()}
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        observations = {label: {language: qualify(include, path, language, standard, work)
                                for language, (path, standard) in compilers.items()}
                        for label, include in includes.items()}
    if (inputs != suite_results.input_digest(CASES[CASE]) or checker != checker_digest()
            or hashes != {key: digest(path) for key, path in artifacts.items()}):
        parser.exit(2, "The qualification inputs changed during execution.\n")
    passed = all(proof["pass"] for observed in observations.values() for proof in observed.values())
    report = {"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
              "compiler_versions": versions,
              "tests": {CASE: {"inputs_sha256": inputs, "headers": observations, "pass": passed}}}
    args.json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    for label, languages in observations.items():
        print(label + ": " + ", ".join(f"{language} {'PASS' if proof['pass'] else 'FAIL'}"
                                      for language, proof in languages.items()))
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

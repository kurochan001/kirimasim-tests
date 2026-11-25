#!/usr/bin/env python3
"""Qualify library map grammar and its boundary with ordinary source files."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_slang
import suite_results


CHECKER = "tools/run_slang_annex_library_map.py"
PROFILE = "slang-annex-library-map"
PATH_LISTS = "ch33/test_annex_library_map_path_lists"
SOURCE_BOUNDARY = "ch33/test_annex_library_map_source_boundary"
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (PATH_LISTS, SOURCE_BOUNDARY)}
LAYOUT = "annex_library_map/layout.map"
BOUNDARY_MAP = "annex_map_boundary/library_item.map"
NEEDS_PATH = "expected an include file name"
NEEDS_END = "expected ';'"
MAP_SYNTAX_PROBES = {
    "identifier": ("annexLib plain.sv", "42 plain.sv", "expected identifier"),
    "library_paths": ("plain.sv, computed.sv\n  -incdir first_include, second_include", "", NEEDS_PATH),
    "library_comma": ("plain.sv, computed.sv", "plain.sv computed.sv", NEEDS_END),
    "library_semicolon": ("second_include;", "second_include", NEEDS_END),
    "incdir_paths": ("first_include, second_include", "", NEEDS_PATH),
    "incdir_comma": ("first_include, second_include", "first_include second_include", NEEDS_END),
    "include_path": ("include parts/extra.map;", "include ;", NEEDS_PATH),
    "include_multiple_paths": ("include parts/extra.map;", "include parts/extra.map, parts/extra.map;", NEEDS_END),
    "include_semicolon": ("include parts/extra.map;", "include parts/extra.map", NEEDS_END),
}
EXPECTED_BINDINGS = {
    "plain_cell": ["annex_library_map/plain.sv", "13"],
    "computed_cell": ["annex_library_map/computed.sv", "41"],
    "extra_cell": ["annex_library_map/parts/extra.sv", "57"],
}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_slang.py", "tools/suite_results.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def line_of(source: str, anchor: str) -> int:
    if source.count(anchor) != 1:
        raise ValueError(f"expected one source anchor {anchor!r}")
    return source.count("\n", 0, source.index(anchor)) + 1


def compile_source(executable: Path, work: Path, top: str, *args: str) -> tuple[dict, list[dict]]:
    ast = work / "design.json"
    ast.unlink(missing_ok=True)
    try:
        process = subprocess.run([str(executable), *run_slang.OPTIONS, "--top", top,
                                  "--ast-json", ast.name, "--ast-json-source-info", *args],
                                 cwd=work, capture_output=True, text=True, timeout=45)
    except subprocess.TimeoutExpired:
        return {"returncode": None, "diagnostics": ["compiler timeout"]}, []
    errors = [(line.removeprefix(str(work) + "/"))
              for line in (process.stdout + "\n" + process.stderr).splitlines()
              if run_slang.ERROR.search(line)]
    members = json.loads(ast.read_text(encoding="utf-8"))["design"]["members"] if process.returncode == 0 else []
    return {"returncode": process.returncode, "diagnostics": errors}, members


def check_rejected(observation: dict, source: str, line: int, diagnostic: str) -> dict:
    expected = {"file": source, "line": line, "diagnostic": diagnostic}
    passed = (observation["returncode"] is not None and observation["returncode"] > 0
              and any(re.match(rf"^{re.escape(source)}:{line}:\d+: error: ", message)
                      and diagnostic in message for message in observation["diagnostics"]))
    return {**observation, "pass": passed, "expected": expected}


def selected_members(members: list[dict], name: str) -> list[dict]:
    roots = [member for member in members if member["kind"] == "Instance"]
    if len(roots) == 1 and roots[0]["name"] == name:
        return roots[0]["body"]["members"]
    return []


def check_path_lists(executable: Path, work: Path, fixture: Path) -> dict:
    layout = work / LAYOUT
    source = layout.read_text(encoding="utf-8")
    command = ("annex_layout:config", "--libmap", LAYOUT, fixture.name)
    control, members = compile_source(executable, work, *command)
    bindings = {}
    for member in selected_members(members, fixture.stem):
        if member["kind"] == "Instance":
            body = member["body"]
            origin = (work / body["source_file"]).relative_to(work).as_posix()
            values = [parameter["value"] for parameter in body["members"]
                      if parameter["kind"] == "Parameter" and parameter["name"] == "MARKER"]
            bindings[member["name"]] = [origin, *values]
    results = {"map_and_bindings": {
        **control, "bindings": bindings, "expected_bindings": EXPECTED_BINDINGS,
        "pass": control["returncode"] == 0 and not control["diagnostics"] and bindings == EXPECTED_BINDINGS,
    }}
    for name, (before, after, message) in MAP_SYNTAX_PROBES.items():
        line = line_of(source, before)
        layout.write_text(source.replace(before, after, 1), encoding="utf-8")
        trial, _ = compile_source(executable, work, *command)
        results[name] = check_rejected(trial, LAYOUT, line, message)
    return results


def check_source_boundary(executable: Path, work: Path, fixture: Path) -> dict:
    results = {}
    source = (work / fixture.name).read_text(encoding="utf-8")
    for name, options in (
        ("ordinary_source", ()),
        ("empty_map", ("--libmap", "annex_map_boundary/empty.map")),
        ("null_library_description", ("--libmap", "annex_map_boundary/null_item.map")),
        ("library_description", ("--libmap", BOUNDARY_MAP)),
    ):
        trial, members = compile_source(executable, work, fixture.stem, *options, fixture.name)
        entries = selected_members(members, fixture.stem)
        markers = [item["value"] for item in entries if item["kind"] == "Parameter"
                   and item["name"] == "SOURCE_MARKER"]
        lifetimes = [item["lifetime"] for item in entries if item["kind"] == "Variable"
                     and item["name"] == "marker"]
        passed = trial["returncode"] == 0 and not trial["diagnostics"] and markers == ["23"] and lifetimes == ["Static"]
        results[name] = {**trial, "pass": passed, "marker": markers, "lifetime": lifetimes}
    trial, _ = compile_source(executable, work, fixture.stem, "--libmap", fixture.name, fixture.name)
    results["source_as_map"] = check_rejected(trial, fixture.name,
                                             line_of(source, f"module {fixture.stem};"), "expected member")
    trial, _ = compile_source(executable, work, fixture.stem, BOUNDARY_MAP, fixture.name)
    results["map_as_source"] = check_rejected(trial, BOUNDARY_MAP, 1, "expected member")
    declaration = "  int marker = SOURCE_MARKER;"
    line = line_of(source, declaration)
    (work / fixture.name).write_text(source.replace(declaration, "  automatic int marker = SOURCE_MARKER;"),
                                    encoding="utf-8")
    trial, _ = compile_source(executable, work, fixture.stem, fixture.name)
    results["annex_a10_footnote_14"] = check_rejected(
        trial, fixture.name, line, "automatic variables can only be declared in procedural contexts")
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--slang", required=True, help="Slang compiler executable")
    parser.add_argument("--json", required=True, type=Path, help="write source qualification results")
    args = parser.parse_args()
    program = shutil.which(args.slang)
    if not program:
        parser.error("Slang compiler is unavailable")
    executable = Path(program).resolve()
    binary_hash = hashlib.sha256(executable.read_bytes()).hexdigest()
    version = suite_results.tool_version([str(executable), "--version"])
    checker_hash = checker_digest()
    fixtures = list(CASES.values())
    inputs = suite_results.fingerprints(fixtures)
    records = {}
    for case, check in ((PATH_LISTS, check_path_lists), (SOURCE_BOUNDARY, check_source_boundary)):
        fixture = CASES[case]
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory).resolve()
            for source in suite_results.input_files(fixture):
                destination = work / source.relative_to(fixture.parent)
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, destination)
            trials = check(executable, work, fixture)
        records[case] = {"inputs_sha256": inputs[case], "checks": trials}
        for name, trial in trials.items():
            if not trial["pass"]:
                print(f"{case} {name}: {trial}")
    if (binary_hash != hashlib.sha256(executable.read_bytes()).hexdigest()
            or checker_hash != checker_digest()
            or inputs != suite_results.fingerprints(fixtures)):
        parser.exit(2, "Compiler, checker or inputs changed during qualification.\n")
    passed = sum(trial["pass"] for record in records.values() for trial in record["checks"].values())
    total = sum(len(record["checks"]) for record in records.values())
    run_slang.write(args.json, {
        "profile": PROFILE, "compiler": "Slang", "version": version, "binary_sha256": binary_hash,
        "checker_sha256": checker_hash, "options": run_slang.OPTIONS,
        "passed_checks": passed, "total_checks": total, "tests": records,
    })
    print(f"{version}: {passed}/{total} grammar checks matched across {len(records)} fixtures")
    return int(passed != total)


if __name__ == "__main__":
    raise SystemExit(main())

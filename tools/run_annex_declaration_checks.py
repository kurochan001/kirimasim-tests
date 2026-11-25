#!/usr/bin/env python3
"""Qualify task port syntax and covergroup set expressions."""

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
import run_slang
import suite_results


CHECKER = "tools/run_annex_declaration_checks.py"
GHOST_PROFILE = "ghost-annex-set-expression"
SLANG_PROFILE = "slang-annex-declarations"
PORT_LIST = "ch13/test_annex_tf_identifier_list"
SET_EXPR = "ch19/test_annex_set_expression_construction"
SLANG_CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (PORT_LIST, SET_EXPR)}
GHOST_CASES = {SET_EXPR: SLANG_CASES[SET_EXPR]}
PORT_LINE = "input logic [3:0] scalar, vector[2], matrix[2][2];"
PORT_TOKENS = ["Declarator", "Comma", "Declarator", "Comma", "Declarator"]
NO_INITIALIZER = "subroutine port declaration cannot contain an initializer"
PORT_INITIALIZERS = {
    "first_initializer": ("scalar, vector[2]", "scalar = 4'd12, vector[2]", "scalar", "IntegerVectorExpression"),
    "last_initializer": ("matrix[2][2];", "matrix[2][2] = '{default:'{default:0}};",
                         "matrix", "AssignmentPatternExpression"),
}
PORT_REJECTIONS = {
    "empty_list": ("scalar, vector[2], matrix[2][2];", ";", "expected a declaration name"),
    "missing_comma": ("scalar, vector[2]", "scalar vector[2]", "expected ';'"),
    "trailing_comma": ("matrix[2][2];", "matrix[2][2],;", "misplaced trailing ','"),
}
SET_LINE = "bins selected[] = choices;"
SET_TYPE_ERROR = "invalid set covergroup expression type"
SET_REJECTIONS = {
    "associative_array": (
        (("source_values[] = '{2, 5};", "source_values[int] = '{0:2, 1:5};"),
         ("ref byte choices[]", "ref byte choices[int]")),
        (SET_TYPE_ERROR, "byte$[int]", "expected non-associative array"),
    ),
    "incompatible_elements": (
        ((SET_LINE, 'bins selected[] = incompatible_t\'(\'{"a", "b"});'),),
        (SET_TYPE_ERROR, "string$[2]"),
    ),
    "coverpoint_name": (
        ((SET_LINE, "bins selected[] = point;"),),
        ("'point'", "cannot be used in an expression", "undeclared identifier"),
    ),
    "bin_name": (
        ((SET_LINE, "bins selected[] = local_bin;"),),
        ("undeclared identifier 'local_bin'",),
    ),
}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_slang.py", "tools/run_ghost.py", "tools/suite_results.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def anchor(source: str, text: str) -> int:
    if source.count(text) != 1:
        raise ValueError(f"expected one occurrence of {text!r}")
    return source.count("\n", 0, source.index(text)) + 1


def replace(source: str, before: str, after: str) -> str:
    anchor(source, before)
    return source.replace(before, after, 1)


def execute(executable: Path, work: Path, options: list, name: str, profile: dict | None = None) -> tuple[dict, list]:
    environment = {**os.environ, **profile["environment"]} if profile else None
    process = subprocess.run([executable, *options, name], cwd=work, env=environment,
                             capture_output=True, text=True, errors="replace", timeout=45)
    transcript = run_ghost.ANSI.sub("", process.stdout + "\n" + process.stderr)
    diagnostics = [line.removeprefix(str(work) + "/") for line in transcript.splitlines()
                   if re.search(r"\berror(?: \[E\d+\])?: ", line)]
    output = run_ghost.normalize(process.stdout, profile).splitlines() if profile else []
    return {"returncode": process.returncode, "diagnostics": diagnostics}, output


def expected_rejection(trial: dict, filename: str, line: int, markers: tuple[str, ...]) -> bool:
    return trial["returncode"] > 0 and any(
        re.match(rf"^{re.escape(filename)}:{line}:\d+: error(?: \[E\d+\])?: ", message)
        and all(marker in message for marker in markers) for message in trial["diagnostics"])


def syntax_nodes(value, kind: str):
    if isinstance(value, dict):
        if value.get("kind") == kind:
            yield value
        for child in value.values():
            yield from syntax_nodes(child, kind)
    elif isinstance(value, list):
        for child in value:
            yield from syntax_nodes(child, kind)


def ports(cst: dict) -> dict:
    tasks = {}
    for task in syntax_nodes(cst, "TaskDeclaration"):
        name = task["prototype"]["name"]["identifier"]["text"]
        declarations = []
        for item in task["items"]:
            if item["kind"] == "PortDeclaration":
                tokens = item["declarators"]
                declarations.append({
                    "tokens": [token["kind"] for token in tokens],
                    "ports": [[token["name"]["text"], len(token.get("dimensions", [])),
                               token.get("initializer", {}).get("expr", {}).get("kind")]
                              for token in tokens if token["kind"] == "Declarator"],
                })
        tasks[name] = declarations
    return tasks


def check_ports(executable: Path, work: Path, fixture: Path) -> dict:
    source = fixture.read_text(encoding="utf-8")
    probe = work / fixture.name
    cst = work / "ports.json"
    site = anchor(source, PORT_LINE)
    parse = [*run_slang.OPTIONS, "--parse-only", "--cst-json", cst.name]
    elaborate = [*run_slang.OPTIONS, "--top", fixture.stem]
    records = {}
    versions = {"control": source}
    versions.update({name: replace(source, before, after)
                     for name, (before, after, _, _) in PORT_INITIALIZERS.items()})
    for name, text in versions.items():
        initializer = PORT_INITIALIZERS.get(name)
        expected = {
            "show_single": [{"tokens": ["Declarator"], "ports": [["only_arg", 0, None]]}],
            "show_many": [{"tokens": PORT_TOKENS, "ports": [
                [port, rank, initializer[3] if initializer and initializer[2] == port else None]
                for rank, port in enumerate(("scalar", "vector", "matrix"))]}],
        }
        probe.write_text(text, encoding="utf-8")
        cst.unlink(missing_ok=True)
        trial, _ = execute(executable, work, parse, probe.name)
        found = ports(json.loads(cst.read_text(encoding="utf-8"))) if trial["returncode"] == 0 and cst.is_file() else {}
        records[name + "_syntax"] = {**trial, "pass": trial["returncode"] == 0 and found == expected,
                                     "ports": found, "expected_ports": expected}
        trial, _ = execute(executable, work, elaborate, probe.name)
        passed = (expected_rejection(trial, probe.name, site, (NO_INITIALIZER,))
                  if initializer else trial["returncode"] == 0 and not trial["diagnostics"])
        records[name + "_semantic"] = {**trial, "pass": passed}
    for name, (before, after, message) in PORT_REJECTIONS.items():
        probe.write_text(replace(source, before, after), encoding="utf-8")
        trial, _ = execute(executable, work, parse, probe.name)
        records[name] = {**trial, "pass": expected_rejection(trial, probe.name, site, (message,)),
                         "expected_line": site, "expected_diagnostic": message}
    return records


def check_sets(executable: Path, work: Path, fixture: Path, profile: dict | None) -> dict:
    source = fixture.read_text(encoding="utf-8")
    probe = work / fixture.name
    site = anchor(source, SET_LINE)
    options = ([*profile["arguments"], "-top", fixture.stem] if profile
               else [*run_slang.OPTIONS, "--top", fixture.stem])
    probe.write_text(source, encoding="utf-8")
    trial, output = execute(executable, work, options, probe.name, profile)
    expected = suite_results.expected_output(fixture).splitlines() if profile else []
    records = {"control": {**trial, "stdout": output, "expected_stdout": expected,
                           "pass": trial["returncode"] == 0 and not trial["diagnostics"] and output == expected}}
    for name, (edits, markers) in SET_REJECTIONS.items():
        changed = source
        for before, after in edits:
            changed = replace(changed, before, after)
        # The two Slang drivers use different diagnostics for a coverpoint reference.
        messages = (markers[:1] + (markers[2] if profile else markers[1],)
                    if name == "coverpoint_name" else markers)
        probe.write_text(changed, encoding="utf-8")
        trial, output = execute(executable, work, options, probe.name, profile)
        passed = (expected_rejection(trial, probe.name, site, messages)
                  and not any(line.startswith("sample=") for line in output))
        records[name] = {**trial, "pass": passed, "expected_line": site, "expected_diagnostics": messages}
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=("ghost", "slang"), required=True)
    parser.add_argument("--executable", required=True)
    parser.add_argument("--observations", type=Path, required=True)
    parser.add_argument("--profile", type=Path, help="Ghost runtime profile")
    parser.add_argument("--results", type=Path, help="Ghost behavioral coverage snapshot")
    args = parser.parse_args()
    program = shutil.which(args.executable)
    if not program:
        parser.error("compiler executable is unavailable")
    if args.tool == "ghost" and (not args.profile or not args.results):
        parser.error("Ghost requires both --profile and --results")
    executable = Path(program).resolve()
    profile_bytes = args.profile.read_bytes() if args.tool == "ghost" else None
    profile = json.loads(profile_bytes) if profile_bytes is not None else None
    if profile is not None and "--lrm-strict" not in profile["arguments"]:
        parser.error("Ghost requires --lrm-strict for the diagnostic controls")
    binary_hash = hashlib.sha256(executable.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost") if profile else None
    version = f"private build {binary_hash[:12]}" if profile else suite_results.tool_version([str(executable), "--version"])
    cases = GHOST_CASES if profile else SLANG_CASES
    fixtures = list(cases.values())
    inputs = suite_results.fingerprints(fixtures)
    records = {}
    for case, fixture in cases.items():
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory).resolve()
            trials = (check_ports(executable, work, fixture) if case == PORT_LIST
                      else check_sets(executable, work, fixture, profile))
        records[case] = {"inputs_sha256": inputs[case], "checks": trials}
        for name, trial in trials.items():
            if not trial["pass"]:
                print(f"{case} {name}: {trial}")
    if (hashlib.sha256(executable.read_bytes()).hexdigest() != binary_hash or checker_digest() != checker_hash
            or suite_results.fingerprints(fixtures) != inputs
            or (profile and (args.profile.read_bytes() != profile_bytes
                             or suite_results.runner_digest("ghost") != runner_hash))):
        parser.exit(2, "Executable, checker, profile or test inputs changed during qualification.\n")
    configuration = {"evidence_profile": GHOST_PROFILE if profile else SLANG_PROFILE,
                     "checker_sha256": checker_hash, "binary_sha256": binary_hash}
    if profile:
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
        passed = all(trial["pass"] for trial in records[SET_EXPR]["checks"].values())
        suite_results.write(args.results, "ghost", "Ghost", version,
                            {SET_EXPR: ("pass", "") if passed else ("fail", "set expression check differed")},
                            inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    passed = sum(trial["pass"] for record in records.values() for trial in record["checks"].values())
    total = sum(len(record["checks"]) for record in records.values())
    run_slang.write(args.observations, {
        "tool": args.tool, "version": version, "configuration": configuration,
        "passed_checks": passed, "total_checks": total, "tests": records,
    })
    print(f"{version}: {passed}/{total} declaration checks matched")
    return int(passed != total)


if __name__ == "__main__":
    raise SystemExit(main())

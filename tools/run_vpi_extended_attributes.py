#!/usr/bin/env python3
"""Observe attribute VPI relationships on real owners with controlled metadata."""

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


CHECKER = "tools/run_vpi_extended_attributes.py"
PROFILE = "ghost-extended-attribute-reference"
CASE = "ch37/test_vpi_extended_attribute_owners"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
OWNER_KINDS = ("primitive-terminal", "path-terminal", "module-path", "timing-check", "table-entry")
SOURCE_MUTATIONS = {
    "path-terminal": ("    (a => y) = 7;", "    ((* term_mark = 7 *) a => y) = 7;"),
    "module-path": ("    (a => y) = 7;", "    (* path_mark = 7 *) (a => y) = 7;"),
    "timing-check": ("    $setup(a, posedge b, 2);", "    (* check_mark = 7 *) $setup(a, posedge b, 2);"),
    "table-entry": ("    0 ? : 0;", "    (* row_mark = 7 *) 0 ? : 0;"),
}
CONTRAST_CHANGES = {
    "path-terminal first count=2 names=2 values=2 parent=2 sibling=0":
        "path-terminal first count=2 names=2 values=2 parent=1 sibling=1",
    "module-path first count=2 names=2 values=2 parent=2 sibling=0":
        "module-path first count=1 names=1 values=1 parent=1 sibling=0",
    "module-path second count=1 names=1 values=1 parent=1 sibling=0":
        "module-path second count=2 names=1 values=1 parent=1 sibling=0",
}


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER) + suite_results.runner_digest("ghost")).encode()).hexdigest()


def headers_digest(include: Path) -> str:
    headers = {path.relative_to(include).as_posix(): digest(path) for path in (include / "sukimasim").rglob("*.h")}
    if not headers:
        raise ValueError("matching Ghost headers are required")
    return hashlib.sha256(json.dumps(headers, sort_keys=True).encode()).hexdigest()


def execute(args: list, work: Path, timeout: int = 60, env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(args, cwd=work, env=env, timeout=timeout, capture_output=True, text=True, errors="replace")


def build(args: list, work: Path) -> None:
    result = execute(args, work)
    if result.returncode:
        raise ValueError(f"could not build the VPI application: {result.stderr.strip()}")


def observe(tools: dict, include: Path, profile: dict, fixture: Path, work: Path) -> dict:
    files = fixture.parent / "vpi_extended_attributes"
    app = files / "client.c"
    bridge = files / "seed.cpp"
    includes = [f"-I{include}", *(f"-I{include / name}" for name in profile["include_subdirs"])]
    linkage = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    library = work / "native.so"
    seeded = work / "seeded.so"
    compiled_client = work / "seed-client.o"
    build([tools["cc"], "-shared", "-fPIC", *linkage, *includes, "-o", library, app], work)
    build([tools["cc"], "-fPIC", "-DSEED_EXTENDED_ATTRIBUTES", *includes,
           "-c", app, "-o", compiled_client], work)
    build([tools["cxx"], "-std=c++20", "-shared", "-fPIC", "-DSEED_EXTENDED_ATTRIBUTES",
           *linkage, *includes, bridge, compiled_client, "-o", seeded], work)

    environment = {**os.environ, **profile["environment"]}
    command = [tools["ghost"], *profile["arguments"], "-top", fixture.stem]

    def simulate(source: Path, plugin: Path, *extra: str) -> subprocess.CompletedProcess:
        return execute([*command, "--lib", plugin, source, *extra], work, env=environment)

    def trace(process: subprocess.CompletedProcess) -> dict:
        completed = any(line.startswith(profile["trailer"]) for line in process.stdout.splitlines())
        return {"exit": process.returncode, "completed": completed,
                "output": run_ghost.normalize(process.stdout, profile).splitlines()}

    ordinary = suite_results.expected_output(fixture).splitlines()
    model = (files / "seeded.expected").read_text(encoding="utf-8").splitlines()
    if not set(CONTRAST_CHANGES) <= set(model):
        raise ValueError("the seeded oracle must contain the rows changed by the contrast")
    contrast = [CONTRAST_CHANGES.get(line, line) for line in model]
    trials = {
        "ordinary": trace(simulate(fixture, library)),
        "source_terminal_attribute": trace(simulate(fixture, library, "+define+ATTRIBUTE_ON_GATE_TERMINAL")),
        "seeded": trace(simulate(fixture, seeded)),
        "contrast": trace(simulate(fixture, seeded, "+contrast_attribute_relations")),
    }
    expected = {"ordinary": ordinary, "seeded": model, "contrast": contrast}
    checks = {f"{kind}_trace_matches": trials[kind] == {"exit": 0, "completed": True, "output": output}
              for kind, output in expected.items()}
    checks["contrast_rejects_wrong_forward_and_reverse_edges"] = (
        checks["contrast_trace_matches"] and trials["contrast"]["output"] != trials["seeded"]["output"])

    def analyze(source: Path, *extra: str) -> subprocess.CompletedProcess:
        return execute([tools["slang"], "--std=1800-2023", "--define-system-task", "$vt_extended_attributes",
                        "--top", fixture.stem, *extra, source], work)

    grammar = {
        "ordinary": {"slang_exit": analyze(fixture).returncode},
        "primitive-terminal": {"slang_exit": analyze(fixture, "-DATTRIBUTE_ON_GATE_TERMINAL").returncode,
                               "ghost_exit": trials["source_terminal_attribute"]["exit"]},
    }
    text = fixture.read_text(encoding="utf-8")
    for label, (before, after) in SOURCE_MUTATIONS.items():
        if text.count(before) != 1:
            raise ValueError(f"source mutation site for {label} is ambiguous")
        source = work / f"{label}.sv"
        source.write_text(text.replace(before, after), encoding="utf-8")
        line = text[:text.index(before)].count("\n") + 1
        modes = {"slang": analyze(source), "ghost": simulate(source, library)}
        diagnostics = {}
        for tool, result in modes.items():
            location = re.compile(rf"{re.escape(source.name)}:{line}:\d+: error:")
            errors = (result.stdout + "\n" + result.stderr).splitlines()
            diagnostics[tool] = {"exit": result.returncode,
                                 "diagnosed_at_annotation": any(location.search(raw) for raw in errors)}
        grammar[label] = {"line": line, **diagnostics}
    checks["grammar_controls_are_qualified"] = (
        grammar["ordinary"]["slang_exit"] == 0
        and all(grammar[kind][tool]["exit"] == 0 or grammar[kind][tool]["diagnosed_at_annotation"]
                for kind in SOURCE_MUTATIONS for tool in ("ghost", "slang")))
    checks["all_five_owner_kinds_checked"] = all(
        any(line.startswith(f"{kind} first ") for line in model)
        and any(line.startswith(f"{kind} second ") for line in model)
        for kind in OWNER_KINDS)
    return {"trials": trials, "grammar": grammar, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    tool_paths = {key: shutil.which(value) for key, value in {
        "ghost": args.ghost, "slang": args.slang, "cc": os.environ.get("CC", "cc"),
        "cxx": os.environ.get("CXX", "c++"),
    }.items()}
    if not all(tool_paths.values()):
        parser.error("Ghost, Slang, and C/C++ compilers are required")
    tools = {name: Path(path).absolute() for name, path in tool_paths.items()}
    include = args.include.resolve()
    fixture = CASES[CASE]
    checker, inputs = checker_digest(), suite_results.input_digest(fixture)
    try:
        profile_bytes = args.profile.read_bytes()
        profile = json.loads(profile_bytes)
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        artifacts = {name: digest(path) for name, path in tools.items()}
        artifacts["ghost_headers"] = headers_digest(include)
        with tempfile.TemporaryDirectory() as directory:
            result = observe(tools, include, profile, fixture, Path(directory))
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI attribute qualification stopped: {error}\n")
    if (any(artifacts[name] != digest(path) for name, path in tools.items())
            or artifacts["ghost_headers"] != headers_digest(include) or profile_bytes != args.profile.read_bytes()
            or checker != checker_digest() or inputs != suite_results.input_digest(fixture)):
        parser.exit(2, "qualification inputs changed during the run\n")
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": checker, "artifact_sha256": artifacts,
        "ghost": f"private build {artifacts['ghost'][:12]}",
        "slang": suite_results.tool_version([str(tools["slang"]), "--version"]),
        "runtime_profile_sha256": hashlib.sha256(profile_bytes).hexdigest(),
        "tests": {CASE: {"inputs_sha256": inputs, **result}},
    }, indent=2) + "\n")
    for name, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {name}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Observe interface ownership edges with native VPI lookups over controlled metadata."""

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
import run_vpi_extended_attributes as helpers
import suite_results


CHECKER = "tools/run_vpi_interface_ownership.py"
PROFILE = "ghost-interface-ownership-reference"
CASE = "ch37/test_vpi_interface_ownership"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
GRAMMAR = {
    "DIRECT_INTERFACE_SPECIFY": ("    (a => y) = 7;", "  specify"),
    "DIRECT_PROGRAM_CHILDREN": ("  owner_link scalar_child", "  owner_link array_child"),
}
LEGACY_CONTRAST = {
    "left paths=2 typed=2 endpoints=3 owner=2 sibling=0 legacy=0 null=2 ancestor=0":
        "left paths=2 typed=2 endpoints=3 owner=2 sibling=0 legacy=0 null=0 ancestor=2",
    "right paths=1 typed=1 endpoints=2 owner=1 sibling=0 legacy=0 null=1 ancestor=0":
        "right paths=1 typed=1 endpoints=2 owner=1 sibling=0 legacy=0 null=0 ancestor=1",
}


def checker_digest() -> str:
    digest = helpers.digest(suite_results.ROOT / CHECKER)
    return hashlib.sha256((digest + helpers.checker_digest()).encode()).hexdigest()


def observe(tools: dict, include: Path, profile: dict, fixture: Path, work: Path) -> dict:
    files = fixture.parent / "vpi_interface_ownership"
    app = files / "client.c"
    bridge = files / "seed.cpp"
    includes = [f"-I{include}", *(f"-I{include / name}" for name in profile["include_subdirs"])]
    linkage = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    native, model, object_file = (work / name for name in ("native.so", "seeded.so", "client.o"))
    helpers.build([tools["cc"], "-shared", "-fPIC", *linkage, *includes, "-o", native, app], work)
    helpers.build([tools["cc"], "-fPIC", "-DSEED_INTERFACE_OWNERSHIP", *includes,
                   "-c", app, "-o", object_file], work)
    helpers.build([tools["cxx"], "-std=c++20", "-shared", "-fPIC", "-DSEED_INTERFACE_OWNERSHIP",
                   *linkage, *includes, bridge, object_file, "-o", model], work)

    environment = {**os.environ, **profile["environment"]}
    base = [tools["ghost"], *profile["arguments"], "-top", fixture.stem]

    def run(plugin: Path, *extra: str) -> subprocess.CompletedProcess:
        return helpers.execute([*base, "--lib", plugin, fixture, *extra], work, env=environment)

    def trace(plugin: Path, *extra: str) -> dict:
        process = run(plugin, *extra)
        return {"exit": process.returncode,
                "completed": any(line.startswith(profile["trailer"]) for line in process.stdout.splitlines()),
                "output": run_ghost.normalize(process.stdout, profile).splitlines()}

    def analyze(*extra: str) -> subprocess.CompletedProcess:
        return helpers.execute([tools["slang"], "--std=1800-2023", "--top", fixture.stem,
                                "--define-system-task", "$vt_interface_owners", *extra, fixture], work)

    ordinary = suite_results.expected_output(fixture).splitlines()
    seeded = (files / "seeded.expected").read_text(encoding="utf-8").splitlines()
    if not set(LEGACY_CONTRAST) <= set(seeded):
        raise ValueError("the seeded oracle must include both interface legacy observations")
    expected = {"native": ordinary, "seeded": seeded,
                "legacy_fallback": [LEGACY_CONTRAST.get(line, line) for line in seeded]}
    trials = {"native": trace(native), "seeded": trace(model),
              "legacy_fallback": trace(model, "+path_parent_fallback")}
    checks = {f"{kind}_trace_matches": trials[kind] == {"exit": 0, "completed": True, "output": output}
              for kind, output in expected.items()}
    checks["legacy_fallback_is_distinguished"] = (
        checks["legacy_fallback_trace_matches"]
        and trials["seeded"]["output"] != trials["legacy_fallback"]["output"])
    grammar = {"native": {"slang_exit": analyze().returncode}}
    source = fixture.read_text(encoding="utf-8").splitlines()
    for macro, prefixes in GRAMMAR.items():
        matches = [i for i, line in enumerate(source, 1) if line.startswith(prefixes)]
        if not matches:
            raise ValueError(f"no source comparison for {macro}")
        alternatives = {"slang": analyze(f"-D{macro}"), "ghost": run(native, f"+define+{macro}")}
        for tool, process in alternatives.items():
            diagnostics = run_ghost.ANSI.sub("", process.stdout + "\n" + process.stderr)
            locations = sorted({int(m[1]) for m in re.finditer(rf"{re.escape(fixture.name)}:(\d+):\d+:[ ]+error",
                                                              diagnostics)})
            grammar.setdefault(macro, {})[tool] = {"exit": process.returncode,
                "diagnostics_at_candidate_lines": [line for line in locations if line in matches]}
    checks["source_comparisons_are_observed"] = (
        grammar["native"]["slang_exit"] == 0 and all(
            item["exit"] == 0 or item["diagnostics_at_candidate_lines"]
            for macro in GRAMMAR for item in grammar[macro].values()))
    return {"trials": trials, "grammar": grammar, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    tool_paths = {name: shutil.which(value) for name, value in {
        "ghost": args.ghost, "slang": args.slang, "cc": os.environ.get("CC", "cc"),
        "cxx": os.environ.get("CXX", "c++"),
    }.items()}
    if not all(tool_paths.values()):
        parser.error("Ghost, Slang, and C/C++ compilers are required")
    tools = {name: Path(path).absolute() for name, path in tool_paths.items()}
    include, fixture = args.include.resolve(), CASES[CASE]
    checker, inputs = checker_digest(), suite_results.input_digest(fixture)
    try:
        profile_bytes = args.profile.read_bytes()
        profile = json.loads(profile_bytes)
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        artifacts = {name: helpers.digest(path) for name, path in tools.items()}
        artifacts["ghost_headers"] = helpers.headers_digest(include)
        with tempfile.TemporaryDirectory() as directory:
            result = observe(tools, include, profile, fixture, Path(directory))
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI ownership qualification stopped: {error}\n")
    if (any(artifacts[name] != helpers.digest(path) for name, path in tools.items())
            or artifacts["ghost_headers"] != helpers.headers_digest(include)
            or profile_bytes != args.profile.read_bytes() or checker != checker_digest()
            or inputs != suite_results.input_digest(fixture)):
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

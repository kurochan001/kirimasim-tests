#!/usr/bin/env python3
"""Compare public VPI parent lookup on native and controlled task/function views."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import run_vpi_extended_attributes as helpers
from run_vpi_pattern_constraint_properties import nodes
import suite_results


CHECKER = "tools/run_vpi_task_reference_parent.py"
PROFILE = "ghost-task-reference-parent"
CASE = "ch37/test_vpi_task_reference_parent"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
EXPECTED_ARGUMENTS = {
    "adjust": {"kind": "Task", "direction": "Ref", "const": False},
    "inspect": {"kind": "Function", "direction": "Ref", "const": True},
    "plain": {"kind": "Function", "direction": "In", "const": False},
}


def checker_digest() -> str:
    files = (CHECKER, "tools/run_vpi_extended_attributes.py", "tools/run_vpi_pattern_constraint_properties.py")
    digests = [helpers.digest(suite_results.ROOT / path) for path in files]
    return hashlib.sha256("".join([*digests, suite_results.runner_digest("ghost")]).encode()).hexdigest()


def observe(tools: dict, include: Path, profile: dict, test: Path, work: Path) -> dict:
    files = test.parent / "vpi_task_reference_parent"
    ast = work / "design.json"
    analyzed = helpers.execute([tools["slang"], "--std=1800-2023", "--define-system-task", "$vt_tf_reference",
                                "--top", test.stem, "--ast-json", ast, test], work)
    if analyzed.returncode:
        raise ValueError(f"Slang could not analyze the declarations: {analyzed.stderr.strip()}")
    arguments = {}
    for declaration in nodes(json.loads(ast.read_text())):
        name = declaration.get("name")
        if declaration.get("kind") != "Subroutine" or name not in EXPECTED_ARGUMENTS:
            continue
        if name in arguments:
            raise ValueError(f"duplicate declaration: {name}")
        formal, = declaration["arguments"]
        arguments[name] = {"kind": declaration["subroutineKind"], "direction": formal["direction"],
                           "const": "const" in formal.get("flags", "").split(","), "formal": formal["name"]}

    includes = [f"-I{include}", *(f"-I{include / name}" for name in profile["include_subdirs"])]
    linkage = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    client = test.with_suffix(".c")
    environment = {**os.environ, **profile["environment"]}
    trials, checks = {}, {}
    for trial in ("native", "seeded", "swapped"):
        library = work / f"{trial}.so"
        if trial == "native":
            helpers.build([tools["cc"], "-shared", "-fPIC", *linkage, *includes, client, "-o", library], work)
            expected = suite_results.expected_output(test)
        else:
            obj = work / f"{trial}.o"
            flags = ["-DSEED_REFERENCE_PARENT"]
            if trial == "swapped":
                flags.append("-DSWAP_REFERENCE_PARENTS")
            helpers.build([tools["cc"], "-fPIC", *flags, *includes, "-c", client, "-o", obj], work)
            helpers.build([tools["cxx"], "-std=c++20", "-shared", "-fPIC", *linkage, *includes,
                           files / "seed.cpp", obj, "-o", library], work)
            expected = (files / f"{trial}.expected").read_text()
        simulated = helpers.execute([tools["ghost"], *profile["arguments"], "--lib", library,
                                     "-top", test.stem, test], work, env=environment)
        trials[trial] = {"exit": simulated.returncode,
                         "completed": any(line.startswith(profile["trailer"])
                                          for line in simulated.stdout.splitlines()),
                         "output": run_ghost.normalize(simulated.stdout, profile).splitlines()}
        checks[f"{trial}_trace_matches"] = trials[trial] == {
            "exit": 0, "completed": True, "output": expected.splitlines(),
        }
    checks["parsed_formal_directions_and_names"] = arguments == {
        name: {**info, "formal": "bound"} for name, info in EXPECTED_ARGUMENTS.items()
    }
    checks["swapped_parents_are_detected"] = trials["seeded"]["output"] != trials["swapped"]["output"]
    return {"checks": checks, "slang_arguments": arguments, "trials": trials, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    executables = {"ghost": args.ghost, "slang": args.slang,
                   "cc": os.environ.get("CC", "cc"), "cxx": os.environ.get("CXX", "c++")}
    paths = {name: shutil.which(path) for name, path in executables.items()}
    if not all(paths.values()):
        parser.error("Ghost, Slang, and C/C++ compilers are required")
    tools = {name: Path(path).absolute() for name, path in paths.items()}
    include, test = args.include.resolve(), CASES[CASE]
    try:
        def provenance():
            return {"checker_sha256": checker_digest(), "inputs_sha256": suite_results.input_digest(test),
                    "profile_sha256": helpers.digest(args.profile),
                    "artifact_sha256": {**{name: helpers.digest(path) for name, path in tools.items()},
                                        "ghost_headers": helpers.headers_digest(include)}}

        before = provenance()
        profile = json.loads(args.profile.read_bytes())
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        with tempfile.TemporaryDirectory() as directory:
            result = observe(tools, include, profile, test, Path(directory))
        if before != provenance():
            raise ValueError("qualification inputs changed during the run")
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI reference-parent qualification stopped: {error}\n")
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": before["checker_sha256"],
        "runtime_profile_sha256": before["profile_sha256"], "artifact_sha256": before["artifact_sha256"],
        "slang": suite_results.tool_version([str(tools["slang"]), "--version"]),
        "tests": {CASE: {"inputs_sha256": before["inputs_sha256"], **result}},
    }, indent=2) + "\n")
    for name, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {name}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

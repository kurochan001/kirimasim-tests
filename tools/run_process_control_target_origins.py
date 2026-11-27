#!/usr/bin/env python3
"""Compare process-origin checks with operations on the same live Ghost handles."""

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


CHECKER = "tools/run_process_control_target_origins.py"
PROFILE = "ghost-process-origin-reference"
CASE = "ch9/test_process_control_target_origins"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
DIAGNOSTIC_REQUIREMENTS = {"SV2023-9.7-EXTRACT-CONTROL-TARGET-RESTRICTION"}
DIAGNOSTIC_ANCHOR = "excluded process origin"


def checker_digest() -> str:
    hashes = helpers.digest(suite_results.ROOT / CHECKER) + helpers.checker_digest()
    return hashlib.sha256(hashes.encode()).hexdigest()


def read_origins(ast: dict) -> dict:
    """Extract the procedure and enclosing fork branch for each instrumented handle."""
    origins = {}

    def walk(node, procedure=None, scope=None, parent_scope=None):
        if isinstance(node, list):
            for item in node:
                walk(item, procedure, scope, parent_scope)
            return
        if not isinstance(node, dict):
            return
        if node.get("kind") == "ProceduralBlock":
            walk(node["body"], node["procedureKind"], id(node))
            return
        if node.get("kind") == "Block" and node.get("blockKind", "").startswith("Join"):
            body = node["body"]
            branches = body["list"] if body["kind"] == "List" else [body]
            for branch in branches:
                walk(branch, procedure, id(branch), scope)
            return
        if node.get("kind") == "List":
            statements = node["list"]
            for index, statement in enumerate(statements):
                expression = statement.get("expr", {})
                if expression.get("subroutine") != "$observe_process":
                    walk(statement, procedure, scope, parent_scope)
                    continue
                argument, = expression["arguments"]
                label = argument.get("literal", "")
                assignment = statements[index - 1].get("expr", {}) if index else {}
                left, right = assignment.get("left", {}), assignment.get("right", {})
                if (procedure not in {"Initial", "Always", "Final"} or scope in origins
                        or not re.fullmatch(r"[a-z_]+", label) or assignment.get("kind") != "Assignment"
                        or left.get("symbol", "").split(" ")[-1] != label
                        or right.get("kind") != "Call" or right.get("subroutine", "").split(" ")[-1] != "self"
                        or not right.get("type", "").endswith(" process")):
                    raise ValueError("process capture must follow an assignment from process::self in its origin")
                origins[scope] = (label, procedure, parent_scope)
            return
        if node.get("subroutine") == "$observe_process":
            raise ValueError("process capture appeared outside the instrumented statement list")
        for value in node.values():
            walk(value, procedure, scope, parent_scope)

    walk(ast)
    result = {}
    for label, procedure, parent in origins.values():
        if label in result:
            raise ValueError(f"duplicate capture label {label}")
        if parent is None:
            result[label] = {"kind": procedure, "parent": "-"}
        else:
            parent_label = origins[parent][0]
            if parent_label not in result:
                raise ValueError(f"fork parent for {label} must be captured before the child")
            result[label] = {"kind": "Fork", "parent": parent_label}
    if sum(row["kind"] == "Final" for row in result.values()) != 1:
        raise ValueError("expected one final-origin capture")
    return result


def observe(tools: dict, include: Path, profile: dict, source: Path, work: Path) -> dict:
    fixtures = source.parent / "process_control_target_origins"
    ast = work / "origins.json"
    analysis = helpers.execute([tools["slang"], "--std=1800-2023", "--define-system-task", "$observe_process",
                                "-DOBSERVE_ORIGIN", "--top", source.stem, "--ast-json", ast, source], work)
    if analysis.returncode:
        raise ValueError(f"Slang could not analyze the origin fixture: {analysis.stderr.strip()}")
    origins = read_origins(json.loads(ast.read_text()))
    declarations = [
        "struct Origin { const char *name; const char *kind; const char *parent; };",
        "static constexpr Origin origins[] = {",
        *(f'    {{"{label}", "{row["kind"]}", "{row["parent"]}"}},' for label, row in origins.items()),
        "};",
    ]
    (work / "origins.h").write_text("\n".join(declarations) + "\n")
    linkage = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    environment = {**os.environ, **profile["environment"]}

    trials, checks = {}, {}
    for name, flags in (("plain", []), ("guarded", []), ("unguarded", ["-DBYPASS_ORIGIN_GUARD"])):
        command = [tools["ghost"], *profile["arguments"], "-top", source.stem, source]
        if name == "plain":
            expected = suite_results.expected_output(source)
        else:
            library = work / f"{name}.so"
            helpers.build([tools["cxx"], "-std=c++20", "-shared", "-fPIC", *linkage,
                           f"-I{include}", f"-I{work}", *flags, fixtures / "probe.cpp", "-o", library], work)
            command.extend(["--lib", library, "+define+OBSERVE_ORIGIN"])
            expected = (fixtures / f"{name}.expected").read_text()
        trial = helpers.execute(command, work, env=environment)
        trials[name] = {"exit": trial.returncode,
                        "completed": any(line.startswith(profile["trailer"]) for line in trial.stdout.splitlines()),
                        "output": run_ghost.normalize(trial.stdout, profile).splitlines()}
        checks[f"{name}_trace_matches"] = trials[name] == {
            "exit": 0, "completed": True, "output": expected.splitlines(),
        }
    methods = ("await", "suspend", "resume", "kill")
    checks["all_methods_reject_the_same_excluded_process"] = all(
        f"{method} rejected: {DIAGNOSTIC_ANCHOR}" in trials["guarded"]["output"]
        and any(line.startswith(f"{method} reached target ") for line in trials["unguarded"]["output"])
        for method in methods)
    return {"origins": origins, "trials": trials, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    paths = {name: shutil.which(executable) for name, executable in {
        "ghost": args.ghost, "slang": args.slang, "cxx": os.environ.get("CXX", "c++"),
    }.items()}
    if not all(paths.values()):
        parser.error("Ghost, Slang, and a C++ compiler are required")
    tools = {name: Path(path).absolute() for name, path in paths.items()}
    source, include = CASES[CASE], args.include.resolve()

    def provenance():
        return {"checker_sha256": checker_digest(), "inputs_sha256": suite_results.input_digest(source),
                "runtime_profile_sha256": helpers.digest(args.profile),
                "artifact_sha256": {**{name: helpers.digest(path) for name, path in tools.items()},
                                    "ghost_headers": helpers.headers_digest(include)}}

    try:
        before = provenance()
        profile = json.loads(args.profile.read_bytes())
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        with tempfile.TemporaryDirectory() as directory:
            result = observe(tools, include, profile, source, Path(directory))
        if before != provenance():
            raise ValueError("qualification inputs changed during the run")
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"process-origin qualification stopped: {error}\n")
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": before["checker_sha256"],
        "runtime_profile_sha256": before["runtime_profile_sha256"], "artifact_sha256": before["artifact_sha256"],
        "slang": suite_results.tool_version([str(tools["slang"]), "--version"]),
        "tests": {CASE: {"inputs_sha256": before["inputs_sha256"], **result}},
    }, indent=2) + "\n")
    for check, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {check}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

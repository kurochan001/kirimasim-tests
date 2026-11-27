#!/usr/bin/env python3
"""Verify virtual constraint and structure member properties from parsed HDL."""

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
import suite_results


CHECKER = "tools/run_vpi_pattern_constraint_properties.py"
PROFILE = "ghost-pattern-constraint-reference"
CASE = "ch37/test_vpi_pattern_constraint_properties"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
SWAP = {
    "structure binding=first member=left": "structure binding=first member=right",
    "structure binding=second member=right": "structure binding=second member=left",
    "matched first=19 second=31": "matched first=30 second=20",
}


def checker_digest() -> str:
    checksum = helpers.digest(suite_results.ROOT / CHECKER)
    return hashlib.sha256((checksum + helpers.checker_digest()).encode()).hexdigest()


def nodes(tree):
    if isinstance(tree, dict):
        yield tree
        for child in tree.values():
            yield from nodes(child)
    elif isinstance(tree, list):
        for child in tree:
            yield from nodes(child)


def one(items, context: str):
    candidates = list(items)
    if len(candidates) != 1:
        raise ValueError(f"expected one {context}, found {len(candidates)}")
    return candidates[0]


def read_constraint_flags(ast: dict) -> dict:
    expected = {"pure_owner": "pending", "fixed_control": "permanent", "implementation_owner": "pending"}
    result = {}
    for class_name, constraint_name in expected.items():
        cls = one((node for node in nodes(ast) if node.get("kind") == "ClassType" and node.get("name") == class_name),
                  f"class {class_name}")
        constraint = one((node for node in cls["members"] if node.get("kind") == "ConstraintBlock"
                          and node.get("name") == constraint_name), f"constraint {class_name}.{constraint_name}")
        result[class_name] = {"name": constraint_name, "abstract": cls["isAbstract"],
                              "flags": sorted(filter(None, constraint.get("flags", "").split(",")))}
    return result


def named_children(pattern: dict) -> list[dict]:
    return [member for member in pattern.get("members", []) if member.get("kind") == "NamedStructurePatternMember"]


def read_pattern_members(cst: dict) -> dict[str, str]:
    outer = one((node for node in nodes(cst) if node.get("kind") == "StructurePattern"
                 and len(named_children(node)) == 2
                 and all(child["pattern"].get("kind") == "StructurePattern" for child in named_children(node))),
                "outer structure with two named nested patterns")
    result = {}
    for member in named_children(outer):
        nested = one(named_children(member["pattern"]), "named member of the nested pattern")
        binding = nested["pattern"]
        if binding.get("kind") != "VariablePattern":
            raise ValueError("expected the named member to bind a variable")
        variable = binding["variableName"]["text"]
        if variable in result:
            raise ValueError("a binding variable was repeated")
        result[variable] = member["name"]["text"]
    return result


def metadata_header(flags: dict, members: dict, output: Path) -> None:
    pure = flags["pure_owner"]
    fixed = flags["fixed_control"]
    implemented = flags["implementation_owner"]
    if (not pure["abstract"] or "pure" not in pure["flags"]
            or fixed["abstract"] or "final" not in fixed["flags"] or "pure" in fixed["flags"]
            or implemented["abstract"] or "pure" in implemented["flags"]):
        raise ValueError("Slang did not distinguish the pure declaration, implementation, and final control")
    declarations = ",\n".join(
        f'    {{{json.dumps(entry["name"])}, {int("pure" in entry["flags"])}}}' for entry in (pure, fixed))
    patterns = ",\n".join(
        f"    {{{json.dumps(variable)}, {json.dumps(name)}}}" for variable, name in sorted(members.items()))
    output.write_text(
        "static constexpr struct { const char *name; int is_virtual; } parsed_constraints[] = {\n"
        + declarations + "\n};\n"
        + "static constexpr struct { const char *binding; const char *name; } parsed_members[] = {\n"
        + patterns + "\n};\n", encoding="utf-8")


def observe(tools: dict, include: Path, profile: dict, fixture: Path, work: Path) -> dict:
    files = fixture.parent / "vpi_pattern_constraint_properties"
    client, bridge = files / "client.c", files / "seed.cpp"
    includes = [f"-I{include}", *(f"-I{include / name}" for name in profile["include_subdirs"])]
    linkage = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    native, client_object = work / "native.so", work / "client.o"
    helpers.build([tools["cc"], "-shared", "-fPIC", *linkage, *includes, "-o", native, client], work)
    helpers.build([tools["cc"], "-fPIC", "-DSEED_PATTERN_CONSTRAINT", *includes,
                   "-c", client, "-o", client_object], work)
    environment = {**os.environ, **profile["environment"]}

    def run(plugin: Path, *extra: str) -> dict:
        simulated = helpers.execute([tools["ghost"], *profile["arguments"], "--lib", plugin,
                                     "-top", fixture.stem, fixture, *extra], work, env=environment)
        output = run_ghost.normalize(simulated.stdout, profile).splitlines()
        return {"exit": simulated.returncode, "output": output,
                "completed": any(line.startswith(profile["trailer"]) for line in simulated.stdout.splitlines())}

    def analyze(*extra: str) -> subprocess.CompletedProcess:
        return helpers.execute([tools["slang"], "--std=1800-2023", "--define-system-task", "$vt_pattern_constraint",
                                "--top", fixture.stem, *extra, fixture], work)

    trials = {"native": run(native), "native_swapped": run(native, "+define+SWAP_PATTERN_MEMBERS")}
    parsed, parsed_controls = {}, {}
    for variant, flags in (("seeded", []), ("seeded_swapped", ["-DSWAP_PATTERN_MEMBERS"])):
        ast, cst = work / f"{variant}.ast.json", work / f"{variant}.cst.json"
        analyzed = analyze(*flags, "--ast-json", str(ast), "--cst-json", str(cst))
        if analyzed.returncode:
            raise ValueError(f"Slang could not analyze {variant}: {analyzed.stderr.strip()}")
        constraints = read_constraint_flags(json.loads(ast.read_text(encoding="utf-8")))
        members = read_pattern_members(json.loads(cst.read_text(encoding="utf-8")))
        parsed[variant] = {"constraints": constraints, "member_for_binding": members}
        metadata_header(constraints, members, work / "parsed_properties.h")
        library = work / f"{variant}.so"
        helpers.build([tools["cxx"], "-std=c++20", "-shared", "-fPIC", "-DSEED_PATTERN_CONSTRAINT",
                       *linkage, *includes, f"-I{work}", bridge, client_object, "-o", library], work)
        trials[variant] = run(library, *(["+define+SWAP_PATTERN_MEMBERS"] if flags else []))

    for macro, marker in (("OMIT_PURE_IMPLEMENTATION", "cannot create instance of virtual class"),
                          ("OVERRIDE_FINAL_CONSTRAINT", "overrides a base class member that is marked 'final'")):
        analyzed = analyze(f"-D{macro}")
        parsed_controls[macro] = {"exit": analyzed.returncode, "matched_diagnostic": marker in analyzed.stderr}

    ordinary = suite_results.expected_output(fixture).splitlines()
    seeded = (files / "seeded.expected").read_text(encoding="utf-8").splitlines()
    if not set(SWAP) <= set(seeded):
        raise ValueError("the seeded oracle must contain the pattern and value changes")
    expected = {"native": ordinary, "native_swapped": [SWAP.get(line, line) for line in ordinary],
                "seeded": seeded, "seeded_swapped": [SWAP.get(line, line) for line in seeded]}
    checks = {f"{kind}_trace_matches": trials[kind] == {"exit": 0, "completed": True, "output": output}
              for kind, output in expected.items()}
    checks["pure_implementation_and_final_override_controls"] = all(
        outcome["exit"] != 0 and outcome["matched_diagnostic"] for outcome in parsed_controls.values())
    checks["independently_parsed_member_names_follow_the_swapped_source"] = (
        parsed["seeded"]["member_for_binding"] == {"first": "left", "second": "right"}
        and parsed["seeded_swapped"]["member_for_binding"] == {"first": "right", "second": "left"})
    return {"trials": trials, "parsed": parsed, "slang_controls": parsed_controls, "checks": checks,
            "pass": all(checks.values())}


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
        parser.exit(2, f"VPI property qualification stopped: {error}\n")
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

#!/usr/bin/env python3
"""Compare source-based configuration with a reference on-disk compilation flow."""

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

import suite_results


CHECKER = "tools/run_config_precompiled_cells.py"
PROFILE = "config-precompiled-cells-reference"
CASE = "ch33/test_config_precompiled_cells"
TRANSITIVE = "ch33/test_config_precompiled_transitive_cells"
CASES = {case: suite_results.ROOT / "tests" / f"{case}.sv" for case in (CASE, TRANSITIVE)}
INPUTS = {
    CASE: ("precompiled_cells", "eastLib.phase_leaf", "west.implementation"),
    TRANSITIVE: ("precompiled_transitive", "middleLib.phase_enclosure", "middle"),
}
CONFIG = "configurations.sv"
LIBMAP = "libraries.map"
LOCAL = "precompiled_local"
IDENTIFIER = r"[a-zA-Z_]\w*"
QUALIFIED = rf"{IDENTIFIER}\.{IDENTIFIER}"
INSTANCE_PATH = rf"{IDENTIFIER}(?:\.{IDENTIFIER})+"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def invoke(command: list, work: Path, timeout: int = 60) -> subprocess.CompletedProcess:
    return subprocess.run(command, cwd=work, capture_output=True, text=True, timeout=timeout)


def require_success(process: subprocess.CompletedProcess) -> None:
    if process.returncode != 0:
        raise ValueError(f"{Path(process.args[0]).name} exited {process.returncode}:\n{process.stdout}{process.stderr}")


def configurations(path: Path) -> dict:
    """Compile the fixture subset: one design and explicit instance-use rules per config."""
    pattern = re.compile(rf"\s*config\s+({IDENTIFIER})\s*;\s*(.*?)\s*endconfig\b", re.S)
    configs = {}
    remaining = path.read_text(encoding="utf-8").strip()
    while remaining:
        declaration = pattern.match(remaining)
        if declaration is None or declaration[1] in configs:
            raise ValueError("invalid or duplicate configuration declaration")
        statements = [statement.strip() for statement in declaration[2].split(";")]
        design = re.fullmatch(rf"design\s+({QUALIFIED})", statements[0])
        if design is None or statements[-1] != "":
            raise ValueError("configuration requires a design statement and terminated rules")
        rules = {}
        for statement in statements[1:-1]:
            rule = re.fullmatch(rf"instance\s+({INSTANCE_PATH})\s+use\s+({QUALIFIED})", statement)
            if rule is None or rule[1] in rules:
                raise ValueError(f"invalid or duplicate instance rule: {statement}")
            rules[rule[1]] = rule[2]
        configs[declaration[1]] = {"design": design[1], "instances": rules}
        remaining = remaining[declaration.end():].lstrip()
    return configs


def source_libraries(path: Path) -> dict[Path, str]:
    sources = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        mapping = re.fullmatch(rf"library\s+({IDENTIFIER})\s+((?:\.\./{IDENTIFIER}/)?{IDENTIFIER}\.sv);", line.strip())
        if mapping is None:
            raise ValueError(f"invalid or duplicate library mapping: {line}")
        source = (path.parent / mapping[2]).resolve()
        if source in sources:
            raise ValueError(f"duplicate library source: {mapping[2]}")
        sources[source] = mapping[1]
    return sources


def compile_library(yosys: str, verilog: Path, sources: dict[Path, str], work: Path) -> dict:
    objects = {}
    for index, (source, library) in enumerate({verilog: "work", **sources}.items()):
        output = work / f"object-{index}.json"
        require_success(invoke([yosys, "-Q", "-T", "-p",
                                f"read_verilog -sv {source.relative_to(work)}; write_json {output.name}"], work))
        (cell,) = read_json(output)["modules"]
        key = f"{library}.{cell}"
        if key in objects:
            raise ValueError(f"duplicate compiled cell {key}")
        output.rename(work / f"{key}.json")
        objects[key] = {"sha256": digest(work / f"{key}.json"), "source": str(source.relative_to(work))}
    return objects


def bind(work: Path, config: str) -> None:
    """Bind from serialized artifacts by following the unresolved cells in each compiled object."""
    plan_path = work / "compiled-configurations.json"
    if not plan_path.is_file():
        raise ValueError("no compiled configuration library")
    plans = read_json(plan_path)
    if config not in plans:
        raise ValueError(f"no compiled configuration {config}")
    plan = plans[config]
    modules, hierarchy, active = {}, {}, set()

    def descend(path: str, target: str) -> str:
        artifact = work / f"{target}.json"
        if not artifact.is_file():
            raise ValueError(f"{path} needs missing compiled cell {target}")
        if target in active:
            raise ValueError(f"recursive compiled cell {target} at {path}")
        active.add(target)
        module = read_json(artifact)["modules"][target.split(".")[1]]
        hierarchy[path] = target
        # The same compiled object can receive a different child binding at each path.
        name = f"bound_{len(hierarchy)}"
        for instance, cell in module["cells"].items():
            if cell["type"].startswith("$"):
                continue
            child_path = f"{path}.{instance}"
            if child_path not in plan["instances"]:
                raise ValueError(f"{child_path} has no compiled instance binding")
            cell["type"] = descend(child_path, plan["instances"][child_path])
        active.remove(target)
        modules[name] = module
        return name

    top = descend(plan["design"].split(".")[1], plan["design"])
    if plan["instances"].keys() - hierarchy.keys():
        raise ValueError("compiled configuration refers to nonexistent instances")
    write_json(work / "linked.json", {"modules": modules})
    write_json(work / "binding.json", {"top": top, "hierarchy": hierarchy})


def verilator_source_run(verilator: str, root: Path, source: Path, inputs: dict[Path, str],
                         config: str, work: Path) -> dict:
    directory = f"source-{config}"
    build = invoke([verilator, "--binary", "--timing", "-Wno-fatal", "-j", "2", "--Mdir", directory,
                    "-o", "simulate", "--top-module", config, "-libmap", source / LIBMAP,
                    root, source / CONFIG, *inputs], work, timeout=120)
    if build.returncode:
        return {"build_exit": build.returncode, "diagnostics": build.stderr.splitlines()}
    simulation = invoke([work / directory / "simulate"], work)
    return {"build_exit": 0, **simulation_result(simulation)}


def simulation_result(simulation: subprocess.CompletedProcess) -> dict:
    return {"exit": simulation.returncode, "output": [line for line in simulation.stdout.splitlines()
                                                     if line.startswith("west=")]}


def ghost_source_run(ghost: str, root: Path, source: Path, inputs: dict[Path, str],
                     config: str, work: Path) -> dict:
    libraries = [item for path, library in inputs.items() for item in ("-v", f"{library}={path}")]
    run = invoke([ghost, "--lrm-strict", "--quiet", "-top", config, *libraries,
                  root, source / CONFIG], work)
    return simulation_result(run)


def slang_source_bindings(slang: str, root: Path, source: Path, inputs: dict[Path, str],
                          config: str, work: Path) -> dict:
    ast = work / "source-ast.json"
    build = invoke([slang, "--std=1800-2023", "--top", f"{config}:config",
                    "--libmap", source / LIBMAP, "--ast-json", ast, "--ast-json-source-info",
                    root, source / CONFIG], work)
    require_success(build)
    libraries = {root: "work", **inputs}
    hierarchy = {}

    def visit(scope: dict, prefix: str) -> None:
        for instance in scope["members"]:
            if instance["kind"] != "Instance":
                continue
            path = prefix + instance["name"]
            body = instance["body"]
            library = libraries[(work / body["source_file"]).resolve()]
            hierarchy[path] = f"{library}.{body['name']}"
            visit(body, f"{path}.")

    visit(read_json(ast)["design"], "")
    return {"exit": build.returncode, "hierarchy": hierarchy}


def binder_process(work: Path, config: str) -> dict:
    for filename in ("linked.json", "binding.json"):
        (work / filename).unlink(missing_ok=True)
    result = invoke([sys.executable, Path(__file__).resolve(), "--bind", config], work)
    return {"exit": result.returncode, "diagnostics": result.stderr.splitlines()}


def proof(yosys: str, work: Path, top: str, expected: str) -> dict:
    match = re.fullmatch(r"west=([0-9a-f]{2}) east=([0-9a-f]{2})", expected)
    if match is None:
        raise ValueError(f"invalid expected output: {expected}")
    script = (f"read_json linked.json; hierarchy -check -top {top}; flatten; "
              f"sat -verify -prove west_value 8'h{match[1]} -prove east_value 8'h{match[2]}")
    result = invoke([yosys, "-Q", "-T", "-p", script], work)
    return {"exit": result.returncode,
            "proved": "SAT proof finished - no model found: SUCCESS!" in result.stdout,
            "refuted": "proof did fail" in result.stderr}


def qualify(programs: dict, fixture: Path, work: Path) -> dict:
    input_directory, missing_cell, missing_path = INPUTS[suite_results.test_id(fixture)]
    staged = work / "source"
    for path in suite_results.input_files(fixture):
        target = staged / path.relative_to(fixture.parent)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, target)
    root = staged / fixture.name
    configuration = staged / input_directory
    inputs = source_libraries(configuration / LIBMAP)
    crossed = suite_results.top_module(fixture)
    expected = {crossed: suite_results.expected_output(fixture).strip(), LOCAL: "west=a1 east=a2"}
    source = {"slang": {config: slang_source_bindings(programs["slang"], root, configuration, inputs, config, work)
                        for config in expected},
              "verilator": {config: verilator_source_run(programs["verilator"], root, configuration, inputs, config, work)
                            for config in expected}}
    if "ghost" in programs:
        source["ghost"] = {config: ghost_source_run(programs["ghost"], root, configuration, inputs, config, work)
                           for config in expected}
    yosys = programs["yosys"]
    objects = compile_library(yosys, root, inputs, work)
    plan_path = work / "compiled-configurations.json"
    write_json(plan_path, configurations(configuration / CONFIG))
    config_sha256 = digest(plan_path)
    shutil.rmtree(staged)
    source_removed = not staged.exists() and not any(work.rglob("*.sv"))

    compiled = {}
    for config, output in expected.items():
        linked = binder_process(work, config)
        if linked["exit"]:
            raise ValueError(f"cannot bind {config}: {linked['diagnostics']}")
        binding = read_json(work / "binding.json")
        compiled[config] = {**linked, **binding, "proof": proof(yosys, work, binding["top"], output)}
    wrong_proof = proof(yosys, work, compiled[LOCAL]["top"], expected[crossed])

    withheld = work / f"{missing_cell}.json"
    withheld.rename(withheld.with_suffix(".withheld"))
    without_cell = binder_process(work, crossed)
    withheld.with_suffix(".withheld").rename(withheld)
    plan_path.rename(plan_path.with_suffix(".withheld"))
    without_config = binder_process(work, crossed)
    plan_path.with_suffix(".withheld").rename(plan_path)

    checks = {
        "slang_source_bindings_agree_with_compiled_bindings": all(
            row["exit"] == 0 and row["hierarchy"] == compiled[config]["hierarchy"]
            for config, row in source["slang"].items()),
        "source_files_absent_during_binding": source_removed,
        "rebound_hierarchies_prove_expected_outputs": all(
            row["proof"]["exit"] == 0 and row["proof"]["proved"] for row in compiled.values()),
        "alternate_configuration_falsifies_crossed_expectation": wrong_proof["exit"] > 0 and wrong_proof["refuted"],
        "missing_cell_diagnosed_during_descent": without_cell == {
            "exit": 1, "diagnostics": [f"{fixture.stem}.{missing_path} needs missing compiled cell {missing_cell}"]},
        "missing_compiled_configuration_rejected": without_config == {
            "exit": 1, "diagnostics": ["no compiled configuration library"]},
        "reused_objects_and_configuration_unchanged": config_sha256 == digest(plan_path) and all(
            digest(work / f"{cell}.json") == data["sha256"] for cell, data in objects.items()),
    }
    if "ghost" in source:
        checks["ghost_source_outputs_agree"] = all(
            row == {"exit": 0, "output": [expected[config]]} for config, row in source["ghost"].items())
    return {"source": source, "compiled": compiled, "objects": objects,
            "configuration_sha256": config_sha256, "alternate_proof": wrong_proof,
            "without_cell": without_cell, "without_config": without_config,
            "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--yosys", default="yosys")
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--slang", default="slang")
    parser.add_argument("--ghost", help="also compare source simulation with Ghost")
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--json", type=Path, help="write the qualification record")
    action.add_argument("--bind", help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.bind is not None:
        try:
            bind(Path.cwd(), args.bind)
        except ValueError as error:
            print(error, file=sys.stderr)
            return 1
        return 0

    names = ["yosys", "slang", "verilator"]
    if args.ghost:
        names.append("ghost")
    programs = {}
    for name in names:
        executable = shutil.which(getattr(args, name))
        if executable is None:
            parser.error(f"missing tool: {name}")
        programs[name] = str(Path(executable).absolute())
    artifact_paths = {name: Path(program) for name, program in programs.items()}
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(artifact_paths["verilator"].with_name("verilator_bin"))))
    if backend is not None:
        artifact_paths["verilator_bin"] = Path(backend)
    artifacts = {name: digest(path) for name, path in artifact_paths.items()}
    inputs = {case: suite_results.input_digest(fixture) for case, fixture in CASES.items()}
    checker = checker_digest()
    results = {}
    for case, fixture in CASES.items():
        with tempfile.TemporaryDirectory() as directory:
            results[case] = {"inputs_sha256": inputs[case], **qualify(programs, fixture, Path(directory).resolve())}
    if (inputs != {case: suite_results.input_digest(fixture) for case, fixture in CASES.items()}
            or checker != checker_digest()
            or any(digest(path) != artifacts[name] for name, path in artifact_paths.items())):
        parser.error("inputs, tools or checker changed during the run")
    write_json(args.json, {"schema": 1, "profile": PROFILE, "checker_sha256": checker,
                           "artifact_sha256": artifacts, "versions": {
                               name: suite_results.tool_version([program, "--version"])
                               for name, program in programs.items()},
                           "tests": results})
    for case, result in results.items():
        for name, passed in result["checks"].items():
            print(f"{'PASS' if passed else 'FAIL'} {case} {name}")
    return int(any(not result["pass"] for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

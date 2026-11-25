#!/usr/bin/env python3
"""Check provider-selected shared-library versions and private initializers."""

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


PROFILE = "ghost-dpi-versioned-dependencies"
CHECKER = "tools/run_ghost_dpi_versioned_dependencies.py"
CASE = "ch35/test_dpi_annex_j_isolates_versioned_dependencies"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
INIT_PREFIXES = ("dependency ", "client ", "optional object initialized", "unreferenced entry called")
OPTIONAL_INIT = "optional object initialized"
MISSING_ABI = re.compile(r"(?:symbol not found|undefined symbol):\s+_?annex_j_dependency_two\b", re.I)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def invoke(command: list[str], cwd: Path, environment: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(command, cwd=cwd, env=environment, capture_output=True, text=True,
                          errors="replace", timeout=60)


def build(command: list[str], cwd: Path) -> None:
    result = invoke(command, cwd)
    if result.returncode:
        raise ValueError(result.stderr)


def link(client: Path, dependency: Path, compiler: str, directory: Path, extra: list[Path]) -> Path:
    output = directory / client.with_suffix(dependency.suffix).name
    rpath = "@loader_path" if sys.platform == "darwin" else "$ORIGIN"
    build([compiler, "-shared", f"-Wl,-rpath,{rpath}", "-o", str(output), str(client),
           *map(str, extra), str(dependency)], directory)
    return output


def build_libraries(compiler: str, fixture: Path, work: Path) -> tuple[str, Path, Path]:
    fields = suite_results.header(fixture)
    client_source = fixture.parent / fields["dpi_c"].removeprefix("@")
    dependency_source, optional_source = (fixture.parent / name for name in fields["files"].split())
    darwin = sys.platform == "darwin"
    suffix = ".dylib" if darwin else ".so"
    normal = work / "normal"
    normal.mkdir()
    for version in (1, 2):
        flags = [compiler, "-std=c++17", "-fPIC", "-DANNEX_J_TRACE", f"-DANNEX_J_ABI={version}"]
        dependency = normal / f"libdependency{version}{suffix}"
        identity = (f"-Wl,-install_name,@rpath/{dependency.name}" if darwin
                    else f"-Wl,-soname,{dependency.name}")
        dep_object = work / f"dependency{version}.o"
        client = work / f"libclient{version}.o"
        build([*flags, "-c", str(dependency_source), "-o", str(dep_object)], work)
        build([compiler, "-shared", identity, "-o", str(dependency), str(dep_object)], work)
        build([*flags, "-c", str(client_source), "-o", str(client)], work)
        link(client, dependency, compiler, normal, [])

    optional = work / "with_optional"
    shutil.copytree(normal, optional)
    extra = work / "optional.o"
    build([compiler, "-std=c++17", "-fPIC", "-c", str(optional_source), "-o", str(extra)], work)
    link(work / "libclient2.o", optional / f"libdependency2{suffix}", compiler, optional, [extra])
    return suffix, normal, optional


def run_trial(simulator: str, fixture: Path, directory: Path, profile: dict, suffix: str,
              order: tuple[int, ...]) -> subprocess.CompletedProcess:
    libraries = [part for version in order for part in ("-sv_lib", f"./libclient{version}{suffix}")]
    environment = {**os.environ, **profile["environment"]}
    return invoke([simulator, *profile["arguments"], *libraries, "-top", fixture.stem, str(fixture)],
                  directory, environment)


def observe(simulator: str, compiler: str, fixture: Path, profile: dict, work: Path) -> dict:
    suffix, normal, optional = build_libraries(compiler, fixture, work)
    expected = suite_results.expected_output(fixture).splitlines()
    observations = {}
    variants = {"forward": (normal, (1, 2)), "reverse": (normal, (2, 1)),
                "with_optional": (optional, (1, 2))}
    for name, (directory, order) in variants.items():
        result = run_trial(simulator, fixture, directory, profile, suffix, order)
        lines = run_ghost.normalize(result.stdout, profile).splitlines()
        optional_count = lines.count(OPTIONAL_INIT)
        output = [line for line in lines if line != OPTIONAL_INIT]
        initializers = [f"{kind} {version} initialized" for version in order for kind in ("dependency", "client")]
        passed = (result.returncode == 0 and output == [*initializers, *expected]
                  and optional_count <= int(name == "with_optional"))
        observations[name] = {"returncode": result.returncode, "stdout": lines,
                              "optional_initializers": optional_count, "pass": passed}

    wrong = work / "incompatible"
    shutil.copytree(normal, wrong)
    first_dependency = wrong / f"libdependency1{suffix}"
    second_dependency = wrong / f"libdependency2{suffix}"
    shutil.copyfile(first_dependency, second_dependency)
    wrong_result = run_trial(simulator, fixture, wrong, profile, suffix, (1, 2))
    messages = wrong_result.stderr + "\n" + wrong_result.stdout
    diagnoses = list(dict.fromkeys(match[0] for match in MISSING_ABI.finditer(messages)))
    output = [line for line in wrong_result.stdout.splitlines()
              if line.startswith((*INIT_PREFIXES, "resolved versions="))]
    replacement = digest(first_dependency) == digest(second_dependency)
    observations["incompatible"] = {
        "returncode": wrong_result.returncode, "stdout": output, "diagnostics": diagnoses,
        "same_replacement_bytes": replacement,
        "pass": wrong_result.returncode > 0 and bool(diagnoses) and replacement
                and not any(line.startswith("resolved versions=") for line in output),
    }
    libraries = {directory.name: {path.name: digest(path) for path in sorted(directory.glob(f"*{suffix}"))}
                 for directory in (normal, optional, wrong)}
    original = libraries["normal"]
    changes = {name: [file for file in original if original[file] != libraries[name].get(file)]
               for name in ("with_optional", "incompatible")}
    isolated = changes == {"with_optional": [f"libclient2{suffix}"],
                           "incompatible": [f"libdependency2{suffix}"]}
    return {"pass": isolated and all(trial["pass"] for trial in observations.values()),
            "trials": observations, "changed_shared_objects": changes, "shared_objects_sha256": libraries}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    found = shutil.which(args.ghost)
    cxx = shutil.which(os.environ.get("CXX", "c++"))
    if not (found and cxx) or sys.platform not in ("darwin", "linux"):
        parser.error("Ghost and a C++ shared-library toolchain for macOS or Linux are required")
    simulator = str(Path(found).absolute())
    compiler = str(Path(cxx).absolute())
    artifacts = {"simulator": Path(simulator).resolve(), "compiler": Path(compiler).resolve()}
    fingerprints = {name: digest(path) for name, path in artifacts.items()}
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation = observe(simulator, compiler, fixture, profile, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (fingerprints != {name: digest(path) for name, path in artifacts.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("ghost") or args.profile.read_bytes() != profile_bytes
            or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, inputs or checker changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "binary_sha256": fingerprints,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(),
                     "compiler_version": suite_results.tool_version([compiler, "--version"])}
    status = ("pass", "") if observation["pass"] else ("fail", "DPI dependency observations differed")
    version = f"private build {fingerprints['simulator'][:12]}"
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: status},
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "ghost", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    for variant, outcome in observation["trials"].items():
        print(variant, outcome)
    return int(not observation["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

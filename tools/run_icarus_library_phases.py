#!/usr/bin/env python3
"""Compare explicitly supplied library files with on-demand library lookup."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_icarus
import suite_results


CHECKER = "tools/run_icarus_library_phases.py"
PROFILE = "icarus-single-pass-library-loading"
SOURCE_NAMES = {
    "ch33/test_single_pass_library_loading": ("phase_needed",),
    "ch33/test_single_pass_library_nested_lookup": ("phase_parent", "phase_child"),
}
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in SOURCE_NAMES}
UNUSED = "lib/phase_unused.v"
MALFORMED = "lib/phase_bad.v"


def required_sources(fixture: Path) -> tuple[str, ...]:
    return tuple(f"lib/{name}.v" for name in SOURCE_NAMES[suite_results.test_id(fixture)])


def invocations(required: tuple[str, ...]) -> dict[str, list[str]]:
    supplied = [argument for path in required for argument in ("-l", path)]
    explicit = [*supplied, "-l", UNUSED]
    return {
        "explicit": explicit,
        "omitted": [*supplied[:-2], "-l", UNUSED],
        "resupplied": explicit,
        "malformed": [*supplied, "-l", MALFORMED],
        "lazy": ["-y", "lib"],
    }


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def prepare(fixture: Path, work: Path) -> None:
    declared = suite_results.input_files(fixture)
    sources = fixture.parent / "single_pass_library"
    (work / "lib").mkdir()
    shutil.copyfile(fixture, work / fixture.name)
    copies = {Path(target).name: target for target in (*required_sources(fixture), UNUSED)}
    copies["phase_bad.txt"] = MALFORMED
    for source, target in copies.items():
        path = sources / source
        if path not in declared:
            raise ValueError(f"undeclared library input: {source}")
        shutil.copyfile(path, work / target)


def invoke(compiler: Path, runtime: Path, fixture: Path, work: Path, stage: str, options: list[str]) -> dict:
    deps_name, executable = f"{stage}.deps", f"{stage}.vvp"
    build = run_icarus.execute(
        [str(compiler), "-g2012", "-s", fixture.stem, "-M", f"all={deps_name}",
         "-o", executable, *options, fixture.name], run_icarus.COMPILE_TIMEOUT, cwd=str(work))
    dependency_file = work / deps_name
    dependencies = (dependency_file.read_text(encoding="utf-8").splitlines()
                    if dependency_file.is_file() else [])
    result = {"compile_exit": build.returncode, "dependencies": sorted(set(dependencies)),
              "compile_diagnostics": build.stderr.splitlines()}
    if build.returncode == 0:
        run = run_icarus.execute([str(runtime), executable], run_icarus.RUN_TIMEOUT, cwd=str(work))
        result.update(runtime_exit=run.returncode, stdout=run.stdout.splitlines())
    return result


def qualifies(trials: dict, fixture: Path, expected: list[str], persistence: dict) -> bool:
    def runtime_matches(stage: str, dependencies: set[str]) -> bool:
        trial = trials[stage]
        return (trial["compile_exit"] == 0 and set(trial["dependencies"]) == dependencies
                and trial["runtime_exit"] == 0 and trial["stdout"] == expected)

    required = required_sources(fixture)
    design_inputs = {fixture.name, *required}
    explicit_inputs = design_inputs | {UNUSED}
    if not (runtime_matches("explicit", explicit_inputs) and runtime_matches("resupplied", explicit_inputs)
            and runtime_matches("lazy", design_inputs)):
        return False
    malformed = trials["malformed"]
    if (malformed["compile_exit"] <= 0 or set(malformed["dependencies"]) != design_inputs | {MALFORMED}
            or not any(re.match(r"^lib/phase_bad\.v:\d+:(?:\d+:)? (?:syntax error|error: Syntax error)", line)
                       for line in malformed["compile_diagnostics"])):
        return False
    omitted = trials["omitted"]
    last_source = Path(required[-1])
    diagnostic_source = fixture.name if len(required) == 1 else required[-2]
    return (persistence["explicit_executable_present"]
            and set(persistence["generated_files"]) == {"explicit.vvp", "explicit.deps", "omitted.deps",
                                                        "resupplied.vvp", "resupplied.deps", "malformed.deps",
                                                        "lazy.vvp", "lazy.deps"}
            and omitted["compile_exit"] > 0 and set(omitted["dependencies"]) == explicit_inputs - {required[-1]}
            and any(line.startswith(f"{diagnostic_source}:") and f"Unknown module type: {last_source.stem}" in line
                    for line in omitted["compile_diagnostics"]))


def observe(compiler: Path, runtime: Path, fixture: Path) -> tuple[bool, dict]:
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        prepare(fixture, work)
        initial = {path.relative_to(work).as_posix() for path in work.rglob("*") if path.is_file()}
        trials = {}
        explicit_executable_present = False
        for stage, options in invocations(required_sources(fixture)).items():
            if stage == "omitted":
                explicit_executable_present = (work / "explicit.vvp").is_file()
            trials[stage] = invoke(compiler, runtime, fixture, work, stage, options)
        generated = {path.relative_to(work).as_posix() for path in work.rglob("*") if path.is_file()} - initial
        persistence = {"explicit_executable_present": explicit_executable_present,
                       "generated_files": sorted(generated)}
        expected = suite_results.expected_output(fixture).splitlines()
        return qualifies(trials, fixture, expected, persistence), {
            "trials": trials, "persistence": persistence, "expected": expected}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    bindir = args.iverilog_bin.resolve()
    compiler, runtime = bindir / "iverilog", bindir / "vvp"
    binaries = (compiler, runtime)
    if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries):
        parser.error("the binary directory must contain executable iverilog and vvp")
    version = suite_results.tool_version([str(compiler), "-V"])
    fixtures = list(CASES.values())
    inputs = suite_results.fingerprints(fixtures)
    binary_hashes = {path.name: digest(path) for path in binaries}
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("icarus")
    results, observations = {}, {}
    for case, fixture in CASES.items():
        try:
            passed, evidence = observe(compiler, runtime, fixture)
        except (OSError, ValueError, subprocess.TimeoutExpired) as error:
            passed, evidence = False, {"error": type(error).__name__}
        status = "pass" if passed else "fail"
        reason = "" if passed else "library dependency, diagnostic or binding observation differed"
        results[case] = (status, reason)
        observations[case] = {"inputs_sha256": inputs[case], "status": status, **evidence}
        print(f"{case}: {status}")
    if (binary_hashes != {path.name: digest(path) for path in binaries}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("icarus")
            or inputs != suite_results.fingerprints(fixtures)):
        parser.exit(2, "Icarus, the checker or test inputs changed during execution.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "binary_sha256": binary_hashes}
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, results,
                        inputs=inputs, runner_sha256=runner_hash, configuration=configuration)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "version": version, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": observations,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

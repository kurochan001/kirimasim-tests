#!/usr/bin/env python3
"""Observe duplicate defparams with same-source and cross-source controls."""

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
import run_icarus
import suite_results


PROFILE = "icarus-defparam-source-order"
CHECKER = "tools/run_defparam_sources.py"
CASE = "ch23/test_defparam_migration_and_duplicate_observation"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SAME = "OBSERVE_SAME_SOURCE"
CROSS = "CROSS_SOURCE_OVERRIDES"
TRIALS = {
    "migration": ((), False),
    "same_source": ((SAME,), False),
    "same_source_reversed": ((SAME, "REVERSE_SAME_SOURCE"), False),
    "inner_only": ((CROSS, "OMIT_OUTER_OVERRIDE"), False),
    "outer_only": ((CROSS, "OMIT_INNER_OVERRIDE"), False),
    "cross_source": ((CROSS,), False),
    "cross_source_reversed": ((CROSS,), True),
}
UNSPECIFIED = {"cross_source", "cross_source_reversed"}
OBSERVED = re.compile(r"cross-source=[0-9xz]+ width=[0-9xz]+", re.I)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    check = hashlib.sha256()
    for name in (CHECKER, "tools/run_ghost.py", "tools/run_icarus.py", "tools/suite_results.py",
                 "tools/normalize_output.py"):
        check.update(name.encode() + b"\0")
        check.update(bytes.fromhex(digest(suite_results.ROOT / name)))
    return check.hexdigest()


def matches(mode: str, trial: dict, migration: list[str]) -> bool:
    if trial["returncode"] != 0:
        return False
    output = trial["stdout"]
    if mode in UNSPECIFIED:
        return len(output) == 1 and OBSERVED.fullmatch(output[0]) is not None
    expected = {
        "migration": migration,
        "same_source": [*migration, "same-file=59"],
        "same_source_reversed": [*migration, "same-file=57"],
        "inner_only": ["cross-source=57 width=7"],
        "outer_only": ["cross-source=59 width=9"],
    }
    return output == expected[mode]


def observe(binaries: dict[str, Path], fixture: Path, profile: dict | None) -> dict:
    expected = suite_results.expected_output(fixture).splitlines()
    sources, _ = suite_results.files(fixture)
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        design = [source.relative_to(fixture.parent).as_posix() for source in (*sources, fixture)]
        for source, name in zip((*sources, fixture), design, strict=True):
            destination = work / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)
        observations = {}
        for mode, (defines, reverse) in TRIALS.items():
            files = list(reversed(design)) if reverse else design
            if profile:
                command = [str(binaries["ghost"]), *profile["arguments"], "-top", fixture.stem,
                           *[f"+define+{name}" for name in defines], *files]
                run = subprocess.run(command, cwd=work, env={**os.environ, **profile["environment"]},
                                     capture_output=True, text=True, errors="replace", timeout=run_icarus.RUN_TIMEOUT)
                stdout = run_ghost.normalize(run.stdout, profile).splitlines()
            else:
                image = f"{mode}.vvp"
                command = [str(binaries["iverilog"]), "-g2012", "-s", fixture.stem, "-o", image,
                           *[f"-D{name}" for name in defines], *files]
                build = run_icarus.execute(command, run_icarus.COMPILE_TIMEOUT, cwd=directory)
                if build.returncode != 0:
                    observations[mode] = {"pass": False, "compile_exit": build.returncode,
                                          "diagnostics": run_icarus.neutral(build.stderr, directory).splitlines()}
                    continue
                run = run_icarus.execute([str(binaries["vvp"]), image], run_icarus.RUN_TIMEOUT, cwd=directory)
                stdout = run.stdout.splitlines()
            item = {"returncode": run.returncode, "stdout": stdout, "source_order": files,
                    "defines": list(defines)}
            item["pass"] = matches(mode, item, expected)
            if run.returncode:
                item["diagnostics"] = run_icarus.neutral(run.stderr, directory).splitlines()
            observations[mode] = item
        return observations


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    backend = parser.add_mutually_exclusive_group(required=True)
    backend.add_argument("--iverilog-bin", type=Path)
    backend.add_argument("--ghost")
    parser.add_argument("--profile", type=Path)
    parser.add_argument("--json", type=Path, help="Icarus behavioral coverage snapshot")
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    if args.ghost:
        path = shutil.which(args.ghost)
        if not path or not args.profile:
            parser.error("Ghost requires its executable and runtime profile")
        binaries = {"ghost": Path(path).resolve()}
        profile_bytes = args.profile.read_bytes()
        profile = json.loads(profile_bytes)
        tool = "ghost"
    else:
        if not args.json:
            parser.error("Icarus requires --json")
        binaries = {name: args.iverilog_bin.resolve() / name for name in ("iverilog", "vvp")}
        if not all(path.is_file() and os.access(path, os.X_OK) for path in binaries.values()):
            parser.error("the Icarus compiler and runtime must be available")
        profile_bytes = profile = None
        tool = "icarus"
    hashes = {name: digest(path) for name, path in binaries.items()}
    version = (f"private build {hashes['ghost'][:12]}" if profile else
               suite_results.tool_version([str(binaries["iverilog"]), "-V"]))
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    runner_hash = suite_results.runner_digest(tool)
    checker_hash = checker_digest()
    try:
        observations = observe(binaries, fixture, profile)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        observations = {"observation": {"pass": False, "error": type(error).__name__}}
    if (hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest(tool)
            or inputs != suite_results.fingerprints([fixture])
            or (profile and args.profile.read_bytes() != profile_bytes)):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"checker_sha256": checker_hash, "binary_sha256": hashes}
    passed = all(trial["pass"] for trial in observations.values())
    if profile:
        configuration["profile_sha256"] = hashlib.sha256(profile_bytes).hexdigest()
    else:
        configuration["evidence_profile"] = PROFILE
        status = ("pass", "") if passed else ("fail", "defparam source-order observation differed")
        suite_results.write(args.json, "icarus", "Icarus Verilog", version, {CASE: status},
                            inputs=inputs, configuration=configuration, runner_sha256=runner_hash)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": tool, "version": version, "configuration": configuration, "runner_sha256": runner_hash,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "pass": passed, "trials": observations}},
    }, indent=2) + "\n", encoding="utf-8")
    for mode, trial in observations.items():
        print(mode, trial)
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

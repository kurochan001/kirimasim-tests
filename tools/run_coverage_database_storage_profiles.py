#!/usr/bin/env python3
"""Replay named coverage entries using the native Ghost and Verilator CLI formats."""

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
import run_verilator
import suite_results


CHECKER = "tools/run_coverage_database_storage_profiles.py"
PROFILE = "coverage-database-storage-reference"
CASE = "ch40/test_coverage_database_storage_profiles"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
COVER_NAMES = ("low_path", "high_path")
ENTRY_NAMES = ("db/north", "db/south")
EXPECTED = dict(zip(ENTRY_NAMES, ((3, 0), (0, 3)), strict=True))
LOCATIONS = {
    "ghost": ("archive/region/part-7", "objects/segment-2"),
    "verilator": ("output-flat-19", "output-flat-43"),
}


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("ghost")
                           + suite_results.runner_digest("verilator")).encode()).hexdigest()


def run(command: list[str], work: Path, *, env: dict | None = None,
        timeout: int = 60) -> subprocess.CompletedProcess:
    return subprocess.run(command, cwd=work, env=env, capture_output=True,
                          text=True, errors="replace", timeout=timeout)


def checked(command: list[str], work: Path, *, env: dict | None = None,
            timeout: int = 60) -> subprocess.CompletedProcess:
    result = run(command, work, env=env, timeout=timeout)
    if result.returncode:
        raise ValueError(f"{Path(command[0]).name} exited {result.returncode}: {result.stderr.strip()}")
    return result


def artifact(path: Path, work: Path) -> dict:
    return {"path": path.relative_to(work).as_posix(), "bytes": path.stat().st_size, "sha256": digest(path)}


def ghost_counts(path: Path) -> tuple[int, ...]:
    rows = json.loads(path.read_text(encoding="utf-8"))["cover_properties"]
    data = {row["name"]: row["hitCount"] for row in rows}
    if len(rows) != len(COVER_NAMES) or set(data) != set(COVER_NAMES):
        raise ValueError("Ghost export did not contain exactly the two labelled cover properties")
    return tuple(data[name] for name in COVER_NAMES)


def lcov_counts(path: Path, sites: tuple[int, ...], source: Path) -> tuple[int, ...]:
    active = False
    counts = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            active = Path(line[3:]).name == source.name
        elif active and line.startswith("DA:"):
            location, count, *_ = map(int, line[3:].split(",")[:2])
            if location in counts:
                raise ValueError("duplicate line entry in Verilator coverage conversion")
            counts[location] = count
    return tuple(counts[site] for site in sites if site in counts)


def cover_sites(source: Path) -> tuple[int, ...]:
    return tuple(next(line for line, text in enumerate(source.read_text().splitlines(), 1)
                      if re.match(rf"\s*{name}: cover property\b", text)) for name in COVER_NAMES)


def verify_locations(work: Path, tool: str, export, merge, read_counts) -> dict:
    work.mkdir()
    aliases = dict(zip(ENTRY_NAMES, LOCATIONS[tool], strict=True))
    trace = {}
    for i, (logical, relative) in enumerate(aliases.items()):
        destination = work / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        staging = work / f"capture-{i}"
        stdout = export(staging, i)
        if stdout != [f"selected={i}"]:
            raise ValueError(f"{tool} produced unexpected stimulus output for {logical}: {stdout}")
        capture = artifact(staging, work)
        staging.rename(destination)
        trace[logical] = {"stdout": stdout, "captured": capture, "persisted": artifact(destination, work)}

    catalogue = work / "entries.json"
    catalogue.write_text(json.dumps(aliases), encoding="utf-8")
    names = json.loads(catalogue.read_text(encoding="utf-8"))
    paths = {name: work / relative for name, relative in names.items()}
    retrieved = {}
    for i, (name, stored) in enumerate(paths.items()):
        loaded = work / f"read-{i}"
        merge([stored], loaded)
        retrieved[name] = read_counts(loaded)
    combined = work / "combined"
    merge(list(paths.values()), combined)
    aggregate = read_counts(combined)

    unknown = names.get("db/missing")
    switched = {}
    for i, (name, stored) in enumerate(zip(paths, reversed(paths.values()), strict=True)):
        reloaded = work / f"switched-{i}"
        merge([stored], reloaded)
        switched[name] = read_counts(reloaded)
    checks = {
        "complementary_entries_read_by_name": retrieved == EXPECTED,
        "merged_cover_counts_preserved": aggregate == (3, 3),
        "switched_entries_detected": switched == dict(zip(ENTRY_NAMES, ((0, 3), (3, 0)), strict=True)),
        "storage_paths_are_independent_of_names": unknown is None and all(
            not (work / name).exists() and not (work / row["captured"]["path"]).exists()
            and row["captured"]["sha256"] == row["persisted"]["sha256"] for name, row in trace.items()),
    }
    return {
        "entries": trace, "retrieved_counts": retrieved, "switched_counts": switched, "merged_counts": aggregate,
        "merged_artifact": artifact(combined, work), "checks": checks, "pass": all(checks.values()),
    }


def verilator_database(exe: str, converter: str, work: Path, source: Path) -> dict:
    build = work / "model"
    checked([exe, "--binary", "--timing", "--coverage-user", "-Wno-fatal", "--top-module", source.stem,
             "--Mdir", str(build), "--prefix", "Vdatabase", str(source)], work, timeout=180)
    root = work / "verilator"
    sites = cover_sites(source)

    def export(path, selected):
        args = ["+high"] if selected else []
        result = checked([str(build / "Vdatabase"), f"+verilator+coverage+file+{path}", *args], root)
        return [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]

    def merge(inputs, destination):
        checked([converter, "--write", str(destination), *map(str, inputs)], root)

    def read_counts(path):
        decoded = path.with_suffix(".info")
        checked([converter, "--write-info", str(decoded), str(path)], root)
        return lcov_counts(decoded, sites, source)

    return verify_locations(root, "verilator", export, merge, read_counts)


def ghost_database(exe: str, profile: dict, work: Path, source: Path) -> dict:
    root = work / "ghost"
    env = {**os.environ, **profile["environment"]}
    command = [exe, *profile["arguments"]]

    def export(path, selected):
        args = ["+high"] if selected else []
        result = checked([*command, "--save-coverage", str(path), str(source), *args], root, env=env)
        return run_ghost.normalize(result.stdout, profile).splitlines()

    def merge(inputs, destination):
        checked([*command, "--merge-coverage", *map(str, inputs), "--save-coverage", str(destination)],
                root, env=env)

    reference = verify_locations(root, "ghost", export, merge, ghost_counts)
    native = checked([*command, "+define+CHECK_NATIVE_COVERAGE_STORAGE", str(source)], root, env=env)
    reference["native_calls"] = run_ghost.normalize(native.stdout, profile).splitlines()
    if len(reference["native_calls"]) != 2 or not re.fullmatch(
            r"standard save=-?\d+ merge=-?\d+", reference["native_calls"][0]):
        raise ValueError("native Ghost storage calls did not report their return codes")
    return reference


def compare_encodings(ghost: str, coverage: str, work: Path, source: Path) -> dict:
    ghost_output = work / "foreign-ghost-output"
    conversion = run([ghost, "--quiet", "--merge-coverage", str(work / "verilator/combined"),
                      "--save-coverage", str(ghost_output)], work)
    lcov = work / "foreign-verilator.info"
    reverse = run([coverage, "--write-info", str(lcov), str(work / "ghost/combined")], work)
    counts = lcov_counts(lcov, cover_sites(source), source) if lcov.is_file() else ()
    checked_formats = {
        "different_payloads": digest(work / "ghost/combined") != digest(work / "verilator/combined"),
        "ghost_rejects_foreign_database": conversion.returncode != 0 and not ghost_output.exists(),
        "verilator_no_hits_from_foreign_database": not counts,
    }
    return {"checks": checked_formats, "ghost_exit": conversion.returncode, "verilator_exit": reverse.returncode,
            "pass": all(checked_formats.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--verilator-coverage", default="verilator_coverage")
    parser.add_argument("--ghost", help="optional executable for the second storage format")
    parser.add_argument("--profile", type=Path, help="private Ghost runtime profile")
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    if bool(args.ghost) != bool(args.profile):
        parser.error("--ghost and --profile must be provided together")
    commands = {"verilator": shutil.which(args.verilator), "converter": shutil.which(args.verilator_coverage)}
    if args.ghost:
        commands["ghost"] = shutil.which(args.ghost)
    if not all(commands.values()):
        parser.error("requested executable unavailable")
    commands = {name: str(Path(path).absolute()) for name, path in commands.items()}
    artifacts = {name: Path(path).resolve() for name, path in commands.items()}
    backend = artifacts["verilator"].with_name("verilator_bin")
    if backend.is_file():
        artifacts["verilator_backend"] = backend
    if args.profile:
        artifacts["profile"] = args.profile
    hashes = {name: digest(path) for name, path in artifacts.items()}
    profile = json.loads(args.profile.read_bytes()) if args.profile else None
    if profile and "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    source = CASES[CASE]
    inputs, checker = suite_results.input_digest(source), checker_digest()
    result = {"inputs_sha256": inputs}
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        result["verilator"] = verilator_database(commands["verilator"], commands["converter"], work, source)
        if profile:
            result["ghost"] = ghost_database(commands["ghost"], profile, work, source)
            result["encodings"] = compare_encodings(commands["ghost"], commands["converter"], work, source)
    if (hashes != {name: digest(path) for name, path in artifacts.items()}
            or inputs != suite_results.input_digest(source) or checker != checker_digest()):
        parser.exit(2, "The storage qualification inputs changed during execution.\n")
    passed = all(stage["pass"] for key, stage in result.items() if key != "inputs_sha256")
    result["pass"] = passed
    report = {"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
              "verilator_version": suite_results.tool_version([commands["verilator"], "--version"]),
              "tests": {CASE: result}}
    args.json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"{'PASS' if passed else 'FAIL'}: named coverage storage and merge")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

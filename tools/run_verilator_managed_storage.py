#!/usr/bin/env python3
"""Measure class storage with the same generated model retained and released."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_verilator
import suite_results


CHECKER = "tools/run_verilator_managed_storage.py"
PROFILE = "verilator-managed-storage"
CASE = "ch8/test_class_managed_storage_lifetime"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
HEAP_LINE = re.compile(r"heap (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) handle=([01])")
SAMPLES = ("baseline", "object", "dynamic_array", "associative_array", "string", "final", "handle")
MINIMUM_GROWTH = (1, 8192 * 4, 2048 * 4, 262144)
SAMPLING_TOLERANCE_BYTES = 4096


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def assess(trials: dict, expected: list[str]) -> dict:
    if any(not trial["samples"] or trial["exit"] != 0 or trial["asan_report"]
           or trial["stdout"][:-1] != expected for trial in trials.values()):
        return {"pass": False}
    retained, dropped = (trials[mode]["samples"] for mode in ("retained", "dropped"))
    growth = {}
    for mode, trial in trials.items():
        samples = trial["samples"]
        growth[mode] = {after: samples[after] - samples[before]
                        for before, after in zip(SAMPLES[:4], SAMPLES[1:5])}
    # Compare final samples relative to each process's starting heap, with
    # the C call and scheduler activity held constant by the retained run.
    paired_release = (retained["final"] - retained["baseline"]) - (dropped["final"] - dropped["baseline"])
    populated = dropped["string"] - dropped["baseline"]
    measured_growth = all(all(delta >= minimum for delta, minimum in zip(row.values(), MINIMUM_GROWTH))
                          for row in growth.values())
    passed = (retained["handle"] == 1 and dropped["handle"] == 0 and measured_growth
              and dropped["final"] < dropped["string"]
              and abs(paired_release - populated) <= SAMPLING_TOLERANCE_BYTES)
    return {"growth_bytes": growth, "paired_release_bytes": paired_release,
            "populated_bytes": populated, "pass": passed}


def observe(verilator: Path, fixture: Path, work: Path) -> dict:
    native = fixture.with_suffix(".c")
    for source in (fixture, native):
        shutil.copyfile(source, work / source.name)
    sanitizer = "-fsanitize=address"
    build = run_verilator.execute([
        str(verilator), "--binary", "--timing", "-Wno-fatal", "--top-module", fixture.stem,
        "--prefix", "Vmeasure", "-CFLAGS", "-DMEASURE_MANAGED_HEAP", "-CFLAGS", sanitizer,
        "-LDFLAGS", sanitizer, fixture.name, native.name,
    ], 120, cwd=str(work))
    if build.returncode:
        raise ValueError(f"Verilator build failed ({build.returncode})")

    trials = {}
    for mode, args in (("retained", []), ("dropped", ["+drop_handle"])):
        result = subprocess.run([work / "obj_dir" / "Vmeasure", "+observe_heap", *args],
                                cwd=work, capture_output=True, text=True, errors="replace", timeout=30,
                                env={**os.environ, "ASAN_OPTIONS": "detect_leaks=0"})
        lines = [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]
        data = HEAP_LINE.fullmatch(lines[-1]) if lines else None
        samples = dict(zip(SAMPLES, map(int, data.groups()), strict=True)) if data else None
        trials[mode] = {"exit": result.returncode, "asan_report": "AddressSanitizer" in result.stderr,
                        "stdout": lines, "samples": samples}
    expected = suite_results.expected_output(fixture).splitlines()
    return {"build_exit": build.returncode, "trials": trials, **assess(trials, expected)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    verilator = args.verilator.absolute()
    if not verilator.is_file():
        parser.error("Verilator is unavailable")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    checker, runner = checker_digest(), suite_results.runner_digest("verilator")
    binary = digest(verilator)
    version = suite_results.tool_version([str(verilator), "--version"])
    try:
        with tempfile.TemporaryDirectory() as directory:
            outcome = observe(verilator, fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Managed storage observation stopped ({error}).\n")
    if (binary != digest(verilator) or checker != checker_digest()
            or runner != suite_results.runner_digest("verilator") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools or inputs changed during qualification.\n")

    config = {"evidence_profile": PROFILE, "checker_sha256": checker,
              "artifact_sha256": {"verilator": binary}, "sanitizer": "address",
              "sampling_tolerance_bytes": SAMPLING_TOLERANCE_BYTES}
    verdict = ("pass", "") if outcome["pass"] else ("fail", "managed storage controls or heap measurements differed")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: verdict}, inputs=inputs,
                        configuration=config, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": config, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **outcome}}}, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], CASE)
    return int(not outcome["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

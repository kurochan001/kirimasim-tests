#!/usr/bin/env python3
"""Observe Verilator class destruction while checking a separate C allocation with ASan."""

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


CHECKER = "tools/run_verilator_class_collection.py"
PROFILE = "verilator-class-collection"
CASE = "ch8/test_class_collection_leaves_foreign_allocation"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
MARKER = "collection_sample native destructor"
DESTRUCTOR = re.compile(r"^    ~\w*collection_sample\(\) \{\}$", re.MULTILINE)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def observe(verilator: Path, make: Path, fixture: Path, work: Path) -> dict:
    foreign = fixture.with_suffix(".c")
    for source in (fixture, foreign):
        shutil.copyfile(source, work / source.name)
    sanitize = "-fsanitize=address"
    generate = run_verilator.execute([
        str(verilator), "--cc", "--main", "--exe", "--timing", "-Wno-fatal", "--prefix", "Vcollection",
        "--top-module", fixture.stem, "-CFLAGS", sanitize, "-LDFLAGS", sanitize,
        fixture.name, foreign.name,
    ], 60, cwd=str(work))
    if generate.returncode:
        raise ValueError(f"Verilator generation failed ({generate.returncode})")
    build = [str(make), "-C", "obj_dir", "-f", "Vcollection.mk"]
    trials = {}
    for mode in ("plain", "traced"):
        if mode == "traced":
            headers = list((work / "obj_dir").glob("*collection_sample__Vclpkg.h"))
            if len(headers) != 1:
                raise ValueError("could not locate the generated collection_sample class header")
            text = headers[0].read_text(encoding="utf-8")
            matches = list(DESTRUCTOR.finditer(text))
            if len(matches) != 1:
                raise ValueError("could not isolate the generated empty destructor")
            declaration = matches[0][0]
            patched = declaration[:-1] + f' std::puts("{MARKER}"); std::fflush(stdout); }}'
            headers[0].write_text("#include <cstdio>\n" + text.replace(declaration, patched, 1), encoding="utf-8")
        # The class body is inline in the generated header. Force the second
        # build to recompile it even when make did not track that dependency.
        flags = ["-B"] if mode == "traced" else []
        built = run_verilator.execute([*build, *flags], 120, cwd=str(work))
        if built.returncode:
            raise ValueError(f"Verilator {mode} build failed ({built.returncode})")
        result = subprocess.run([work / "obj_dir" / "Vcollection"], cwd=work, capture_output=True,
                                text=True, errors="replace", timeout=30,
                                env={**os.environ, "ASAN_OPTIONS": "detect_leaks=0"})
        stdout = [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]
        trials[mode] = {"build_exit": built.returncode, "exit": result.returncode,
                        "asan_report": "AddressSanitizer" in result.stderr, "stdout": stdout}
    expected = suite_results.expected_output(fixture).splitlines()
    expected_traced = [*expected[:2], MARKER, expected[2]]
    passed = (trials["plain"]["stdout"] == expected and trials["traced"]["stdout"] == expected_traced
              and all(run["exit"] == 0 and not run["asan_report"] for run in trials.values()))
    return {"generated_header": headers[0].name, "destructor": declaration.strip(), "trials": trials, "pass": passed}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    verilator = args.verilator.absolute()
    make = shutil.which("make")
    if make is None or not verilator.is_file():
        parser.error("Verilator and make are required")
    fixture = CASES[CASE]
    checker, runner = checker_digest(), suite_results.runner_digest("verilator")
    inputs = suite_results.fingerprints([fixture])
    version = suite_results.tool_version([str(verilator), "--version"])
    fingerprint = digest(verilator)
    try:
        with tempfile.TemporaryDirectory() as directory:
            outcome = observe(verilator, Path(make), fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Class collection observation could not run ({error}).\n")
    if (fingerprint != digest(verilator) or checker != checker_digest()
            or runner != suite_results.runner_digest("verilator") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools or inputs changed during qualification.\n")
    config = {"evidence_profile": PROFILE, "checker_sha256": checker,
              "artifact_sha256": {"verilator": fingerprint}, "sanitizer": "address", "leak_detection": False}
    verdict = ("pass", "") if outcome["pass"] else ("fail", "class destruction or foreign allocation control differed")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: verdict}, inputs=inputs,
                        configuration=config, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": config, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **outcome}}}, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], CASE)
    return int(not outcome["pass"])


if __name__ == "__main__":
    raise SystemExit(main())

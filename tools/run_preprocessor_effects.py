#!/usr/bin/env python3
"""Check line-record emission and optional undef diagnostics with Verilator."""

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


CHECKER = "tools/run_preprocessor_effects.py"
PROFILE = "verilator-preprocessor-effects"
LINE = "ch22/test_preprocessor_line_emission_modes_preserve_manual_origin"
UNDEF = "ch22/test_undef_never_defined_macro_preserves_other_definitions"
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (LINE, UNDEF)}
LINE_RECORD = re.compile(r'^\s*`line\s+(\d+)\s+"([^"]+)"\s+([012])\s*$')
MISSING_NAME = "VT_NEVER_DEFINED_MACRO"
MISSING_UNDEF = "`undef " + MISSING_NAME
WARNING = re.compile(r"^%Warning(?:-[^:]+)?: ([^:]+):(\d+):\d+:\s*(.*)$")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def line_records(output: str) -> list[dict]:
    records = []
    for text in output.splitlines():
        if match := LINE_RECORD.fullmatch(text):
            records.append({"file": Path(match[2]).name, "line": int(match[1]), "level": int(match[3])})
        elif re.match(r"^\s*`line\b", text):
            raise ValueError("the preprocessor emitted a malformed line record")
    return records


def undef_warnings(stderr: str) -> list[dict]:
    found = []
    for text in stderr.splitlines():
        if match := WARNING.match(text):
            if MISSING_NAME in match[3] or re.search(r"\bundef(?:ine|ining)?\b", match[3], re.I):
                found.append({"file": Path(match[1]).name, "line": int(match[2]),
                              "missing_macro_named": MISSING_NAME in match[3]})
    return found


def compile_and_run(executable: Path, work: Path, source: str, fixture: Path) -> dict:
    build = run_verilator.execute(
        [str(executable), "--binary", "--timing", "-Wall", "-Wno-fatal",
         "--top-module", fixture.stem, "--Mdir", "obj", "-o", "probe", source],
        run_verilator.BUILD_TIMEOUT, cwd=str(work),
    )
    result = {"compile_exit": build.returncode, "undef_warnings": undef_warnings(build.stderr)}
    if build.returncode == 0:
        run = run_verilator.execute(["./obj/probe"], run_verilator.RUN_TIMEOUT, cwd=str(work))
        expected = suite_results.expected_output(fixture).splitlines()
        actual = [text for text in run.stdout.splitlines() if not run_verilator.BANNER.match(text)]
        result.update(simulation_exit=run.returncode, expected=expected,
                      observed=[text for text in actual if text in expected],
                      simulation_matches=actual == expected)
    return result


def completed(trial: dict) -> bool:
    return (trial["compile_exit"] == 0 and trial["simulation_exit"] == 0
            and trial["simulation_matches"])


def line_is_qualified(trials: dict, source: str) -> bool:
    emitted, omitted = trials["emitted"], trials["omitted"]
    if any(trial["preprocessor_exit"] != 0 or not completed(trial) for trial in trials.values()):
        return False
    records = emitted["line_records"]
    return (not omitted["line_records"]
            and {"file": "reviewed_origin.sv", "line": 700, "level": 0} in records
            and any(r["file"] == "payload.svh" and r["level"] == 1 for r in records)
            and any(r["file"] == source and r["level"] == 2 for r in records))


def undef_is_qualified(trials: dict, source: str, line: int) -> bool:
    control, unknown = trials["control"], trials["unknown"]
    target = {"file": source, "line": line, "missing_macro_named": True}
    return (completed(control) and completed(unknown)
            and not control["undef_warnings"] and unknown["undef_warnings"] in ([], [target]))


def probe_line(executable: Path, fixture: Path) -> tuple[bool, dict]:
    trials = {}
    for name, options in (("emitted", []), ("omitted", ["-P"])):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            shutil.copyfile(fixture, work / fixture.name)
            shutil.copyfile(fixture.parent / "line_emission/payload.svh", work / "payload.svh")
            output = run_verilator.execute(
                [str(executable), "-E", *options, fixture.name], run_verilator.BUILD_TIMEOUT, cwd=directory)
            trial = {"preprocessor_exit": output.returncode}
            if output.returncode == 0:
                trial["line_records"] = line_records(output.stdout)
                (work / "preprocessed.sv").write_text(output.stdout, encoding="utf-8")
                trial.update(compile_and_run(executable, work, "preprocessed.sv", fixture))
            trials[name] = trial
    return line_is_qualified(trials, fixture.name), trials


def probe_undef(executable: Path, fixture: Path) -> tuple[bool, dict]:
    source = fixture.read_text(encoding="utf-8")
    control = source.splitlines(keepends=True)
    site, = (n for n, text in enumerate(control, 1) if text.rstrip("\n") == MISSING_UNDEF)
    control[site - 1] = "\n"
    trials = {}
    for name, text in (("control", "".join(control)), ("unknown", source)):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            (work / fixture.name).write_text(text, encoding="utf-8")
            trials[name] = compile_and_run(executable, work, fixture.name, fixture)
    return undef_is_qualified(trials, fixture.name, site), {"site": site, **trials}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    program = shutil.which(args.verilator)
    if program is None:
        parser.error("Verilator is unavailable")
    launcher = Path(program).resolve()
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    binaries = {"launcher": launcher}
    if backend is not None:
        binaries["compiler"] = Path(backend).resolve()
    binary_hashes = {name: digest(path) for name, path in binaries.items()}
    version = suite_results.tool_version([str(launcher), "--version"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("verilator")
    inputs = suite_results.fingerprints(list(CASES.values()))
    records, results = {}, {}
    for case, probe in ((LINE, probe_line), (UNDEF, probe_undef)):
        try:
            passed, detail = probe(launcher, CASES[case])
        except (OSError, ValueError, subprocess.TimeoutExpired):
            passed, detail = False, {"error": "could not complete or decode the tool run"}
        status = "pass" if passed else "fail"
        results[case] = (status, "" if passed else "preprocessor effect or a control differed")
        records[case] = {"inputs_sha256": inputs[case], "status": status, **detail}
        print(f"{case}: {status}")

    if (binary_hashes != {name: digest(path) for name, path in binaries.items()}
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Compiler, checker or test input changed during qualification.\n")
    config = {"evidence_profile": PROFILE, "checker_sha256": checker_hash, "binaries_sha256": binary_hashes}
    suite_results.write(args.json, "verilator", "Verilator", version, results, inputs=inputs,
                        runner_sha256=runner_hash, configuration=config)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "version": version, "configuration": config, "runner_sha256": runner_hash,
        "tests": records,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

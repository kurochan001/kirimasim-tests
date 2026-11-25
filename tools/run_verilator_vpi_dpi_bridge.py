#!/usr/bin/env python3
"""Qualify VPI activation and DPI export scope selection in separate Verilator models."""

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


PROFILE = "verilator-vpi-dpi-bridge"
CHECKER = "tools/run_verilator_vpi_dpi_bridge.py"
ACTIVATION = "ch35/test_dpi_context_requires_separate_vpi_activation"
SCOPE = "ch35/test_dpi_vpi_callback_selects_export_scope"
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (ACTIVATION, SCOPE)}
VPI_SYMBOLS = ("vpi_handle_by_name", "vpi_get_value", "vpi_release_handle")
LINK_ERROR = re.compile(r"undefined (?:symbols?|reference)", re.I)
SCOPE_ERROR = re.compile(r"read_scope_token.*(?:scope wasn't set|missing svSetScope)", re.I)
SCOPE_PREFIXES = ("callback ", "same instances=", "unscoped=")
WITHOUT_SCOPE = "calling export without setting scope"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def build(verilator: str, fixture: Path, cwd: Path, options: list[str],
          source: Path) -> subprocess.CompletedProcess:
    command = [verilator, *options, "--timing", "-Wno-fatal", "--top-module", fixture.stem,
               "--prefix", "Vt", "-Mdir", "obj", str(fixture), str(source)]
    return run_verilator.execute(command, run_verilator.BUILD_TIMEOUT, cwd=cwd)


def run(cwd: Path, options: tuple[str, ...] = ()) -> subprocess.CompletedProcess:
    return run_verilator.execute([str(cwd / "obj" / "Vt"), *options], run_verilator.RUN_TIMEOUT, cwd=cwd)


def activation_trials(verilator: str, fixture: Path, directory: Path) -> dict:
    source = run_verilator.c_source(fixture, "dpi_c")
    control_output = ["context=1 value=-3 released=0"]
    expected = suite_results.expected_output(fixture).splitlines()
    scenarios = {"enabled": ["--vpi"], "context_only": ["-CFLAGS", "-DDPI_CONTEXT_ONLY"], "disabled": []}
    observations = {}
    for name, flags in scenarios.items():
        work = directory / name
        work.mkdir()
        compiled = build(verilator, fixture, work, ["--binary", *flags], source)
        trial = {"build_exit": compiled.returncode, "pass": False}
        if name == "disabled":
            messages = compiled.stderr + "\n" + compiled.stdout
            missing = [symbol for symbol in VPI_SYMBOLS if re.search(rf"\b_?{symbol}\b", messages)]
            trial.update(missing_vpi_symbols=missing,
                         diagnostics=[line for line in messages.splitlines()
                                      if LINK_ERROR.search(line) or any(symbol in line for symbol in missing)])
            trial["pass"] = compiled.returncode > 0 and bool(LINK_ERROR.search(messages)) and missing == list(VPI_SYMBOLS)
        elif compiled.returncode == 0:
            proc = run(work)
            output = [line for line in proc.stdout.splitlines() if line.startswith("context=")]
            want = expected if name == "enabled" else control_output
            trial.update(run_exit=proc.returncode, stdout=output)
            trial["pass"] = proc.returncode == 0 and output == want
        else:
            trial["diagnostics"] = [line for line in compiled.stderr.splitlines() if line.startswith("%Error")]
        observations[name] = trial
    return {"trials": observations, "pass": all(trial["pass"] for trial in observations.values())}


def scope_trials(verilator: str, fixture: Path, directory: Path) -> dict:
    source = fixture.parent / suite_results.header(fixture)["files"]
    compiled = build(verilator, fixture, directory, ["--cc", "--exe", "--build", "--vpi"], source)
    if compiled.returncode != 0:
        return {"pass": False, "build_exit": compiled.returncode,
                "diagnostics": [line for line in compiled.stderr.splitlines() if line.startswith("%Error")]}
    ordinary = suite_results.expected_output(fixture).splitlines()
    initial = "callback initial scope=0"
    observations = {}
    for name, options in (("selected", ()), ("unset", ("--without-scope",))):
        proc = run(directory, options)
        output = [line for line in proc.stdout.splitlines() if line.startswith(SCOPE_PREFIXES)]
        messages = (proc.stderr + "\n" + proc.stdout).splitlines()
        diagnosis = [line for line in messages if SCOPE_ERROR.search(line)]
        trial = {"returncode": proc.returncode, "stdout": output, "scope_diagnostics": diagnosis}
        if name == "selected":
            trial["pass"] = proc.returncode == 0 and output == [initial, "callback scopes=37,91", *ordinary]
        else:
            # An out-of-DPI call without a selected scope has tool-specific behavior.
            diagnosed = proc.returncode != 0 and output == [initial] and bool(diagnosis)
            returned = (proc.returncode == 0 and len(output) == 2 + len(ordinary)
                        and output[0] == initial and re.fullmatch(r"unscoped=-?\d+", output[1]) is not None
                        and output[2:] == ordinary)
            trial["attempted"] = WITHOUT_SCOPE in messages
            trial["outcome"] = "diagnosed" if diagnosed else "returned" if returned else "unverified"
            trial["pass"] = trial["attempted"] and (diagnosed or returned)
        observations[name] = trial
    return {"build_exit": compiled.returncode, "trials": observations,
            "pass": all(trial["pass"] for trial in observations.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    tool = shutil.which(args.verilator)
    if not tool:
        parser.error("Verilator executable is required")
    executable = str(Path(tool).absolute())
    launcher = Path(tool).resolve()
    artifacts = {"launcher": launcher}
    backend = Path(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    if backend.is_file():
        artifacts["backend"] = backend
    hashes = {name: digest(path) for name, path in artifacts.items()}
    checker = checker_digest()
    runner = suite_results.runner_digest("verilator")
    version = suite_results.tool_version([executable, "--version"])
    inputs = suite_results.fingerprints(list(CASES.values()))
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            activation = work / "activation"
            scope = work / "scope"
            activation.mkdir()
            scope.mkdir()
            results = {ACTIVATION: activation_trials(executable, CASES[ACTIVATION], activation),
                       SCOPE: scope_trials(executable, CASES[SCOPE], scope)}
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("verilator")
            or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "Simulator, checker or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "binary_sha256": hashes}
    statuses = {case: ("pass", "") if result["pass"] else ("fail", "DPI and VPI observations differed")
                for case, result in results.items()}
    suite_results.write(args.json, "verilator", "Verilator", version, statuses,
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "verilator", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {case: {"inputs_sha256": inputs[case], **result} for case, result in results.items()},
    }, indent=2) + "\n", encoding="utf-8")
    for case, result in results.items():
        print(case, result)
    return int(not all(result["pass"] for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

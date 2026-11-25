#!/usr/bin/env python3
"""Check C linkage and detect escaped exceptions in a native C++ caller."""

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


PROFILE = "verilator-dpi-cxx-boundary"
CHECKER = "tools/run_dpi_cxx_boundary.py"
CASE = "ch35/test_dpi_cxx_function_and_task_boundaries"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
DIAGNOSTIC_REQUIREMENTS = {"SV2023-35.5.1.6-EXTRACT-CXX-BOUNDARY"}
DIAGNOSTIC_ANCHOR = "undefined (?:symbols?|reference)"
UNDEFINED = re.compile(DIAGNOSTIC_ANCHOR, re.I)
SYMBOLS = ("cxx_boundary_function", "cxx_boundary_task")
VARIANTS = {
    "control": (),
    "cpp_linkage": ("-DDPI_PROBE_CPP_LINKAGE",),
    "escape": ("-DDPI_PROBE_ESCAPE",),
}
NATIVE_OUTPUT = {
    "control": ["function returned value=-19 caught=1", "task returned status=0 value=-29 caught=1"],
    "escape": ["function exception reached native caller", "task exception reached native caller"],
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def command(arguments: list[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(arguments, cwd=cwd, capture_output=True, text=True, errors="replace", timeout=60)


def native_trial(cxx: str, caller: Path, implementation: Path, work: Path, variant: str) -> dict:
    flags = VARIANTS[variant]
    caller_flags = flags if variant == "escape" else ()
    built_caller = command([cxx, "-std=c++17", *caller_flags, "-c", str(caller), "-o", "caller.o"], work)
    built_impl = command([cxx, "-std=c++17", *flags, "-c", str(implementation), "-o", "implementation.o"], work)
    result = {"compile_exits": [built_caller.returncode, built_impl.returncode], "pass": False}
    if result["compile_exits"] != [0, 0]:
        result["diagnostics"] = (built_caller.stderr + built_impl.stderr).replace(str(implementation.parent) + "/", "")
        return result
    linked = command([cxx, "caller.o", "implementation.o", "-o", "native_caller"], work)
    result["link_exit"] = linked.returncode
    if variant == "cpp_linkage":
        messages = linked.stderr + "\n" + linked.stdout
        missing = [symbol for symbol in SYMBOLS if re.search(rf"\b_?{symbol}\b", messages)]
        result.update(missing_c_symbols=missing,
                      diagnostics=[line for line in messages.splitlines()
                                   if UNDEFINED.search(line) or any(symbol in line for symbol in missing)])
        result["pass"] = linked.returncode > 0 and bool(UNDEFINED.search(messages)) and missing == list(SYMBOLS)
    elif linked.returncode == 0:
        call = command([str(work / "native_caller")], work)
        output = call.stdout.splitlines()
        result.update(run_exit=call.returncode, stdout=output)
        result["pass"] = call.returncode == 0 and output == NATIVE_OUTPUT[variant]
    else:
        result["diagnostics"] = linked.stderr
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--cxx", default=os.environ.get("CXX", "c++"))
    parser.add_argument("--json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    tools = {"verilator": shutil.which(args.verilator), "cxx": shutil.which(args.cxx)}
    if not all(tools.values()):
        parser.error("Verilator and a C++ compiler are required")
    executable = str(Path(tools["verilator"]).absolute())
    compiler = str(Path(tools["cxx"]).absolute())
    artifacts = {name: Path(path).resolve() for name, path in tools.items()}
    backend = Path(os.environ.get("VERILATOR_BIN", str(artifacts["verilator"].with_name("verilator_bin"))))
    if backend.is_file():
        artifacts["verilator_backend"] = backend
    hashes = {name: digest(path) for name, path in artifacts.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("verilator")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    fields = suite_results.header(fixture)
    implementation = fixture.parent / fields["dpi_c"].removeprefix("@")
    caller = fixture.parent / fields["files"]
    version = suite_results.tool_version([executable, "--version"])
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory).resolve()
            native = {variant: native_trial(compiler, caller, implementation, work, variant) for variant in VARIANTS}
    except (OSError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    matched, reason = run_verilator.run(fixture, executable, 1, run_verilator.install_prefix(executable))
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("verilator") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "binary_sha256": hashes,
                     "cxx_version": suite_results.tool_version([compiler, "--version"]), "seed": 1}
    passed = matched and all(trial["pass"] for trial in native.values())
    outcome = ("pass", "") if passed else ("fail", "C linkage or exception boundary observation differed")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: outcome},
                        inputs=inputs, configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "tool": "verilator", "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "pass": passed, "native": native,
                         "simulation": {"pass": matched, "reason": reason}}},
    }, indent=2) + "\n", encoding="utf-8")
    for variant, trial in native.items():
        print(variant, trial)
    print(f"simulation: {'pass' if matched else reason}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Observe selected SystemVerilog defaults without source-level overrides."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_verilator
import suite_results


CHECKER = "tools/run_language_defaults.py"
TIMESCALE = "ch3/test_selected_defaults_set_time_unit_and_precision"
KEYWORDS = "ch22/test_selected_default_keyword_set_controls_bit"
PROFILES = {tool: f"{tool}-language-defaults" for tool in ("ghost", "icarus", "verilator")}
CASES = {tool: {case: suite_results.ROOT / "tests" / (case + ".sv")}
         for tool, case in (("ghost", TIMESCALE), ("icarus", KEYWORDS), ("verilator", TIMESCALE))}
SCALES = {
    "1ns/100ps": "unit=1.000 absolute=1.000 fraction=0.300",
    "10ns/10ps": "unit=1.000 absolute=0.100 fraction=0.263",
}
LEGACY_DECLARATION = "wire bit = 1'b1;"
CURRENT_DECLARATION = "bit selected = 1'b1;"


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_verilator.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def invoke(command, directory):
    return subprocess.run(command, cwd=directory, capture_output=True, text=True, timeout=120)


def timescale_checks(tool, executable, test):
    observations = {}
    for scale, expected in SCALES.items():
        with tempfile.TemporaryDirectory() as work:
            if tool == "ghost":
                build = None
                result = invoke([str(executable), "--quiet-all", "--lrm-strict", "--timescale", scale,
                                 str(test), "+report_default_steps"], work)
            else:
                build = invoke([str(executable), "--binary", "--timing", "--timescale", scale,
                                "--top-module", test.stem, "--Mdir", "obj", "-o", "probe", str(test)], work)
                result = invoke(["./obj/probe", "+report_default_steps"], work) if build.returncode == 0 else None
        code = result.returncode if result else None
        lines = [] if result is None else [line for line in result.stdout.splitlines()
                                           if not run_verilator.BANNER.match(line)]
        expected_lines = [expected, *suite_results.expected_output(test).splitlines()]
        observations[scale] = {"pass": code == 0 and lines == expected_lines,
                               "compiler_exit": None if build is None else build.returncode,
                               "run_exit": code,
                               "observed_steps": [line for line in lines if re.fullmatch(
                                   r"unit=\d+\.\d+ absolute=\d+\.\d+ fraction=\d+\.\d+", line)],
                               "expected_steps": expected}
    return observations


def keyword_checks(executable, vvp, test):
    original = test.read_text(encoding="utf-8")
    if original.count(LEGACY_DECLARATION) != 1 or original.count(", bit);") != 1:
        raise ValueError("expected one declaration and one read of the keyword probe signal")
    current = original.replace(LEGACY_DECLARATION, CURRENT_DECLARATION).replace(", bit);", ", selected);")
    line = original.count("\n", 0, original.index(LEGACY_DECLARATION)) + 1
    location = re.compile(rf"^{re.escape(test.name)}:{line}(?=[:\s]).*\b(?:syntax error|Invalid module (?:item|instantiation))\b",
                          re.I | re.M)
    observations = {}
    with tempfile.TemporaryDirectory() as work:
        source = Path(work) / test.name
        for label, text, supported in (("identifier", original, "2005"), ("type", current, "2012")):
            source.write_text(text, encoding="utf-8")
            for mode in ("2005", "2012"):
                build = invoke([str(executable), "-g" + mode, "-s", test.stem,
                                "-o", "probe.vvp", source.name], work)
                at_line = bool(location.search(build.stderr))
                if mode == supported:
                    result = invoke([str(vvp), "probe.vvp"], work) if build.returncode == 0 else None
                    observed = result.stdout.splitlines() if result else []
                    passed = bool(result and result.returncode == 0
                                  and observed == suite_results.expected_output(test).splitlines())
                else:
                    observed = []
                    passed = build.returncode > 0 and at_line
                observations[f"{label}_{mode}"] = {
                    "pass": passed, "compiler_exit": build.returncode,
                    "diagnosed_at_declaration": at_line, "simulation_matched": bool(observed) and passed,
                }
    return observations


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=PROFILES, required=True)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    if program is None:
        parser.error("the simulator executable is unavailable")
    executable = Path(program).resolve()
    binaries = {"executable": executable}
    if args.tool == "icarus":
        vvp = executable.with_name("vvp")
        if shutil.which(vvp) is None:
            parser.error("the Icarus runtime is unavailable beside the compiler")
        binaries["runtime"] = vvp
    if args.tool == "verilator" and executable.with_name("verilator_bin").is_file():
        binaries["backend"] = executable.with_name("verilator_bin")
    hashes = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
    checker = checker_digest()
    runner = suite_results.runner_digest(args.tool)
    case, = CASES[args.tool]
    test = CASES[args.tool][case]
    inputs = suite_results.fingerprints([test])
    try:
        checks = (keyword_checks(executable, vvp, test) if case == KEYWORDS
                  else timescale_checks(args.tool, executable, test))
    except (OSError, subprocess.TimeoutExpired):
        checks = {"tool_execution": {"pass": False}}
    if (hashes != {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
            or checker != checker_digest() or inputs != suite_results.fingerprints([test])):
        parser.exit(2, "The tool, checker or test changed during execution.\n")
    passed = bool(checks) and all(item["pass"] for item in checks.values())
    verdict = ("pass", "") if passed else ("fail", "selected default did not produce the expected result")
    version_arg = "-V" if args.tool == "icarus" else "--version"
    version = (f"private build {hashes['executable'][:12]}" if args.tool == "ghost"
               else suite_results.tool_version([str(executable), version_arg]))
    configuration = {"evidence_profile": PROFILES[args.tool], "checker_sha256": checker,
                     "binary_sha256": hashes}
    suite_results.write(args.json, args.tool, "Ghost" if args.tool == "ghost" else args.tool,
                        version, {case: verdict}, inputs=inputs, runner_sha256=runner,
                        configuration=configuration)
    args.observations.write_text(json.dumps({"tool": args.tool, "version": version, **configuration,
                                             "case": case, "inputs_sha256": inputs[case], "checks": checks},
                                            indent=2) + "\n", encoding="utf-8")
    print(f"{verdict[0].upper()} {case}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

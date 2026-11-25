#!/usr/bin/env python3
"""Qualify optional string-literal diagnostics and duplicate-attribute warnings."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_ghost
import suite_results


CHECKER = "tools/run_optional_lexical.py"
OCTAL = "ch5/test_string_octal_escape_outside_byte_range"
RAW = "ch5/test_raw_control_byte_string_literal"
ATTRIBUTE = "ch5/test_duplicate_attribute_advisory_sites"
CASES = {"ghost": (OCTAL, RAW), "slang": (OCTAL, RAW, ATTRIBUTE)}
PROFILES = {tool: f"{tool}-optional-lexical" for tool in CASES}
RAW_LITERAL = b"L\x0bR"
ESCAPED_LITERAL = rb"L\vR"
OCTAL_CONTROL = rb'"L\376R"'
OCTAL_TRIAL = rb'"L\400R"'


def digest(binary: Path) -> str:
    return hashlib.sha256(binary.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def unique_site(source: bytes, fragment: bytes) -> int:
    if source.count(fragment) != 1:
        raise ValueError("the source must contain exactly one diagnostic site")
    return source.count(b"\n", 0, source.index(fragment)) + 1


def source_variants(case: str, original: bytes) -> tuple[bytes, bytes, int]:
    if case == OCTAL:
        line = unique_site(original, OCTAL_CONTROL)
        return original, original.replace(OCTAL_CONTROL, OCTAL_TRIAL), line
    line = unique_site(original, RAW_LITERAL)
    return original.replace(RAW_LITERAL, ESCAPED_LITERAL), original, line


def run(command: list[str], directory: Path) -> subprocess.CompletedProcess:
    return subprocess.run(command, cwd=directory, capture_output=True, text=True,
                          errors="replace", timeout=90)


def ghost_observation(result: subprocess.CompletedProcess, filename: str) -> dict:
    messages = run_ghost.ANSI.sub("", result.stdout + "\n" + result.stderr)
    source_error = re.compile(rf"{re.escape(filename)}:(\d+):\d+: error: (.*)", re.IGNORECASE)
    errors = []
    for line in messages.splitlines():
        local = source_error.fullmatch(line.strip())
        if local:
            errors.append({"line": int(local[1]), "message": local[2]})
        elif re.search(r"(?:^|:\s+)error:|^\[(?:ERROR|FATAL)\]", line, re.IGNORECASE):
            errors.append({"line": None, "message": "error outside the source site"})
    output = run_ghost.ANSI.sub("", result.stdout)
    return {"exit": result.returncode,
            "errors": errors,
            "values": [line for line in output.splitlines()
                       if line.startswith(("in_range=", "variant=", "raw="))]}


def assess_ghost(case: str, observations: dict, expected: list[str], site: int) -> bool:
    control, trial = observations["control"], observations["trial"]
    if control["exit"] != 0 or control["errors"] or control["values"] != expected:
        return False
    if trial["exit"] == 0 and not trial["errors"]:
        values = trial["values"]
        if case == RAW:
            return values == expected
        return (len(values) == 2 and values[0] == expected[0]
                and re.fullmatch(r"variant=[0-9a-fA-FxXzZ]+", values[1]) is not None)
    if trial["exit"] <= 0 or len(trial["errors"]) != 1:
        return False
    error = trial["errors"][0]
    wording = (r"OctalEscapeCodeTooBig|octal.*(?:too large|range)" if case == OCTAL else
               r"non.?printable|control (?:byte|character)|invalid (?:byte|character)|vertical tab")
    return error["line"] == site and re.search(wording, error["message"], re.IGNORECASE) is not None


def slang_observation(executable: Path, source: Path, options: tuple[str, ...]) -> dict:
    diagnostic_path = source.with_suffix(".json")
    diagnostic_path.unlink(missing_ok=True)
    result = run([str(executable), "--std=1800-2023", "--diag-json", diagnostic_path.name,
                  *options, source.name], source.parent)
    if not diagnostic_path.is_file():
        raise ValueError("compiler did not produce structured diagnostics")
    codes = json.loads(diagnostic_path.read_text(encoding="utf-8"))
    return {"exit": result.returncode,
            "diagnostics": [{key: item.get(key) for key in ("severity", "code", "location")}
                            for item in codes]}


def assess_slang(case: str, observations: dict, filename: str, site: int) -> bool:
    control, trial = observations["control"], observations["trial"]
    if control != {"exit": 0, "diagnostics": []}:
        return False
    if trial == control:
        return True
    if trial["exit"] <= 0 or len(trial["diagnostics"]) != 1:
        return False
    diagnostic = trial["diagnostics"][0]
    return (diagnostic["severity"] == "error"
            and (diagnostic["code"] == "OctalEscapeCodeTooBig" if case == OCTAL else
                 diagnostic["code"] in ("InvalidEncodingByte", "InvalidUTF8Seq", "IllegalCharacter"))
            and (diagnostic["location"] or "").startswith(f"{filename}:{site}:"))


def lexical_case(tool: str, executable: Path, fixture: Path, working: Path, case: str):
    baseline, stimulus, site = source_variants(case, fixture.read_bytes())
    working_file = working / fixture.name
    observations = {}
    for label, contents in (("control", baseline), ("trial", stimulus)):
        working_file.write_bytes(contents)
        if tool == "ghost":
            result = run([str(executable), "--quiet-all", "--lrm-strict",
                          working_file.name], working)
            observations[label] = ghost_observation(result, fixture.name)
        else:
            observations[label] = slang_observation(executable, working_file, ())
    if tool == "ghost":
        expected = suite_results.expected_output(fixture).splitlines()
        passed = assess_ghost(case, observations, expected, site)
    else:
        passed = assess_slang(case, observations, fixture.name, site)
    return passed, {"stimulus_line": site, **observations}


def attribute_case(executable: Path, fixture: Path, working: Path):
    contents = fixture.read_text(encoding="utf-8")
    sites = []
    for number, line in enumerate(contents.splitlines(), 1):
        if line.endswith("// duplicate site"):
            sites.append(f"{fixture.name}:{number}:{line.rindex('mark') + 1}")
    if len(sites) != 2:
        raise ValueError("the test must contain two duplicate attribute sites")
    source = working / fixture.name
    source.write_text(contents, encoding="utf-8")
    enabled = slang_observation(executable, source, ("-Wdup-attr",))
    suppressed = slang_observation(executable, source, ("-Wno-dup-attr",))
    expected = [{"severity": "warning", "code": "DuplicateAttribute", "location": site}
                for site in sites]
    passed = (enabled == {"exit": 0, "diagnostics": expected}
              and suppressed == {"exit": 0, "diagnostics": []})
    return passed, {"expected_diagnostic_sites": sites, "enabled": enabled, "suppressed": suppressed}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", required=True, choices=CASES)
    parser.add_argument("--simulator", required=True, help="Ghost or Slang executable")
    parser.add_argument("--json", type=Path, help="also write simulation verdicts for Ghost")
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    if program is None:
        parser.error("the selected executable is unavailable")
    if args.json and args.tool != "ghost":
        parser.error("--json is available only for simulation verdicts")
    executable = Path(program).resolve()
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES[args.tool]}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    binary_hash = digest(executable)
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest(args.tool)
    version = (f"private build {binary_hash[:12]}" if args.tool == "ghost" else
               suite_results.tool_version([str(executable), "--version"]))
    records, results = {}, {}
    for case, fixture in fixtures.items():
        try:
            with tempfile.TemporaryDirectory() as directory:
                if case == ATTRIBUTE:
                    passed, detail = attribute_case(executable, fixture, Path(directory))
                else:
                    passed, detail = lexical_case(args.tool, executable, fixture, Path(directory), case)
        except (OSError, ValueError, subprocess.TimeoutExpired):
            passed, detail = False, {"error": "could not complete or decode the tool run"}
        status = "pass" if passed else "fail"
        results[case] = (status, "" if passed else "optional behavior or its control differed")
        records[case] = {"status": status, "inputs_sha256": inputs[case], **detail}
        print(f"{case}: {status}")

    if (binary_hash != digest(executable) or checker_hash != checker_digest()
            or runner_hash != suite_results.runner_digest(args.tool)
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Tool, checker, or input changed during qualification.\n")
    config = {"evidence_profile": PROFILES[args.tool], "checker_sha256": checker_hash,
              "binary_sha256": binary_hash}
    if args.json:
        suite_results.write(args.json, "ghost", "Ghost", version, results, inputs=inputs,
                            runner_sha256=runner_hash, configuration=config)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "tool": args.tool, "version": version, "configuration": config,
        "runner_sha256": runner_hash, "tests": records,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

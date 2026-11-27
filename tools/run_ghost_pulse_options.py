#!/usr/bin/env python3
"""Project reference launch options onto specify/SDF and compare Ghost waveforms."""

import argparse
from fractions import Fraction
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

import run_ghost
import suite_results


PROFILE = "ghost-pulse-option-reference"
CHECKER = "tools/run_ghost_pulse_options.py"
LIMITS = "ch30/test_global_pulse_limit_sources"
STYLE = "ch30/test_specify_pulsestyle_ondetect"
CANCELLATION = "ch30/test_showcancelled_negative_pulse_x"
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (LIMITS, STYLE, CANCELLATION)}
DIAGNOSTIC_REQUIREMENTS = {
    "SV2023-30.7.2-EXTRACT-GLOBAL-PULSE-ORDER-ERROR",
    "SV2023-30.7.2-EXTRACT-GLOBAL-PULSE-PERCENTAGES",
}
DIAGNOSTIC_ANCHOR = "def invocation_limits("
CONFIGURATIONS = {
    "defaults": (None, None, (100, 100), None),
    "per_transition": ("25", "75", (25, 75), None),
    "correct_reversed": ("50", "25", (50, 50), "error percentage is below reject percentage"),
    "minimum_and_maximum": ("0", "100", (0, 100), None),
    "zero_percent": ("0", "0", (0, 0), None),
    "maximum_percent": ("100", "100", (100, 100), None),
}
PULSES = ((30, 3), (60, 5), (90, 6), (120, 9), (150, 10), (180, 15))


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(suite_results.runner_digest("ghost").encode())
    return digest.hexdigest()


def percentage(option: str, text: str | None) -> int:
    if text is None:
        return 100
    if not re.fullmatch(r"[+-]?[0-9]+", text) or not 0 <= int(text) <= 100:
        raise ValueError(f"{option} percentage must be an integer from 0 to 100")
    return int(text)


def invocation_limits(reject: str | None, error: str | None) -> tuple[tuple[int, int], str | None]:
    reject_value, error_value = percentage("reject", reject), percentage("error", error)
    if error_value < reject_value:
        return (reject_value, reject_value), "error percentage is below reject percentage"
    return (reject_value, error_value), None


def projected_sdf(source: str, reject: int, error: int, *, ignore_priority: bool = False) -> tuple[str, list[str]]:
    modules = dict(re.findall(r"(?ms)^module (\w+)\([^\n]*\);\n(.*?)^endmodule", source))
    annotated = set(re.findall(r"\(INSTANCE (\w+)\)", source))
    selected, cells = [], []
    for cell, instance in re.findall(r"(?m)^  (global_pulse_\w+) (\w+)\(a, \w+\);$", source):
        if not ignore_priority and (instance in annotated or "PATHPULSE$" in modules[cell]):
            continue
        selected.append(instance)
        cells.append(f'(CELL (CELLTYPE "{cell}") (INSTANCE {instance})\n'
                     f' (DELAY (ABSOLUTE (PATHPULSEPERCENT a y ({reject}) ({error})))))')
    return '\n'.join(['(DELAYFILE (SDFVERSION "3.0") (TIMESCALE 1ns)', *cells, ')', '']), selected


def pulse_events(start: int, width: int, new: int, lead_delay: int, trail_delay: int,
                 limits: tuple[Fraction, Fraction]) -> list[str]:
    first, last = start + lead_delay, start + width + trail_delay
    # Section 30.7 measures the scheduled output pulse with the trailing transition's limits.
    if last <= first or last - first < limits[0]:
        return []
    value = new if last - first >= limits[1] else "x"
    return [f"{first}:{value}", f"{last}:{1 - new}"]


def expected_limit_trace(label: str, rise: int, fall: int, settings: tuple[int, int],
                         *, percentage_limits: bool) -> str:
    def limits(delay: int) -> tuple[Fraction, Fraction]:
        reject, error = settings
        if percentage_limits:
            return Fraction(reject * delay, 100), Fraction(error * delay, 100)
        return Fraction(reject), Fraction(error)

    edges = [edge for start, width in PULSES for edge in pulse_events(start, width, 1, rise, fall, limits(fall))]
    edges.append(f"{240 + rise}:1")
    edges.extend(pulse_events(270, 5, 0, fall, rise, limits(rise)))
    return f"{label}: " + " ".join(edges)


def ghost_run(ghost: Path, profile: dict, work: Path, case: str, source: str,
              sdf: str | None = None, args: tuple[str, ...] = ()) -> dict:
    work.mkdir()
    path = work / CASES[case].name
    path.write_text(source, encoding="utf-8")
    if sdf is not None:
        (work / "invocation.sdf").write_text(sdf, encoding="utf-8")
        args = (*args, "+invocation_projection")
    invocation = [str(ghost), *profile["arguments"], *args, path.name]
    run = subprocess.run(invocation, cwd=work, env={**os.environ, **profile["environment"]},
                         capture_output=True, text=True, errors="replace", timeout=30)
    return {"exit": run.returncode, "stdout": run_ghost.normalize(run.stdout, profile).splitlines()}


def matches(run: dict, expected: list[str]) -> bool:
    return run == {"exit": 0, "stdout": expected}


def invalid_options() -> dict:
    rejections = {}
    for name, index in (("reject", 0), ("error", 1)):
        for value in ("-1", "101", "24.5", "text"):
            arguments = ["25", "75"]
            arguments[index] = value
            label = f"{name}={value}"
            try:
                invocation_limits(*arguments)
            except ValueError as error:
                diagnostic = str(error)
            else:
                diagnostic = None
            rejections[label] = {
                "diagnostic": diagnostic,
                "pass": diagnostic == f"{name} percentage must be an integer from 0 to 100",
            }
    return rejections


def limit_checks(ghost: Path, profile: dict, work: Path) -> dict:
    source = CASES[LIMITS].read_text(encoding="utf-8")
    configurations = {}
    for name, (reject, error, required, required_diagnostic) in CONFIGURATIONS.items():
        resolved, diagnostic = invocation_limits(reject, error)
        sdf, instances = projected_sdf(source, *resolved)
        use_projection = reject is not None or error is not None
        expected = [
            expected_limit_trace("fast", 10, 10, required, percentage_limits=True),
            expected_limit_trace("asym", 12, 8, required, percentage_limits=True),
            expected_limit_trace("local", 10, 10, (4, 7), percentage_limits=False),
            expected_limit_trace("sdf", 10, 10, (1, 5), percentage_limits=False),
        ]
        actual = ghost_run(ghost, profile, work / name, LIMITS, source, sdf=sdf if use_projection else None)
        configurations[name] = {
            "arguments": [reject, error], "resolved": resolved, "diagnostic": diagnostic,
            "projected_instances": instances if use_projection else [], "expected": expected, "actual": actual,
            "pass": (resolved == required and diagnostic == required_diagnostic and matches(actual, expected)
                     and (use_projection or expected == suite_results.expected_output(CASES[LIMITS]).splitlines())),
        }
    invalid = invalid_options()
    # A projection that replaces either explicit source must be detected by its changed trace.
    conflicting, overridden = projected_sdf(source, 25, 75, ignore_priority=True)
    wrong = ghost_run(ghost, profile, work / "override_explicit", LIMITS, source, sdf=conflicting)
    baseline = configurations["per_transition"]["expected"]
    precedence_control = (wrong["exit"] == 0 and len(wrong["stdout"]) == 4 and wrong["stdout"][:2] == baseline[:2]
                          and all(got != want for got, want in zip(wrong["stdout"][2:], baseline[2:], strict=True)))
    return {"configurations": configurations, "invalid": invalid,
            "priority_control": {"projected_instances": overridden, "actual": wrong, "pass": precedence_control},
            "pass": (all(row["pass"] for row in configurations.values())
                     and all(row["pass"] for row in invalid.values()) and precedence_control)}


def style_checks(ghost: Path, profile: dict, work: Path) -> dict:
    source = CASES[STYLE].read_text(encoding="utf-8")
    control_expected = suite_results.expected_output(CASES[STYLE]).splitlines()
    control = ghost_run(ghost, profile, work / "local_style", STYLE, source)
    options = {}
    for mode, leading in (("onevent", 16), ("ondetect", 13)):
        variant, declarations = re.subn(r"(?m)^    pulsestyle_(?:onevent|ondetect) ", f"    pulsestyle_{mode} ", source)
        expected = [f"{label}: {leading}:x 19:0 36:1 43:0" for label in ("ondetect y", "onevent z")]
        actual = ghost_run(ghost, profile, work / mode, STYLE, variant)
        options[mode] = {"expected": expected, "actual": actual, "pass": declarations == 2 and matches(actual, expected)}
    return {"local": control, "options": options,
            "pass": matches(control, control_expected) and all(row["pass"] for row in options.values())}


def cancellation_checks(ghost: Path, profile: dict, work: Path) -> dict:
    source = CASES[CANCELLATION].read_text(encoding="utf-8")
    control_expected = suite_results.expected_output(CASES[CANCELLATION]).splitlines()
    control = ghost_run(ghost, profile, work / "local_cancellation", CANCELLATION, source)
    labels = [line.split(":")[0] for line in control_expected]
    options = {}
    for policy in ("showcancelled", "noshowcancelled"):
        variant, declarations = re.subn(
            r"(?m)^  specify\n(?:    (?:no)?showcancelled y;\n)?", f"  specify\n    {policy} y;\n", source)
        insert = (" 15:x 17:1",) * 3 + (" 12:x 17:1",) if policy == "showcancelled" else ("",) * 4
        expected = [f"{label}:{signal} end 1" for label, signal in zip(labels, insert, strict=True)]
        actual = ghost_run(ghost, profile, work / policy, CANCELLATION, variant)
        options[policy] = {"expected": expected, "actual": actual,
                           "pass": declarations == 4 and matches(actual, expected)}
    return {"local": control, "options": options,
            "pass": matches(control, control_expected) and all(row["pass"] for row in options.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True, type=Path)
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    ghost = args.ghost.resolve()
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if not ghost.is_file() or "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost executable and a strict runtime profile are required")
    binary = hashlib.sha256(ghost.read_bytes()).hexdigest()
    inputs = {case: suite_results.input_digest(path) for case, path in CASES.items()}
    checker = checker_digest()
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        results = {LIMITS: limit_checks(ghost, profile, work), STYLE: style_checks(ghost, profile, work),
                   CANCELLATION: cancellation_checks(ghost, profile, work)}
    if (checker != checker_digest() or binary != hashlib.sha256(ghost.read_bytes()).hexdigest()
            or profile_bytes != args.profile.read_bytes()
            or any(inputs[case] != suite_results.input_digest(path) for case, path in CASES.items())):
        parser.exit(2, "Tools or test inputs changed during qualification.\n")
    for name, result in results.items():
        result["inputs_sha256"] = inputs[name]
        print(f"{name}: {'pass' if result['pass'] else 'fail'}")
    record = {"profile": PROFILE, "checker_sha256": checker, "ghost_sha256": binary,
              "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(), "tests": results}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    return int(not all(result["pass"] for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

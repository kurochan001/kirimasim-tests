#!/usr/bin/env python3
"""Replay Ghost controls and observations for rules with permitted outcomes."""

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
import suite_results


CHECKER = "tools/run_ghost_language_latitude.py"
PROFILE = "ghost-language-latitude"
CALLER = "ch9/test_function_disable_caller_observation"
METHOD = "ch9/test_event_method_unrelated_member_observation"
UNIQUE = "ch12/test_unique_overlap_optional_evaluation"
NULL_WAIT = "ch15/test_null_event_wait_observation"
ASSIGNMENT_PATTERN = "ch10/test_assignment_pattern_side_effect_observation"
TAGGED_UNION = "ch7/test_tagged_union_initial_tag_and_unused_bits"
RNG_STATES = "ch18/test_rng_state_format_and_replay"
PROGRAM_EXIT = "ch24/test_exit_outside_program_optional_warning"
SCHEDULING = "ch4/test_active_sample_and_reactive_settling"
ASSERTION_GLITCH = "ch16/test_assertion_clock_multiple_transitions_observation"
PROGRAM_CLOCK = "ch24/test_design_and_program_assertion_clocks"
PORT_STARTUP = "ch23/test_port_type_time_zero_events"
MAILBOX_BOUND = "ch15/test_mailbox_negative_bound_observation"
LOCATOR_EFFECT = "ch7/test_locator_with_side_effect_observation"
DEFPARAM_CALL = "ch13/test_defparam_constant_function_observation"
PRODUCTION_VALUE = "ch18/test_randsequence_ungenerated_result_observation"
PROPERTY_INIT = "ch8/test_class_property_before_initializer_observation"
VARIABLE_STRENGTH = "ch6/test_variable_drive_strength_warning_observation"
UNIQUE_CONTRACT = "ch12/test_unique_and_unique0_condition_contract"
COMBINED_PHASES = "ch3/test_combined_compile_elaboration_results"
PHASE_OPTIONS = {"parse": "--parse-only", "compile": "--compile-only", "elaborate": "--elaborate-only"}
OVERLAP_DIAGNOSTICS = {"if": "unique if", "case": "unique case",
                       "unique": "unique if", "unique0": "unique0 if"}
PATTERN_VALUES = {"type": "555", "default": "666", "replication": "777"}
CASES = {
    CALLER: {"task": ["+define+OBSERVE_CALLER_TASK"], "block": ["+define+OBSERVE_CALLER_BLOCK"]},
    METHOD: {"write": ["+observe_evaluations"], "omit": ["+observe_evaluations", "+omit_unused"]},
    UNIQUE: {"if": ["+overlap_if"], "case": ["+overlap_case"]},
    NULL_WAIT: {name: ["+define+OBSERVE_NULL_WAIT", f"+observe_null_{name}"]
                for name in ("event", "triggered")},
    ASSIGNMENT_PATTERN: {
        "array_type": ["+define+OBSERVE_ARRAY_TYPE_KEY", "+array_type"],
        **{mode: [f"+{mode}"] for mode in ("array_default", "array_replication",
                                         "struct_type", "struct_default", "struct_replication")},
    },
    TAGGED_UNION: {"representation": ["+observe_raw"]},
    RNG_STATES: {"format": ["+observe_state"], "unrecognized": ["+define+OBSERVE_UNKNOWN_STATE"]},
    PROGRAM_EXIT: {"outside": ["+observe_module_exit"]},
    SCHEDULING: {"writer_first": ["+observe_active"],
                 "reader_first": ["+define+READER_DECLARED_FIRST", "+observe_active"]},
    ASSERTION_GLITCH: {"glitch": ["+observe_glitch"]},
    PROGRAM_CLOCK: {"program_clock": ["+observe_program_clock"]},
    PORT_STARTUP: {"startup": ["+observe_startup"]},
    MAILBOX_BOUND: {"negative": ["+observe_negative"]},
    LOCATOR_EFFECT: {"impure": ["+observe_effect"]},
    DEFPARAM_CALL: {"defparam": ["+define+OBSERVE_DEFPARAM"]},
    PRODUCTION_VALUE: {"ungenerated": ["+define+OBSERVE_UNGENERATED"]},
    PROPERTY_INIT: {"early": ["+define+OBSERVE_BEFORE_INITIALIZER"]},
    VARIABLE_STRENGTH: {"explicit": ["+define+OBSERVE_STRENGTH"]},
    UNIQUE_CONTRACT: {"unique": ["+overlap_unique"], "unique0": ["+overlap_zero"]},
    COMBINED_PHASES: {
        **{mode: [option] for mode, option in PHASE_OPTIONS.items()},
        **{f"unbound_{mode}": [option, "+define+OBSERVE_UNBOUND_COMPONENT"]
           for mode, option in PHASE_OPTIONS.items()},
        "unbound_combined": ["+define+OBSERVE_UNBOUND_COMPONENT"],
    },
}
EVALUATION = re.compile(r"evaluated t=(\d+) value=(\d+)")
TAGGED_BITS = re.compile(r"initial=[01xz]{14} short gaps=[01xz]{9},[01xz]{9} "
                         r"empty payloads=[01xz]{12},[01xz]{12}", re.IGNORECASE)
DECIMAL_OBSERVATION = r"(?:-?\d+|[xXzZ])"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def run(simulator: Path, fixture: Path, profile: dict, args: list[str], sites: dict) -> dict:
    with tempfile.TemporaryDirectory() as directory:
        shutil.copyfile(fixture, Path(directory) / fixture.name)
        try:
            result = subprocess.run([simulator, *profile["arguments"], *args, fixture.name],
                                    cwd=directory, env={**os.environ, **profile["environment"]},
                                    capture_output=True, text=True, errors="replace", timeout=20)
        except (OSError, subprocess.TimeoutExpired):
            return {"exit": -1, "stdout": [], "overlap": [], "evaluations": []}

    messages = run_ghost.ANSI.sub("", result.stdout + "\n" + result.stderr)
    warnings = []
    for message in messages.splitlines():
        for construct, site in sites.items():
            diagnostic = OVERLAP_DIAGNOSTICS.get(construct)
            if (diagnostic and f"{fixture.name}:{site}:" in message
                    and diagnostic in message.casefold()
                    and "multiple" in message.casefold()):
                warnings.append(construct)

    observed, evaluations = [], []
    for text in run_ghost.normalize(result.stdout, profile).splitlines():
        if match := EVALUATION.fullmatch(text):
            evaluations.append({"time": int(match[1]), "value": int(match[2])})
        elif not text.startswith(("$warning: unique ", "$warning: unique0 ")):
            observed.append(text)
    evidence = {"exit": result.returncode, "stdout": observed, "overlap": warnings,
                "evaluations": evaluations}
    if "outside_exit" in sites:
        site = f"{fixture.name}:{sites['outside_exit']}:"
        evidence["outside_exit_warnings"] = sum(
            "warning" in line and "$exit" in line and (site in line or "ignored" in line)
            for line in messages.casefold().splitlines())
    if "negative_mailbox" in sites:
        site = f"{fixture.name}:{sites['negative_mailbox']}:"
        evidence["negative_bound_diagnostics"] = sum(
            ("warning" in line or "error" in line) and re.search(r"\bnegative\b", line) is not None
            and (site in line or ("mailbox" in line and "bound" in line))
            for line in messages.casefold().splitlines())
    if "variable_driver" in sites:
        site = f"{fixture.name}:{sites['variable_driver']}:"
        evidence["strength_diagnostics"] = sum(
            site in line and "strength" in line.partition(site)[2]
            and ("warning" in line or "error" in line) for line in messages.casefold().splitlines())
    if "unbound_component" in sites:
        site = f"{fixture.name}:{sites['unbound_component']}:"
        evidence["unbound_errors"] = sum(
            site in line and "error" in line and "phase_missing" in line
            for line in messages.casefold().splitlines())
        if args:
            evidence["stdout"] = [line for line in observed if line.startswith("resolved port=")]
    return evidence


def control_matches(trial: dict, expected: list[str]) -> bool:
    return trial["exit"] == 0 and trial["stdout"] == expected and not trial["overlap"]


def trial_matches(case: str, mode: str, trial: dict, expected: list[str]) -> bool:
    stdout = trial["stdout"]
    if case == CALLER:
        return trial["exit"] >= 0 and stdout[:2] == [f"caller {mode} begins", f"before disabling caller {mode}"]
    if case == METHOD:
        return control_matches(trial, expected) and bool(trial["evaluations"])
    if case == RNG_STATES and mode == "unrecognized":
        marker = [*expected, "before setting manually constructed state"]
        return trial["exit"] >= 0 and stdout[:len(marker)] == marker
    if case == RNG_STATES:
        return (trial["exit"] == 0 and len(stdout) == len(expected) + 2 and stdout[:-2] == expected
                and all(re.fullmatch(rf"{owner} size=\d+ prefix=[0-9a-f]{{2}},[0-9a-f]{{2}}", line,
                                     re.IGNORECASE) for owner, line in zip(("object", "process"), stdout[-2:])))
    if case == PROGRAM_EXIT:
        return (trial["exit"] == 0 and "outside_exit_warnings" in trial
                and stdout == ["module calls exit at t=1", *expected])
    if case == SCHEDULING:
        return (trial["exit"] == 0 and stdout[1:] == expected
                and re.fullmatch(r"active t=1 stage=[012]", stdout[0]) is not None)
    if case == ASSERTION_GLITCH:
        return (trial["exit"] == 0 and len(stdout) == 2 and stdout[0] == "same slot edges emitted t=1"
                and re.fullmatch(r"assertion passes=\d+ failures=\d+", stdout[1]) is not None)
    if case == PROGRAM_CLOCK:
        first, last = expected
        return trial["exit"] == 0 and stdout == [first, "program clock t=3 sampled=0 live=1", last]
    if case == PORT_STARTUP:
        return (trial["exit"] == 0 and len(stdout) == len(expected) + 1 and stdout[:-1] == expected
                and re.fullmatch(r"startup events=\d+,\d+", stdout[-1]) is not None)
    if case == MAILBOX_BOUND:
        marker = [*expected, "before constructing mailbox with negative bound"]
        return trial["exit"] >= 0 and stdout[:len(marker)] == marker
    if case == LOCATOR_EFFECT:
        return (trial["exit"] == 0 and len(stdout) == len(expected) + 1 and stdout[:-1] == expected
                and re.fullmatch(r"impure locator calls=\d+ count=\d+", stdout[-1]) is not None)
    if case == DEFPARAM_CALL:
        result = rf"defparam results={DECIMAL_OBSERVATION},{DECIMAL_OBSERVATION}"
        return (trial["exit"] == 0 and len(stdout) == len(expected) + 1 and stdout[:-1] == expected
                and re.fullmatch(result, stdout[-1]) is not None)
    if case == PRODUCTION_VALUE:
        return (trial["exit"] == 0 and len(stdout) == len(expected) + 1 and stdout[1:] == expected
                and re.fullmatch(rf"before generation={DECIMAL_OBSERVATION}", stdout[0]) is not None)
    if case == PROPERTY_INIT:
        result = rf"base argument={DECIMAL_OBSERVATION} final property=29"
        return (trial["exit"] == 0 and len(stdout) == len(expected) and stdout[:-1] == expected[:-1]
                and re.fullmatch(result, stdout[-1]) is not None)
    if case == VARIABLE_STRENGTH:
        return control_matches(trial, expected) and "strength_diagnostics" in trial
    if case == UNIQUE_CONTRACT:
        return trial["exit"] == 0 and stdout == expected and trial["overlap"] == [mode]
    if case == COMBINED_PHASES:
        if stdout:
            return False
        errors = trial.get("unbound_errors")
        if mode in PHASE_OPTIONS:
            return trial["exit"] == 0 and errors == 0
        if mode in ("unbound_parse", "unbound_compile") and trial["exit"] == 0:
            return errors == 0
        return trial["exit"] > 0 and errors == 1
    if case in (ASSIGNMENT_PATTERN, TAGGED_UNION):
        if trial["exit"] != 0 or len(stdout) != len(expected) + 1 or stdout[:-1] != expected:
            return False
        if case == TAGGED_UNION:
            return TAGGED_BITS.fullmatch(stdout[-1]) is not None
        aggregate, key = mode.split("_")
        # The key's value is fixed. The number of calls is an observation.
        return re.fullmatch(rf"{aggregate} {key} calls=\d+ values={PATTERN_VALUES[key]}", stdout[-1]) is not None
    if case == NULL_WAIT:
        operation = "event control" if mode == "event" else "triggered wait"
        before = [expected[0], f"before null {operation}"]
        returned = f"null {operation} returned"
        return (trial["exit"] == 0 and stdout[:2] == before and stdout[-1:] == expected[-1:]
                and stdout[2:-1] in ([], [returned]))
    if case == UNIQUE:
        lines = [r"if selected=10 visited=111", r"case selected=10 visited=111"]
        index = ("if", "case").index(mode)
        # The third visit may be omitted after two true conditions/items.
        lines[index] = lines[index].replace("111", "[01]11")
        return (trial["exit"] == 0 and trial["overlap"] == [mode] and len(stdout) == len(lines)
                and all(re.fullmatch(pattern, text) for pattern, text in zip(lines, stdout)))
    raise ValueError(f"unknown case: {case}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    simulator = args.simulator.resolve()
    if not simulator.is_file():
        parser.error("Ghost executable is unavailable")
    profile = json.loads(args.profile.read_text(encoding="utf-8"))
    profile_hash = digest(args.profile)
    binary_hash = digest(simulator)
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    results, observations = {}, {}
    for case, fixture in fixtures.items():
        sites = {}
        if case == UNIQUE:
            for number, text in enumerate(fixture.read_text(encoding="utf-8").splitlines(), 1):
                for construct in ("if", "case"):
                    if text.lstrip().startswith(f"unique {construct} ("):
                        sites[construct] = number
        if case == PROGRAM_EXIT:
            _, sites["outside_exit"] = (number for number, text in enumerate(
                fixture.read_text(encoding="utf-8").splitlines(), 1) if text.strip() == "$exit;")
        if case == MAILBOX_BOUND:
            sites["negative_mailbox"], = (number for number, text in enumerate(
                fixture.read_text(encoding="utf-8").splitlines(), 1) if text.strip() == "invalid = new(-1);")
        if case in (VARIABLE_STRENGTH, COMBINED_PHASES, UNIQUE_CONTRACT):
            markers = {
                VARIABLE_STRENGTH: {"variable_driver": "assign (pull1, weak0) value = stimulus;"},
                COMBINED_PHASES: {"unbound_component": "phase_missing u(settled);"},
                UNIQUE_CONTRACT: {"unique": "unique if (selector == 0)",
                                  "unique0": "unique0 if (selector == 0)"},
            }
            lines = fixture.read_text(encoding="utf-8").splitlines()
            for label, marker in markers[case].items():
                sites[label], = (number for number, text in enumerate(lines, 1) if text.strip() == marker)
        expected = suite_results.expected_output(fixture).splitlines()
        control = run(simulator, fixture, profile, [], sites)
        trials = {mode: run(simulator, fixture, profile, flags, sites) for mode, flags in CASES[case].items()}
        passed = (control_matches(control, expected)
                  and all(trial_matches(case, mode, trial, expected) for mode, trial in trials.items()))
        status = "pass" if passed else "fail"
        results[case] = (status, "" if passed else "control or observation criterion differed")
        observations[case] = {"status": status, "inputs_sha256": inputs[case], "control": control,
                              "trials": trials, "diagnostic_lines": sites}
        print(f"{case}: {status}")

    if (binary_hash != digest(simulator) or profile_hash != digest(args.profile)
            or checker_hash != checker_digest() or runner_hash != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Simulator, profile, checker or inputs changed during observation.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                     "binary_sha256": binary_hash, "runtime_profile_sha256": profile_hash}
    version = f"private build {binary_hash[:12]}"
    suite_results.write(args.json, "ghost", "Ghost", version, results, inputs=inputs,
                        runner_sha256=runner_hash, configuration=configuration)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "schema": 1, "version": version, "configuration": configuration,
        "runner_sha256": runner_hash, "tests": observations,
    }, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())

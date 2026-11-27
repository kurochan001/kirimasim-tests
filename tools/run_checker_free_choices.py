#!/usr/bin/env python3
"""Enumerate checker assumption witnesses with Yosys and optionally replay them in Ghost."""

import argparse
import hashlib
from itertools import product
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_ghost
import suite_results


CHECKER = "tools/run_checker_free_choices.py"
PROFILE = "checker-choice-reference"
CASE = "ch17/test_checker_free_joint_solutions"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SEEDS = (1, 7, 31, 73, 101, 509)
PREDICATE = re.compile(r"^  (\w+): assume property \(@\(posedge sample_clk\) (.+)\)$", re.M)
SIGNALS = ("key", "held", "x", "y")
SAT_VALUE = re.compile(r"^\s*(\d+)\s+\\(key|held|x|y)\s+(\d+)\s+", re.M)
TRACE_VALUE = re.compile(r"choice step=([01]) key=([0-3]) held=([0-3]) x=([0-3]) y=([0-3]) failed=(\d+)")
SEED_VALUE = re.compile(r"seed control=([0-9a-f]{8})")


def digest(path: Path) -> str:
    with path.open("rb") as binary:
        return hashlib.file_digest(binary, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("ghost")).encode()).hexdigest()


def formal_source(source: str, key_attribute: str) -> str:
    predicates = dict(PREDICATE.findall(source))
    if tuple(predicates) != ("different", "relation", "range_check", "contradiction"):
        raise ValueError("expected four labelled, single-cycle checker assumptions")
    assumptions = "\n".join(f"    assume({expr});" for expr in predicates.values())
    return f"""module checker_free_formal;
  (* {key_attribute} *) wire [1:0] key;
  (* anyseq *) wire [1:0] held, x, y;
  (* anyseq *) wire impossible;
  always @* begin
{assumptions}
  end
endmodule
"""


def failure_mask(choice: tuple, impossible: bool = False) -> int:
    key, held, x, y = choice
    return ((x == held) | ((y != (x ^ held ^ key)) << 1)
            | ((y == 3) << 2) | ((impossible and x != held) << 3))


def enumerate_sat(yosys: Path, work: Path, source: str, held_steps: tuple,
                  impossible_last: bool = False) -> set[tuple]:
    (work / "model.sv").write_text(source, encoding="utf-8")
    constraints = []
    for step, held in enumerate(held_steps, start=1):
        impossible = int(impossible_last and step == len(held_steps))
        constraints.append(f"-set-at {step} impossible {impossible}")
        if held is not None:
            constraints.append(f"-set-at {step} held {held}")
    command = (
        "read_verilog -formal -sv model.sv; prep -top checker_free_formal; chformal -lower; "
        f"sat -seq {len(held_steps)} -set-assumes {' '.join(constraints)} "
        f"-show {','.join(SIGNALS)} -all"
    )
    result = subprocess.run([str(yosys), "-Q", "-T", "-p", command], cwd=work, check=True,
                            capture_output=True, text=True, timeout=30)
    traces = set()
    for block in result.stdout.split("SAT solving finished - model found:")[1:]:
        values = {(int(step), name): int(value) for step, name, value in SAT_VALUE.findall(block)}
        traces.add(tuple(tuple(values[step, name] for name in SIGNALS)
                         for step in range(1, len(held_steps) + 1)))
    exhaustion = re.search(r"no more models found \(after (\d+) distinct solutions\)", result.stdout)
    if not traces and "SAT solving finished - no model found." in result.stdout:
        return traces
    if exhaustion is None or int(exhaustion[1]) != len(traces):
        raise ValueError("could not verify that the SAT model enumeration was complete")
    return traces


def qualify_formal(yosys: Path, work: Path, source: str) -> tuple[dict, set[tuple]]:
    stable = formal_source(source, "anyconst")
    one_step = enumerate_sat(yosys, work, stable, (None,))
    two_steps = enumerate_sat(yosys, work, stable, (2, 1))
    reselected = enumerate_sat(yosys, work, formal_source(source, "anyseq"), (2, 1))
    contradictory = enumerate_sat(yosys, work, stable, (2, 1), impossible_last=True)

    legal = {choice for choice in product(range(4), repeat=4) if failure_mask(choice) == 0}
    unrestricted = {(first, second) for first, second in product(legal, repeat=2)
                    if first[1] == 2 and second[1] == 1}
    stable_keys = {trace for trace in unrestricted if trace[0][0] == trace[1][0]}
    checks = {
        "all_assumption_consistent_values": one_step == {(choice,) for choice in legal},
        "all_two_step_constant_traces": two_steps == stable_keys,
        "reselected_key_changes_trace_set": reselected == unrestricted and two_steps < reselected,
        "contradictory_step_has_no_witness": not contradictory,
    }
    return {
        "checks": checks,
        "single_step_count": len(one_step),
        "two_step_count": len(two_steps),
        "reselected_key_count": len(reselected),
        "reselected_key_extras": len(reselected - two_steps),
        "contradictory_two_step_count": len(contradictory),
        "single_step_traces": sorted(one_step),
        "two_step_traces": sorted(two_steps),
        "pass": all(checks.values()),
    }, two_steps


def replay_source(source: str) -> str:
    for name in ("key", "x", "y"):
        qualifier = "rand const" if name == "key" else "rand"
        declaration = f"  {qualifier} bit [1:0] {name};"
        if source.count(declaration) != 1:
            raise ValueError(f"could not identify the free variable declaration for {name}")
        source = source.replace(declaration, f"  let {name} = {name}_in;", 1)
    return source


def observe(ghost: Path, profile: dict, fixture: Path, expected: list[str], seed: int,
            arguments: tuple = ()) -> dict:
    with tempfile.TemporaryDirectory() as cwd:
        run = subprocess.run(
            [str(ghost), *profile["arguments"], "--seed", str(seed),
             "-top", suite_results.top_module(fixture), str(fixture), "+print-choices", *arguments],
            cwd=cwd, env={**os.environ, **profile["environment"]},
            capture_output=True, text=True, errors="replace", timeout=90,
        )
    stdout = run_ghost.normalize(run.stdout, profile).splitlines()
    observations, invariant, seed_control = [], [], None
    for line in stdout:
        choice = TRACE_VALUE.fullmatch(line)
        seed_match = SEED_VALUE.fullmatch(line)
        if choice:
            observations.append(tuple(map(int, choice.groups())))
        elif seed_match and seed_control is None:
            seed_control = seed_match[1]
        else:
            invariant.append(line)
    trace = tuple(row[1:5] for row in observations)
    masks = tuple(row[5] for row in observations)
    observed_invariants = (run.returncode == 0 and invariant == expected and seed_control is not None
                           and [row[0] for row in observations] == [0, 1])
    return {"seed": seed, "seed_control": seed_control, "exit": run.returncode, "stdout": stdout,
            "trace": trace, "failure_masks": masks, "invariants_hold": observed_invariants}


def replay_trace(ghost: Path, profile: dict, replay: Path, expected: list[str], trace: tuple,
                 impossible: bool = False) -> dict:
    key, _, x0, y0 = trace[0]
    _, _, x1, y1 = trace[1]
    args = (f"+choice_key={key}", f"+x0={x0}", f"+y0={y0}", f"+x1={x1}", f"+y1={y1}")
    if impossible:
        args += ("+impossible-second",)
    observed = observe(ghost, profile, replay, expected, SEEDS[0], args)
    expected_masks = (failure_mask(trace[0]), failure_mask(trace[1], impossible))
    return {"expected_trace": trace, "expected_masks": expected_masks, "observed": observed,
            "pass": (observed["invariants_hold"] and observed["trace"] == trace
                     and observed["failure_masks"] == expected_masks)}


def qualify_ghost(ghost: Path, profile: dict, work: Path, traces: set[tuple]) -> dict:
    fixture = CASES[CASE]
    replay = work / "replay.sv"
    replay.write_text(replay_source(fixture.read_text(encoding="utf-8")), encoding="utf-8")
    expected = suite_results.expected_output(fixture).splitlines()
    witnesses = [replay_trace(ghost, profile, replay, expected, trace) for trace in sorted(traces)]
    # This input violates three predicates on the first edge and satisfies all
    # four on the second. The other control adds an impossible second step.
    illegal = replay_trace(ghost, profile, replay, expected, ((1, 2, 2, 3), (1, 1, 2, 2)))
    impossible = replay_trace(ghost, profile, replay, expected, ((1, 2, 1, 2), (1, 1, 2, 2)), True)
    native = [observe(ghost, profile, fixture, expected, seed) for seed in SEEDS]
    no_solution = observe(ghost, profile, fixture, expected, SEEDS[0], ("+impossible-second",))
    for row in native:
        row["matches_formal_witness"] = row["trace"] in traces
    checks = {
        "all_formal_witnesses_replayed": bool(witnesses) and all(row["pass"] for row in witnesses),
        "wrong_tuple_sets_only_expected_failures": illegal["pass"] and illegal["expected_masks"] == (7, 0),
        "contradiction_fails_only_on_second_edge": impossible["pass"] and impossible["expected_masks"] == (0, 8),
        "native_constant_and_failure_timing": all(row["invariants_hold"] for row in [*native, no_solution]),
        "ordinary_rng_changed_with_seed": len({row["seed_control"] for row in native}) > 1,
    }
    return {"checks": checks, "replays": witnesses, "illegal_tuple": illegal, "impossible_tuple": impossible,
            "native": native, "native_impossible": no_solution, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--yosys", default="yosys")
    parser.add_argument("--simulator", help="private Ghost executable for optional replays")
    parser.add_argument("--profile", type=Path, help="private Ghost runtime profile")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    if bool(args.simulator) != bool(args.profile):
        parser.error("--simulator and --profile must be specified together")
    yosys_path = shutil.which(args.yosys)
    ghost_path = shutil.which(args.simulator) if args.simulator else None
    if yosys_path is None or (args.simulator and ghost_path is None):
        parser.error("requested Yosys or Ghost executable is unavailable")
    yosys = Path(yosys_path).resolve()
    ghost = Path(ghost_path).resolve() if ghost_path else None
    fixture = CASES[CASE]
    inputs = suite_results.input_digest(fixture)
    checker = checker_digest()
    executables = {tool: digest(tool) for tool in (yosys, ghost) if tool is not None}
    version = subprocess.check_output([str(yosys), "-V"], text=True, timeout=30).strip()
    profile_bytes = args.profile.read_bytes() if args.profile is not None else None
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        formal, traces = qualify_formal(yosys, work, fixture.read_text(encoding="utf-8"))
        replay = qualify_ghost(ghost, json.loads(profile_bytes), work, traces) if ghost else None
    if (inputs != suite_results.input_digest(fixture) or checker != checker_digest()
            or any(digest(tool) != before for tool, before in executables.items())
            or (args.profile and profile_bytes != args.profile.read_bytes())):
        parser.exit(2, "Qualification inputs changed during the run.\n")
    passed = formal["pass"] and (replay is None or replay["pass"])
    report = {"profile": PROFILE, "checker_sha256": checker, "yosys_version": version,
              "yosys_sha256": executables[yosys],
              "tests": {CASE: {"inputs_sha256": inputs, "formal": formal, "pass": passed}}}
    if ghost:
        report.update(ghost_binary_sha256=executables[ghost],
                      ghost_profile_sha256=hashlib.sha256(profile_bytes).hexdigest())
        report["tests"][CASE]["ghost"] = replay
    args.json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"{'PASS' if passed else 'FAIL'}: {formal['single_step_count']} one-step witnesses, "
          f"{formal['two_step_count']} stable-key traces")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())

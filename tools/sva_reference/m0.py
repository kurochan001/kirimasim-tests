"""Reproduce the M0 output-strategy experiment on three fixed pilot inputs.

These small clause-based evaluators are disposable pilot adapters, NOT the
v1 parser/engine. No evaluator or trace capture opens an expected-output file.
Only the final --compare-expected stage does so, after A and B have run.
"""

import argparse
from dataclasses import dataclass
import difflib
import hashlib
import json
from pathlib import Path
import re

from .source import inspect_source, rewrite
from .trace import Tick, Trace, TraceError, capture, load_trace, run_icarus, save_trace


ROOT = Path(__file__).resolve().parents[2]
FIXTURES = Path(__file__).with_name("fixtures")
PILOTS = {
    "test_sequence_goto_nonconsecutive": ("s", "b", "c"),
    "test_property_nexttime_eventually": ("start", "x"),
    "test_property_binary_operator_forms": ("start", "p", "q"),
}


@dataclass(frozen=True)
class Action:
    label: str
    start: int  # zero-based attempt tick
    end: int    # zero-based decision tick
    branch: str


def audit_stimulus(name, trace):
    """Compare every tick with the pilot models' independent stim() inputs.

    Only stimulus functions were transcribed; model output assertions are not
    used to implement the evaluations below. Model files remain outside git.
    """
    rows = []
    if name == "test_sequence_goto_nonconsecutive":
        for phase in range(3):
            rows.extend([(1, 0, 0), (0, 1, 0), (0, int(phase >= 1), 0),
                         (0, int(phase != 1), 0), (0, 0, 1), (0, 0, 0), (0, 0, 0)])
    elif name == "test_property_nexttime_eventually":
        rows = [(int(i == 0), int(i == later)) for later in range(1, 5) for i in range(6)]
    elif name == "test_property_binary_operator_forms":
        patterns = [(0b10000, 0b10000), (0b10000, 0b01000), (0b10000, 0),
                    (0, 0b01000), (0b11000, 0b01000)]
        rows = [(int(i == 0), (p >> (4 - i)) & 1, (q >> (4 - i)) & 1)
                for p, q in patterns for i in range(5)]
    else:
        raise TraceError(f"unknown M0 pilot: {name}")
    if trace.timescale != "1ns" or len(trace.ticks) != len(rows):
        raise TraceError(f"{name}: pilot time unit or tick count differs")
    for i, (tick, expected) in enumerate(zip(trace.ticks, rows)):
        got = tuple(tick.sampled[f"{name}.{signal}"] for signal in PILOTS[name])
        if tick.time != 5 + 10 * i or got != tuple(map(str, expected)):
            raise TraceError(f"{name}: stimulus differs at tick {i + 1}: {got}")


def evaluate(name, trace):
    """Compute action times directly from clauses, without expected outputs."""
    def bit(i, signal):
        value = trace.ticks[i].sampled[f"{name}.{signal}"]
        if value not in {"0", "1"}:
            raise TraceError("M0 pilot evaluators require known Boolean inputs")
        return value == "1"

    actions = []
    if name == "test_sequence_goto_nonconsecutive":
        # 16.9.2: exactly two b ticks strictly between s and c; goto also
        # requires b immediately before c. 16.14.3: first success per attempt.
        for start in range(len(trace.ticks)):
            if not bit(start, "s"):
                continue
            matched = set()
            count = 0
            for end in range(start + 1, len(trace.ticks)):
                for label, allowed in (("c_goto", bit(end - 1, "b")),
                                       ("c_nonconsecutive", True)):
                    if count == 2 and bit(end, "c") and allowed and label not in matched:
                        actions.append(Action(label, start, end, "pass"))
                        matched.add(label)
                count += bit(end, "b")
    elif name == "test_property_nexttime_eventually":
        # 16.12.7, 16.12.10, 16.12.13. All checked windows finish in M0.
        for start in range(len(trace.ticks)):
            if not bit(start, "start"):
                continue
            if start + 3 >= len(trace.ticks):
                raise TraceError("M0 excludes unfinished eventually windows")
            for label, offset in (("a_next", 1), ("a_next2", 2)):
                if not bit(start + offset, "x"):
                    actions.append(Action(label, start, start + offset, "fail"))
            if not any(bit(start + k, "x") for k in (2, 3)):
                actions.extend(Action(label, start, start + 3, "fail")
                               for label in ("a_ev", "a_sev"))
    elif name == "test_property_binary_operator_forms":
        # 16.12.3-.8 and .12: Boolean operands, and earliest decisive tick
        # for until. The strong and weak forms resolve before trace end here.
        for start in range(len(trace.ticks)):
            if not bit(start, "start"):
                continue
            p, q = bit(start, "p"), bit(start, "q")
            immediate = {"a_not": not p, "a_or": p or q, "a_and": p and q,
                         "a_imp": not p or q, "a_iff": p == q}
            actions.extend(Action(label, start, start, "fail")
                           for label, succeeds in immediate.items() if not succeeds)
            for label, overlap in (("a_unt", False), ("a_sunt", False),
                                   ("a_untw", True), ("a_suntw", True)):
                for end in range(start, len(trace.ticks)):
                    if bit(end, "q") and (not overlap or bit(end, "p")):
                        break
                    if not bit(end, "p"):
                        actions.append(Action(label, start, end, "fail"))
                        break
                else:
                    raise TraceError("M0 excludes unresolved until attempts")
    else:
        raise TraceError(f"unknown M0 pilot: {name}")
    return sorted(actions, key=lambda action: (action.end, action.label, action.start))


def adapter_output(name, trace, actions):
    """Option A: test-specific presentation of the action schedule."""
    def count(label, begin, end):
        return sum(a.label == label and begin <= trace.ticks[a.end].time < end for a in actions)

    lines = []
    if name == "test_sequence_goto_nonconsecutive":
        for text, time in (("b on ticks 2 and 4", 61), ("b on ticks 2 and 3", 131),
                           ("b on ticks 2, 3 and 4", 201)):
            lines.append(f"{text}: goto {count('c_goto', 0, time)}, "
                         f"nonconsecutive {count('c_nonconsecutive', 0, time)}")
    elif name == "test_property_nexttime_eventually":
        for phase in range(4):
            counts = [count(label, phase * 60, (phase + 1) * 60)
                      for label in ("a_next", "a_next2", "a_ev", "a_sev")]
            lines.append(f"x after {phase + 1}: nexttime {counts[0]}, nexttime[2] {counts[1]}, "
                         f"eventually {counts[2]}, s_eventually {counts[3]}")
    else:
        patterns = [("10000", "10000"), ("10000", "01000"), ("10000", "00000"),
                    ("00000", "01000"), ("11000", "01000")]
        for phase, (p, q) in enumerate(patterns):
            counts = [count(label, phase * 50, (phase + 1) * 50)
                      for label in ("a_not", "a_or", "a_and", "a_imp", "a_iff",
                                    "a_unt", "a_sunt", "a_untw", "a_suntw")]
            lines.append(f"p {p} q {q}: not {counts[0]}, or {counts[1]}, and {counts[2]}, "
                         f"implies {counts[3]}, iff {counts[4]}")
            lines.append(f"  until {counts[5]}, s_until {counts[6]}, until_with {counts[7]}, "
                         f"s_until_with {counts[8]}")
    return "\n".join(lines) + "\n"


def replay_source(source, trace, actions):
    """Option B EXPERIMENT: #0 module procedures, not Reactive scheduling.

    Preserves duplicate actions, current-value reads and $time. It cannot
    reproduce the ordering after NBA, so it must never be used as an oracle.
    """
    top, directives = inspect_source(source)
    bodies = {d.label: d for d in directives}
    grouped = {d.label: [] for d in directives}
    for action in actions:
        if action.branch not in {"pass", "fail"} or action.label not in bodies:
            raise TraceError("unknown action branch/label")
        if not 0 <= action.start <= action.end < len(trace.ticks):
            raise TraceError("action is outside the trace")
        grouped[action.label].append(action)
    scale = re.search(r"`timescale\s+(\d+\s*\w+)\s*/\s*(\d+\s*\w+)", source)
    # M0 avoids time-unit rounding in the replay experiment.
    if not scale or re.sub(r"\s+", "", scale[1]) != trace.timescale:
        raise TraceError("M0 replay requires VCD precision equal to module timeunit")
    replacements = {}
    for label, group in grouped.items():
        procedure = ["initial begin"]
        previous = 0
        for action in sorted(group, key=lambda a: a.end):
            time = trace.ticks[action.end].time
            body = bodies[label].passed if action.branch == "pass" else bodies[label].failed
            procedure.append(f"  #{time - previous}; #0; {body}")
            previous = time
        procedure.append("end")
        replacements[label] = "\n".join(procedure)
    return top, rewrite(source, replacements)


def normalized(stdout):
    # Only remove known simulator banners; preserve indentation in displays.
    return "\n".join(line for line in stdout.splitlines()
                     if line.strip() and not line.startswith("VCD info:")
                     and not re.match(r"\S+:\d+: \$finish(?:\(\d\))? called at ", line)) + "\n"


def probe_replay_order(iverilog_bin):
    """Demonstrate why #0 replay cannot stand in for Reactive actions.

    By 4.4.2.3-.6 the NBA write precedes a concurrent assertion's action.
    The experiment sees observed=0 while current=1 after the slot, proving
    that an Inactive-region #0 replay is too early. No SVA runs in Icarus.
    """
    source = '''`timescale 1ns/1ns
module replay_order;
  logic clk = 0;
  int current = 0, observed = -1;
  always #5 clk = ~clk;
  always @(posedge clk) current <= 1;
  c: cover property (@(posedge clk) 1) observed = current;
  initial begin
    #6 $display("current=%0d observed=%0d", current, observed);
    $finish;
  end
endmodule
'''
    trace = Trace("1ns", "replay_order.clk", "posedge", {}, [Tick(5, {}, {})], 6)
    top, rewritten = replay_source(source, trace, [Action("c", 0, 0, "pass")])
    stdout, _ = run_icarus(rewritten, top, iverilog_bin)
    actual = normalized(stdout)
    if actual != "current=1 observed=0\n":
        raise TraceError(f"unexpected replay ordering probe: {actual}")
    return {"nba_current": 1, "inactive_replay_read": 0, "reactive_read_from_4_4_2": 1}


def validate_pilot_source(name, source):
    # Audited inputs only: changes in actions, display code, dependencies or
    # stimulus require a fresh independence/adapter audit, not silent reuse.
    manifest = json.loads((FIXTURES / "sources.json").read_text())
    if hashlib.sha256(source).hexdigest() != manifest[name]:
        raise TraceError(f"{name}: source changed; repeat the M0 source audit")


def run_pilots(iverilog_bin=None, refresh=False, compare_expected=False):
    results = []
    for name, signals in PILOTS.items():
        path = ROOT / "tests" / "ch16" / (name + ".sv")
        source = path.read_bytes()
        validate_pilot_source(name, source)
        full_signals = [f"{name}.{signal}" for signal in signals]
        clock = f"{name}.clk"
        cache = FIXTURES / (name + ".json")
        if refresh:
            trace, captured_source = capture(path, clock, full_signals, iverilog_bin)
            if captured_source != source:
                raise TraceError("source changed during trace capture")
            audit_stimulus(name, trace)
            save_trace(cache, trace, source, full_signals)
        else:
            trace = load_trace(cache, source, clock, full_signals)
            audit_stimulus(name, trace)
        actions = evaluate(name, trace)
        output = adapter_output(name, trace, actions)
        replay = None
        if iverilog_bin:
            top, rewritten = replay_source(source.decode(), trace, actions)
            stdout, _ = run_icarus(rewritten, top, iverilog_bin)
            replay = normalized(stdout)
            if output != replay:
                raise TraceError(f"{name}: A/B differ:\n" + "".join(difflib.unified_diff(
                    output.splitlines(True), replay.splitlines(True), fromfile="A", tofile="B")))
        matches = None
        if compare_expected:
            # Independent generation is finished before this read.
            expected = path.with_suffix(".expected").read_text()
            matches = output == expected
            if not matches:
                raise TraceError(f"{name}: expected differs:\n" + "".join(difflib.unified_diff(
                    expected.splitlines(True), output.splitlines(True),
                    fromfile="expected", tofile="adapter")))
        results.append({"test": name, "ticks": len(trace.ticks), "actions": len(actions),
                        "a_b_match": None if replay is None else output == replay,
                        "expected_match": matches})
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog-bin", type=Path, help="13.0 stable; enables option B")
    parser.add_argument("--refresh-traces", action="store_true")
    parser.add_argument("--compare-expected", action="store_true")
    parser.add_argument("--probe-replay-order", action="store_true")
    args = parser.parse_args()
    if args.refresh_traces and not args.iverilog_bin:
        parser.error("--refresh-traces requires --iverilog-bin")
    if args.probe_replay_order and not args.iverilog_bin:
        parser.error("--probe-replay-order requires --iverilog-bin")
    try:
        results = run_pilots(args.iverilog_bin, args.refresh_traces, args.compare_expected)
        if args.probe_replay_order:
            results.append({"replay_order_probe": probe_replay_order(args.iverilog_bin)})
    except (TraceError, ValueError) as exc:
        parser.exit(1, f"{exc}\n")
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()

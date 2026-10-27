"""Export actual Python semantics and check independent RTL with SymbiYosys.

Sequence derivatives become a complete streaming DFA. Finite-word property
and sampled-function results become exhaustive combinational tables. The RTL
specifications in formal_cases do not use those implementations. No suite
source/expected file is read, no assertion is sent to a simulator frontend.
"""

import argparse
from collections import Counter
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import time

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from sva_reference import automata as rx, formal_cases as specs
    from sva_reference import f56_cases as f56
    from sva_reference import f4_common, f41_flat_cases, f4_rewrite_cases
    from sva_reference import f_extra_common, f5_word_cases, f_assign_cases, f36_cases
    from sva_reference import ch16_cases
    from sva_reference import nonvacuity as nonvac
    from sva_reference.engine import Current, Engine
    from sva_reference.parser import Parser, Unsupported, parse_sequence
    from sva_reference.sampled import History
    from sva_reference.values import Bits, evaluate
else:
    from . import automata as rx, formal_cases as specs
    from . import f56_cases as f56
    from . import f4_common, f41_flat_cases, f4_rewrite_cases
    from . import f_extra_common, f5_word_cases, f_assign_cases, f36_cases
    from . import ch16_cases
    from . import nonvacuity as nonvac
    from .engine import Current, Engine
    from .parser import Parser, Unsupported, parse_sequence
    from .sampled import History
    from .values import Bits, evaluate


HERE = Path(__file__).parent
STATUS = {"success": 0, "failure": 1, "vacuous": 2, "holds": 3, "pending": 4, "disabled": 5}
RC = {"PASS": 0, "FAIL": 2, "UNKNOWN": 4, "TIMEOUT": 8, "ERROR": 16}


def sha(data):
    return hashlib.sha256(data).hexdigest()


@dataclass(frozen=True)
class DFA:
    transitions: tuple
    counts: tuple


def dfa(expression, signals, *, max_states=256):
    states = [rx.compile_sequence(parse_sequence(expression))]
    indices = {states[0]: 0}
    transitions = []
    for state in states:
        row = []
        for letter in range(1 << len(signals)):
            values = {name: str((letter >> i) & 1) for i, name in enumerate(signals)}
            following = rx.derivative(state, lambda atom: evaluate(atom, values).assertion())
            if following not in indices:
                if len(states) >= max_states:
                    raise Unsupported("formal DFA exceeded its state limit; no equivalence claim")
                indices[following] = len(states)
                states.append(following)
            row.append(indices[following])
        transitions.append(tuple(row))
    counts = tuple(rx.nullable(state) for state in states)
    if max(counts) >= (1 << 32):
        raise Unsupported("formal match count exceeds its RTL width")
    return DFA(tuple(transitions), counts)


def sequence_model(name, *, mutation=False):
    streaming = name in specs.STREAMS
    expression, names, clause, reference = (specs.STREAMS if streaming else specs.SEQUENCES)[name]
    machine = dfa(expression, names)
    width = max(1, (len(machine.counts) - 1).bit_length())
    history_size = max(reference, default=0) if not streaming else 1
    limit = history_size + 1
    pieces = [f"module check_model(input clk);\n(* anyseq *) reg [{len(names)-1}:0] letter;",
              f"reg [{width-1}:0] state=0; reg [{width-1}:0] following; reg [31:0] actual_count;",
              "always @* begin following=0; case(state)"]
    for index, row in enumerate(machine.transitions):
        pieces.append(f"{width}'d{index}: begin case(letter)")
        pieces.extend(f"{len(names)}'d{letter}: following={width}'d{target};" for letter, target in enumerate(row))
        pieces.append("endcase end")
    pieces.extend(["endcase end", "always @(posedge clk) state<=following;", "always @* begin actual_count=0; case(state)"])
    pieces.extend(f"{width}'d{i}: actual_count=32'd{count};" for i, count in enumerate(machine.counts))
    pieces.extend(["endcase end", f"reg [7:0] age=0; always @(posedge clk) if(age<{limit}) age<=age+1;"])
    if streaming:
        if mutation:
            raise Unsupported("no mutation registered for this stream")
        pieces.append(reference)
    else:
        for i, signal_name in enumerate(names):
            size = max(1, history_size)
            pieces.append(f"reg [{size-1}:0] h_{signal_name}=0; always @(posedge clk) h_{signal_name}<=(h_{signal_name}<<1)|letter[{i}];")
        reference = dict(reference)
        if mutation:
            if name == "first_match_tie":
                reference[3] = "h_a[2] && !h_b[1] && (h_b[0] || h_c[0])"
            elif name == "within_endpoints":
                reference[4] = f"{specs.count('h_a[3] && h_b[0]')} * ({specs.count('h_x[3] && h_x[2]')} + {specs.count('h_x[2] && h_x[1]')})"
            elif name == "empty_left":
                reference = {2: "h_b[0]"}
            else:
                raise Unsupported("no mutation registered for this sequence")
        pieces.append("reg [31:0] reference_count; always @* begin reference_count=0; case(age)")
        pieces.extend(f"{age}: reference_count={value};" for age, value in sorted(reference.items()))
        pieces.append("endcase end")
    reachable = sorted(set(machine.counts))
    covers = [f"cover(actual_count=={value});" for value in
              ([reachable[0], reachable[-1]] if len(reachable) > 1 else reachable)]
    if name in {"first_match_tie", "within_endpoints", "and_endpoint_pairs"}:
        covers = ["cover(reference_count>=2);"]
    if name == "empty_fusion":
        covers = ["cover(age==1 && letter!=0);"]
    pieces.extend(["always @* begin", "assert(actual_count==reference_count);",
                   f"assert(state<{len(machine.counts)});", *covers, "end endmodule\n"])
    return "\n".join(pieces), {"kind": "streaming_sequence", "expression": expression, "signals": names,
        "clause": clause, "states": len(machine.counts), "alphabet_size": 1 << len(names),
        "bmc_depth": 16 if streaming else max(8, history_size + 3)}


def expression(text):
    parser = Parser(text)
    node = parser.boolean()
    parser.finish()
    return node


def attempt_code(spec, samples):
    """Encode one word's top-level directive result for the F.5.3.1 cases.

    The default path is the historical single-attempt Engine.property() call.
    Optional top-level fields add only quantifier/directive context:
    kind (assert/assume/cover), starts=all|any, enable, assume+infeasible and
    current (Observed snapshots needed by disable iff).
    """
    horizon = len(samples)
    kind = spec.get("kind", "assert property")
    if kind == "restrict property":
        # F.3.4.1: in the formal semantics restrict property is assume property.
        kind = "assume property"
    current = ([Current(tick, samples[tick], "observed") for tick in range(horizon)]
               if spec.get("current") else None)
    engine = Engine(samples, current=current)

    def tick_key(attempt):
        return 99 if attempt.tick is None else attempt.tick

    if spec.get("assume") is not None:
        feasible = all(engine.property(condition).status in {"success", "vacuous"}
                       for condition in spec["assume"])
        if not feasible:
            status = "success" if spec.get("infeasible") == "pass" else "failure"
            return (STATUS[status] << 4) | 15
        return encode(engine.property(spec["expression"], kind=kind))
    if spec.get("starts") == "all":
        starts = [tick for tick in range(horizon)
                  if spec.get("enable") is None or samples[tick][spec["enable"]] == "1"]
        if not starts:
            return (STATUS["success"] << 4) | 15
        attempts = [engine.property(spec["expression"], start=tick, kind=kind) for tick in starts]
        failed = [attempt for attempt in attempts if attempt.status == "failure"]
        if failed:
            return encode(min(failed, key=tick_key))
        passed = [attempt for attempt in attempts if attempt.status in {"success", "vacuous"}]
        disabled = [attempt for attempt in attempts if attempt.status == "disabled"]
        if passed and len(passed) + len(disabled) == len(attempts):
            return encode(max(passed, key=tick_key))
        if len(disabled) == len(attempts):
            return encode(max(disabled, key=tick_key))
        status = "holds" if any(attempt.status == "holds" for attempt in attempts) else "pending"
        return (STATUS[status] << 4) | 15
    if spec.get("starts") == "any":
        attempts = [engine.property(spec["expression"], start=tick, kind=kind)
                    for tick in range(horizon)]
        passed = [attempt for attempt in attempts if attempt.status in {"success", "vacuous"}]
        if passed:
            return encode(min(passed, key=tick_key))
        # cover needs a pass witness; disabled/holds/pending alone is not enough.
        return (STATUS["failure"] << 4) | (horizon - 1)
    return encode(engine.property(spec["expression"], kind=kind))


def encode(attempt):
    return (STATUS[attempt.status] << 4) | (15 if attempt.tick is None else attempt.tick)


def property_model(name, *, mutation=False):
    spec = specs.PROPERTIES[name]
    names, horizon = spec["signals"], spec["horizon"]
    size = len(names) * horizon
    pieces = [f"module check_model; (* anyconst *) reg [{size-1}:0] word;",
              "reg [7:0] actual_result, reference_result;", "always @* begin actual_result=0; case(word)"]
    codes = set()
    for word in range(1 << size):
        samples = [{name: str((word >> (tick * len(names) + i)) & 1) for i, name in enumerate(names)} for tick in range(horizon)]
        code = attempt_code(spec, samples)
        codes.add(code)
        pieces.append(f"{size}'d{word}: actual_result=8'd{code};")
    pieces.append("endcase end")
    pieces.extend(f"wire [{horizon-1}:0] {signal_name}={{{','.join(f'word[{tick*len(names)+i}]' for tick in reversed(range(horizon)))}}};"
                  for i, signal_name in enumerate(names))
    reference = spec["reference"]
    if mutation:
        if name != "followed_overlap":
            raise Unsupported("no mutation registered for this property")
        reference = reference.replace("!a[0]) reference_result=8'd16", "!a[0]) reference_result=8'd32")
    ordered = sorted(codes)
    chosen = ordered if len(ordered) <= 2 else [ordered[0], ordered[-1]]
    pieces.extend([reference, "always @* begin assert(actual_result==reference_result);",
                   *[f"cover(actual_result==8'd{value});" for value in chosen],
                   "end endmodule\n"])
    return "\n".join(pieces), {"kind": "finite_word_property", "expression": spec["expression"],
        "clause": spec["clause"], "signals": names, "semantic_ticks": horizon,
        "symbolic_bits": size, "input_words": 1 << size, "bmc_depth": 2}


LOCAL_TABLES = {**f56.TABLES, **f4_common.TABLES, **f_extra_common.TABLES}


def table_model(name):
    """Exhaustive combinational model for the F.4/F.5.4-F.7 finite tables."""
    spec = LOCAL_TABLES[name]
    signals, horizon = spec["signals"], spec["horizon"]
    context, inputs = spec["context"], spec["inputs"]
    selectors = spec["selectors"]
    signal_stride = sum(width for _, width in signals)
    context_width = sum(width + 1 for _, width in context)
    input_width = sum(width for _, width in inputs)
    size = max(1, signal_stride * horizon + context_width + input_width + selectors)
    if size > 17:
        raise Unsupported(f"{name} enumerates too many input words ({1 << size})")
    pieces = [f"module check_model; (* anyconst *) reg [{size - 1}:0] word;",
              "reg [31:0] actual_result, reference_result;",
              "always @* begin actual_result=0; case(word)"]
    codes = set()
    for word in range(1 << size):
        samples = []
        for tick in range(horizon):
            row = {}
            offset = tick * signal_stride
            for signal, width in signals:
                raw = (word >> offset) & ((1 << width) - 1)
                row[signal] = Bits(format(raw, f"0{width}b"))
                offset += width
            samples.append(row)
        offset = signal_stride * horizon
        local = {}
        for local_name, width in context:
            present = (word >> offset) & 1
            raw = (word >> (offset + 1)) & ((1 << width) - 1)
            if present:
                local[local_name] = Bits(format(raw, f"0{width}b"))
            offset += width + 1
        values = {}
        for input_name, width in inputs:
            raw = (word >> offset) & ((1 << width) - 1)
            values[input_name] = raw
            offset += width
        selector = (word >> offset) & ((1 << selectors) - 1) if selectors else 0
        code = spec["actual"](samples, local, selector, values) if inputs else \
            spec["actual"](samples, local, selector)
        codes.add(code)
        pieces.append(f"{size}'d{word}: actual_result=32'd{code};")
    pieces.append("endcase end")
    offset = 0
    for signal, width in signals:
        for tick in range(horizon):
            base = tick * signal_stride + offset
            pieces.append(f"wire [{width - 1}:0] s_{signal}_{tick}=word[{base} +: {width}];")
        offset += width
    offset = signal_stride * horizon
    # emit the context and non-temporal inputs in the same order the table
    # consumed them
    for local_name, width in context:
        pieces.append(f"wire p_{local_name}=word[{offset}];")
        pieces.append(f"wire [{width - 1}:0] c_{local_name}=word[{offset + 1} +: {width}];")
        offset += width + 1
    for input_name, width in inputs:
        pieces.append(f"wire [{width - 1}:0] i_{input_name}=word[{offset} +: {width}];")
        offset += width
    if selectors:
        pieces.append(f"wire [{selectors - 1}:0] sel=word[{offset} +: {selectors}];")
    else:
        pieces.append("wire [0:0] sel=0;")
    if spec.get("cover", "1") != "1":
        covers = [f"cover({spec['cover']});"]
    else:
        ordered = sorted(codes)
        chosen = ordered if len(ordered) <= 2 else [ordered[0], ordered[-1]]
        covers = [f"cover(actual_result==32'd{value});" for value in chosen]
    pieces.extend([spec["reference"], "always @* begin",
                   "assert(actual_result==reference_result);",
                   *covers, "end endmodule\n"])
    return "\n".join(pieces), {
        "kind": "finite_local_table", "expression": spec["expression"],
        "clause": spec["clause"], "signals": [name for name, _ in signals],
        "semantic_ticks": horizon, "symbolic_bits": size,
        "input_words": 1 << size, "bmc_depth": 2,
        "requirement": spec.get("requirement", ""),
    }


def nonvacuity_model(name):
    spec = specs.NONVACUITY[name]
    names, horizon = spec["signals"], spec["horizon"]
    size = len(names) * horizon
    pieces = [f"module check_model; (* anyconst *) reg [{size-1}:0] word;",
              "reg actual_result, reference_result;",
              "always @* begin actual_result=0; case(word)"]
    codes = set()
    for word in range(1 << size):
        samples = [{name: str((word >> (tick * len(names) + i)) & 1)
                    for i, name in enumerate(names)} for tick in range(horizon)]
        evaluate = (nonvac.nonvacuous_satisfaction if spec.get("mode") == "satisfaction"
                    else nonvac.nonvacuous)
        value = int(evaluate(spec['expression'], samples))
        codes.add(value)
        pieces.append(f"{size}'d{word}: actual_result=1'b{value};")
    pieces.append("endcase end")
    pieces.extend(f"wire [{horizon-1}:0] {name}={{{','.join(f'word[{tick*len(names)+i}]' for tick in reversed(range(horizon)))}}};"
                  for i, name in enumerate(names))
    pieces.extend([spec["reference"], "always @* begin assert(actual_result==reference_result);",
                   *[f"cover(actual_result==1'b{value});" for value in sorted(codes)],
                   "end endmodule\n"])
    return "\n".join(pieces), {"kind": "finite_word_nonvacuity",
        "expression": spec["expression"], "clause": spec["clause"],
        "requirement": spec.get("requirement"), "signals": names,
        "semantic_ticks": horizon, "symbolic_bits": size,
        "input_words": 1 << size, "bmc_depth": 2}


def clocking_table_model(name):
    """Export a finite-word table from a clocking/grammar clause spec.

    ``spec["actual"]`` is a Python semantic function; the RTL in
    ``spec["reference"]`` is written independently from the clause and never
    calls the parser, derivative engine or evaluator.
    """
    spec = specs.TABLES[name]
    dims, horizon = spec["dims"], spec["horizon"]
    width = spec["width"]
    size = sum(bits for _, bits in dims) * horizon
    pieces = [f"module check_model; (* anyconst *) reg [{size-1}:0] word;",
              f"reg [{width-1}:0] actual_result, reference_result;",
              "always @* begin actual_result=0; case(word)"]
    codes = set()
    for word in range(1 << size):
        value = int(spec["actual"](word))
        codes.add(value)
        pieces.append(f"{size}'d{word}: actual_result={width}'d{value};")
    pieces.append("endcase end")
    stride = sum(bits for _, bits in dims)
    base = 0
    for signal, bits in dims:
        slices = [f"word[{base + tick * stride} +: {bits}]"
                  for tick in reversed(range(horizon))]
        pieces.append(f"wire [{bits * horizon - 1}:0] {signal}={{{','.join(slices)}}};")
        base += bits
    ordered = sorted(codes)
    chosen = ordered if len(ordered) <= 2 else [ordered[0], ordered[-1]]
    pieces.extend([spec["reference"],
                   "always @* begin assert(actual_result==reference_result);",
                   *[f"cover(actual_result=={width}'d{value});" for value in chosen],
                   "end endmodule\n"])
    return "\n".join(pieces), {"kind": "finite_word_clocking",
        "clause": spec["clause"], "signals": [signal for signal, _ in dims],
        "semantic_ticks": horizon, "symbolic_bits": size,
        "input_words": 1 << size, "bmc_depth": 2,
        "requirement": spec.get("requirement")}


def decode_four(value):
    return Bits("".join("01xz"[(value >> bit) & 3] for bit in [2, 0]))


def four_state_model():
    calls = [expression(f"${name}(v)") for name in ["sampled", "past", "rose", "fell", "stable", "changed"]]
    pieces = ["module check_model; (* anyconst *) reg [7:0] word; reg [11:0] actual_result;",
              "always @* begin actual_result=0; case(word)"]
    for word in range(256):
        history = History([{"v": decode_four(word >> 4)}, {"v": decode_four(word & 15)}])
        values = [history.evaluate(call, 1) for call in calls]
        # Store the actual return encodings, not just the input word.
        code = 0
        offset = 0
        for value in values:
            encoded = sum("01xz".index(char) << (2 * i) for i, char in enumerate(reversed(value.bits))) if value.width == 2 else int(value.bits)
            code |= encoded << offset
            offset += 4 if value.width == 2 else 1
        pieces.append(f"8'd{word}: actual_result=12'd{code};")
    pieces.extend(["endcase end", "wire [3:0] previous=word[7:4], current_value=word[3:0];",
        "wire rose=(current_value[1:0]==1 && previous[1:0]!=1);",
        "wire fell=(current_value[1:0]==0 && previous[1:0]!=0);",
        "wire same=(current_value==previous);",
        "wire [11:0] reference_result={!same,same,fell,rose,previous,current_value};",
        "always @* begin assert(actual_result==reference_result);",
        "cover(previous[1:0]==2 && current_value[1:0]==1 && rose); end endmodule\n"])
    return "\n".join(pieces), {"kind": "four_state_sampled", "clause": "16.9.3/F.3.4.4", "symbolic_bits": 8,
                               "input_words": 256, "semantic_ticks": 2, "bmc_depth": 2}


def gated_past_model(*, mutation=False):
    calls = [expression(text) for text in ["$past(v)", "$past(v,2)", "$past(v,1,g)", "$past(v,2,g)"]]
    pieces = ["module check_model; (* anyconst *) reg [11:0] word; reg [31:0] actual_result, reference_result;",
              "always @* begin actual_result=0; case(word)"]
    for word in range(4096):
        samples = [{"v": Bits(format((word >> (3 * i)) & 3, "02b")), "g": str((word >> (3 * i + 2)) & 1)} for i in range(4)]
        history = History(samples, defaults={"v": Bits("01"), "g": "0"})
        code = sum(history.evaluate(call, tick).integer() << (tick * 8 + j * 2) for tick in range(4) for j, call in enumerate(calls))
        pieces.append(f"12'd{word}: actual_result=32'd{code};")
    update = "if (word[3*i+2]) begin gp2=gp1; gp1=word[3*i +:2]; end"
    emit = "reference_result[8*i +:8]={gp2,gp1,p2,p1};"
    pieces.extend(["endcase end", "reg [1:0] p1,p2,gp1,gp2; integer i;", "always @* begin",
        "p1=1; p2=1; gp1=1; gp2=1; reference_result=0;",
        "for (i=0;i<4;i=i+1) begin", update if mutation else emit,
        emit if mutation else update, "p2=p1; p1=word[3*i +:2]; end end",
        "always @* begin assert(actual_result==reference_result);",
        "cover(word[2] && !word[5] && word[8] && word[11]); end endmodule\n"])
    return "\n".join(pieces), {"kind": "gated_past", "clause": "16.5.1/16.9.3", "symbolic_bits": 12,
        "input_words": 4096, "semantic_ticks": 4, "bmc_depth": 2}


def export(name, *, mutation=False):
    if name in LOCAL_TABLES:
        if mutation:
            raise Unsupported("no mutation registered for this F.5.4-F.7 case")
        return table_model(name)
    if name in specs.TABLES:
        if mutation:
            raise Unsupported("no mutation registered for this clocking table")
        return clocking_table_model(name)
    if name in specs.SEQUENCES or name in specs.STREAMS:
        return sequence_model(name, mutation=mutation)
    if name in specs.PROPERTIES:
        return property_model(name, mutation=mutation)
    if name in specs.NONVACUITY and not mutation:
        return nonvacuity_model(name)
    if name == "four_state_sampled" and not mutation:
        return four_state_model()
    if name == "gated_past":
        return gated_past_model(mutation=mutation)
    raise Unsupported("unknown formal case")


def catalogue():
    return [*LOCAL_TABLES, *specs.TABLES, *specs.SEQUENCES, *specs.STREAMS,
            *specs.PROPERTIES, *specs.NONVACUITY, "four_state_sampled", "gated_past"]


def sby_text(mode, depth, timeout):
    engine = "abc pdr" if mode == "prove" else "smtbmc yices"
    return f"""[options]
mode {mode}
depth {depth}
timeout {timeout}

[engines]
{engine}

[script]
read_verilog -formal -sv model.sv
prep -top check_model

[files]
model.sv
"""


def run_job(folder, model, *, mode, depth, expected, binary, env, timeout):
    folder.mkdir()
    (folder / "model.sv").write_text(model)
    config = sby_text(mode, depth, timeout)
    (folder / "case.sby").write_text(config)
    start = time.monotonic()
    status, rc = "ERROR", None
    with (folder / "stdout.log").open("w") as stream:
        process = subprocess.Popen([str(binary), "case.sby"], cwd=folder, env=env,
                                   stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            rc = process.wait(timeout=timeout + 5)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()
            status = "TIMEOUT"
    status_path = folder / "case/status"
    if status != "TIMEOUT" and status_path.exists():
        status = status_path.read_text().strip().split()[0]
    if status not in RC or (status != "TIMEOUT" and rc != RC.get(status)):
        status = "ERROR"
    traces = sorted((folder / "case").rglob("*.vcd")) if (folder / "case").exists() else []
    witnessed = bool(traces) if mode == "cover" or expected == "FAIL" else True
    return {"mode": mode, "depth": depth, "status": status, "expected": expected,
            "ok": status == expected and witnessed, "rc": rc,
            "elapsed_seconds": round(time.monotonic() - start, 3),
            "model_sha256": sha(model.encode()), "sby_sha256": sha(config.encode()),
            "traces": [path.relative_to(folder).as_posix() for path in traces]}


def source_hashes():
    return {path.name: sha(path.read_bytes()) for path in sorted(HERE.glob("*.py"))}


def task_plan(name, prove=True):
    tasks = [("bmc", False)]
    if prove and name in {*specs.SEQUENCES, *specs.STREAMS}:
        tasks.append(("prove", False))
    # Every case must witness a non-vacuous state, not only the four cases
    # that historically carried a hand-written cover condition.
    tasks.append(("cover", False))
    if name in {"first_match_tie", "within_endpoints", "empty_left", "followed_overlap", "gated_past"}:
        tasks.append(("bmc", True))
    return tasks


def job_name(name, mode, mutation):
    return name + ("_mutant" if mutation else "") + "_" + mode


def validate_report(report):
    """Check provenance/completeness; this does not rerun a solver."""
    if report.get("schema") != 1 or report.get("source_hashes") != source_hashes():
        raise ValueError("stale formal report: evaluator/exporter/specification sources changed")
    names = report.get("selected", [])
    if not names or len(set(names)) != len(names) or set(names) - set(catalogue()):
        raise ValueError("formal report has an invalid or empty case selection")
    expected = {job_name(name, mode, mutation): "FAIL" if mutation else "PASS"
                for name in names for mode, mutation in task_plan(name, report.get("prove", False))}
    jobs = report.get("jobs", [])
    if {job["case"] for job in jobs} != set(expected) or len(jobs) != len(expected):
        raise ValueError("formal report omitted, duplicated or added tasks")
    for job in jobs:
        status = expected[job["case"]]
        if not job.get("ok") or job["status"] != status or job["expected"] != status or job["rc"] != RC[status]:
            raise ValueError("formal report contains an unsuccessful task")
        if job["mode"] != job["case"].rsplit("_", 1)[1] or job["mutation"] != ("_mutant_" in job["case"]):
            raise ValueError("formal report has inconsistent task modes")
        if (status == "FAIL" or job["mode"] == "cover") and not job.get("traces"):
            raise ValueError("formal report lacks a counterexample or reachability witness")
    if report.get("counts") != dict(Counter(job["status"] for job in jobs)) or not report.get("ok") or report.get("source_changed"):
        raise ValueError("formal report has inconsistent totals or changed sources")
    return True


def run(folder, binary, *, selected=None, timeout=30, prove=True):
    folder, binary = Path(folder), Path(binary).resolve()
    names = catalogue() if selected is None else list(selected)
    if not names or len(set(names)) != len(names) or set(names) - set(catalogue()):
        raise ValueError("select at least one unique known formal case")
    sources_before = source_hashes()
    if folder.exists() and any(folder.iterdir()):
        raise ValueError("output directory must be new or empty; existing runs are never overwritten")
    folder.mkdir(parents=True, exist_ok=True)
    # Keep the bundled toolchain out of the user's and simulator runner's PATH.
    env = {"PATH": str(binary.parent) + os.pathsep + os.defpath,
           "HOME": os.environ.get("HOME", "/tmp"), "LANG": "C", "LC_ALL": "C"}
    versions = {}
    for name, flag in [("sby", "--version"), ("yosys", "--version"), ("yices-smt2", "--version"), ("yosys-abc", "-h")]:
        proc = subprocess.run([str(binary.parent / name), flag], env=env, capture_output=True, text=True, timeout=10)
        version = ((proc.stdout + proc.stderr).strip().splitlines() or ["unknown"])[0]
        # Keep tool build identities without host-specific compiler paths.
        versions[name] = version.split(", Release,")[0] + ")" if ", Release," in version else version
    jobs = []
    for name in names:
        model, meta = export(name)
        for mode, mutation in task_plan(name, prove):
            depth, expected = meta["bmc_depth"], "FAIL" if mutation else "PASS"
            case = job_name(name, mode, mutation)
            source = export(name, mutation=True)[0] if mutation else model
            result = run_job(folder / case, source, mode=mode, depth=depth,
                             expected=expected, binary=binary, env=env, timeout=timeout)
            jobs.append({"case": case, "mutation": mutation, **meta, **result})
            print(f"{case}: {result['status']} (expected {expected})", flush=True)
    changed = sources_before != source_hashes()
    report = {"schema": 1, "tool_versions": versions,
              "generated_at": datetime.now(timezone.utc).isoformat(),
              "selected": names, "prove": prove, "source_changed": changed,
              "scope": "symbolic semantic-model equivalence; does not verify a SystemVerilog simulator or suite execution coverage",
              "source_hashes": sources_before,
              "counts": dict(Counter(job["status"] for job in jobs)),
              "ok": not changed and all(job["ok"] for job in jobs), "jobs": jobs}
    (folder / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    destinations = parser.add_mutually_exclusive_group(required=True)
    destinations.add_argument("--output-dir", type=Path)
    destinations.add_argument("--check-results", type=Path, help="check saved provenance/completeness without running tools")
    parser.add_argument("--sby", type=Path, help="sby executable; sibling bundled tools are used only in subprocesses")
    parser.add_argument("--case", action="append", choices=catalogue())
    parser.add_argument("--emit-only", action="store_true", help="export all model sources without invoking tools")
    parser.add_argument("--no-prove", action="store_true", help="omit unbounded streaming equivalence jobs")
    parser.add_argument("--timeout", type=int, default=30)
    args = parser.parse_args()
    if not 1 <= args.timeout <= 300:
        parser.error("timeout must be between 1 and 300 seconds")
    try:
        if args.check_results:
            validate_report(json.loads(args.check_results.read_text()))
            print("formal report is complete and bound to current sources; solver not rerun")
            return 0
        if args.emit_only:
            if args.output_dir.exists() and any(args.output_dir.iterdir()):
                raise ValueError("export directory must be new or empty")
            args.output_dir.mkdir(parents=True, exist_ok=True)
            for name in args.case or catalogue():
                source, _ = export(name)
                (args.output_dir / (name + ".sv")).write_text(source)
            return 0
        binary = args.sby or shutil.which("sby")
        if not binary:
            parser.error("sby is not installed on PATH; pass --sby explicitly")
        report = run(args.output_dir, binary, selected=args.case, timeout=args.timeout, prove=not args.no_prove)
    except (ValueError, OSError, subprocess.SubprocessError) as exc:
        parser.exit(2, f"formal run failed: {exc}\n")
    print(json.dumps({"ok": report["ok"], "counts": report["counts"]}))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())

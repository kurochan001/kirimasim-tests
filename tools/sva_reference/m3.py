"""M3 source-audited adapters. All assertion evaluation uses the general engine.

Source preparation removes reporting state and translates finite literal input
tables/membership helpers for Icarus. It never executes assertion actions in
a simulator and never opens expected output. Scope/reporting lives in survey.py.
"""

from dataclasses import asdict, dataclass, replace
import hashlib
import json
from pathlib import Path
import re
import tempfile

from . import bridge
from .engine import Current
from .module import parse_module
from .parser import Node, Parser, Spec, Unsupported, expand
from .pilots import Display, Generated, ROOT, _arguments, _printf, displays, initial_calls
from .source import _balanced, _statement, tokens
from .trace import TraceError, load_trace, read_vcd, run_icarus, save_trace
from .values import Bits, evaluate


HERE = Path(__file__).parent
MANIFEST = HERE / "fixtures/m3_cases.json"
FIXTURES = HERE / "fixtures/m3"
PROTOCOL = "m3-source-projection-v1"


def expression(text):
    parser = Parser(text)
    result = parser.boolean()
    parser.finish()
    return result


def source_view(source, prepare=None):
    """Two fixed lexical-scope preparations, guarded by whole-source audits."""
    if prepare == "clocking_let":
        block = re.search(r"clocking cb @\(posedge clk\);(.*?)endclocking", source, re.S)
        if block is None or re.search(r"\binput\b|\boutput\b|#", block[1]):
            raise Unsupported("clocking-let scope preparation no longer applies")
        source = source[:block.start()] + block[1].replace("property cp;", "property cp; @(posedge clk)") + source[block.end():]
        return source.replace("cb.cp", "cp")
    if prepare == "nested_disable":
        for name, label, counter, reset in [("nested_m", "a_nested", "nested_f", "rst"),
                                             ("nested_own_m", "a_nested_own", "nested_own_f", "r_nm")]:
            block = re.search(r"\bmodule\s+" + name + r";(.*?)endmodule", source, re.S)
            if block is None or "a |=> b" not in block[1]:
                raise Unsupported("nested-module preparation no longer applies")
            replacement = f"int {counter}=0;\n{label}: assert property (@(posedge clk) disable iff ({reset}) a |=> b) else {counter}++;"
            source = source[:block.start()] + replacement + source[block.end():]
            source = re.sub(r"\b" + name + r"\s+\w+\s*\(\s*\)\s*;", "", source)
        return source
    if prepare is not None:
        raise Unsupported("unknown M3 source preparation")
    return source


def order_values(source):
    match = re.search(r"\bstring\s+order\s*\[\s*\]\s*=\s*'\{(.*?)\};", source, re.S)
    return tuple(json.loads(token.text) for token in tokens(match[1]) if token.text.startswith('"')) if match else ()


def project(module, case):
    source = module.stimulus
    # Translation of the reviewed pure at(n, '{literal,...}) input helper.
    if case.get("at"):
        pattern = r"\bat\(\s*(\w+)\s*,\s*'\{([^{}]*)\}\s*\)"
        def membership(match):
            values = match[2].split(",")
            if not all(re.fullmatch(r"\s*\d+\s*", value) for value in values):
                raise Unsupported("at() stimulus requires literal integer members")
            return "(" + " || ".join(f"({match[1]} == {value.strip()})" for value in values) + ")"
        source = re.sub(pattern, membership, source)
    # Read-only finite literal tables; replace both indexed reads and foreach.
    array = re.compile(r"\b(?:bit|logic)\s+(?:(\[[^]]+\])\s+)?(\w+)\s*\[([^]]+)\]\s*=\s*'\{(.*?)\};", re.S)
    for match in list(array.finditer(source))[::-1]:
        name = match[2]
        dimensions = match[3].split(":")
        lo, hi = (0, int(dimensions[0]) - 1) if len(dimensions) == 1 else map(int, dimensions)
        values = [item.strip() for item in match[4].split(",")]
        step = 1 if lo <= hi else -1
        indices = list(range(lo, hi + step, step))
        if len(indices) != len(values):
            raise Unsupported("literal stimulus array size mismatch")
        source = bridge._blank(source, match.start(), match.end())
        loop = re.compile(r"foreach\s*\(\s*" + name + r"\s*\[\s*(\w+)\s*\]\s*\)")
        source = loop.sub(lambda m: f"for (int {m[1]}={lo}; {m[1]} {'<=' if step == 1 else '>='} {hi}; {m[1]} {'++' if step == 1 else '--'})", source)
        reference = re.compile(r"\b" + name + r"\s*\[\s*(\w+)\s*\]")
        source = reference.sub(lambda m: "(" + " : ".join(f"({m[1]} == {index}) ? {value}" for index, value in zip(indices, values)) + " : 'x)", source)
    # The one reviewed integral inside expression in stimulus has a plain
    # loop-index operand and a finite list of known integer members.
    source = re.sub(r"\b(\w+)\s+inside\s*\{([\d,\s]+)\}",
                    lambda m: "(" + " || ".join(f"({m[1]} == {item.strip()})" for item in m[2].split(",")) + ")", source)
    ts = tokens(source)
    words = [token.text for token in ts]
    spans, stores, i = [], set(), 0
    while i < len(ts):
        if words[i] in {"task", "function"}:
            i = words.index("end" + words[i], i + 1) + 1
            continue
        if words[i] in {"initial", "always", "always_ff", "always_comb", "final"}:
            i = _statement(ts, i + 1)
            continue
        if words[i] in {"string", "int"} and i + 2 < len(ts) and words[i + 2] == "[" and (
            words[i] == "string" or words[i + 3] == "string"
        ):
            end = words.index(";", i + 1)
            stores.add(words[i + 1])
            spans.append((ts[i].start, ts[end].end))
            i = end + 1
        else:
            i += 1
    for begin, end in sorted(spans, reverse=True):
        source = bridge._blank(source, begin, end)
    ts = tokens(source)
    words = [token.text for token in ts]
    spans, i = [], 0
    while i < len(ts):
        if words[i] == "foreach" and words[i + 2] == "order":
            end = _statement(ts, i)
            spans.append((ts[i].start, ts[end - 1].end))
            i = end
        elif words[i] in stores and words[i + 1:i + 5] == [".", "delete", "(", ")"]:
            end = _statement(ts, i)
            spans.append((ts[i].start, ts[end - 1].end))
            i = end
        else:
            i += 1
    for begin, end in sorted(spans, reverse=True):
        source = bridge._blank(source, begin, end, ";")
    functions = list(case.get("functions", {})) + (["at"] if case.get("at") else [])
    # Function n() shares its identifier with stimulus loop variables in some
    # tests; rename only its declaration/call sites before M2's strict guard.
    if "n" in functions:
        source = re.sub(r"\bn(?=\s*\()", "m3_report_count", source)
        functions[functions.index("n")] = "m3_report_count"
    return bridge.project_stimulus(replace(module, stimulus=source), remove_functions=functions)


def names_in(node):
    result = {node.value} if node.op == "name" else set()
    for arg in node.args:
        result.update(names_in(arg))
    return result


def signals_for(module):
    result = set()
    for directive in module.directives:
        result.update(names_in(directive.spec.body))
        if directive.spec.disable:
            result.update(names_in(directive.spec.disable))
    return tuple(sorted(result))


def load_input(path, source, projected, module, signals, case, refresh, binary):
    provenance = bridge.context(source, projected, module, signals)
    provenance.update({"m3_protocol": PROTOCOL, "current_mode": "audited_settled_equals_observed" if case.get("current") else None})
    key = bridge.cache_input(source, provenance)
    if refresh:
        _, vcd = run_icarus(projected, module.top, binary)
        if vcd is None:
            raise TraceError("M3 stimulus did not produce VCD")
        updates = []
        with tempfile.TemporaryDirectory(prefix="sva-m3-") as directory:
            p = Path(directory) / "trace.vcd"
            p.write_text(vcd)
            trace = read_vcd(p, provenance["clock"], provenance["signals"], provenance["edge"],
                             current_callback=lambda time, values: updates.append({"time": time, "values": values}))
        path.parent.mkdir(parents=True, exist_ok=True)
        save_trace(path, trace, key, provenance["signals"])
        data = json.loads(path.read_text())
        data.update({"projection": provenance, "current": updates if case.get("current") else []})
        path.write_text(json.dumps(data, indent=2) + "\n")
    else:
        data = json.loads(path.read_text())
        if data.get("projection") != provenance:
            raise TraceError("stale M3 source, projection, type metadata or current-value audit")
        trace = load_trace(path, key, provenance["clock"], provenance["signals"], provenance["edge"])
    declarations = bridge.signal_types(module)
    current = None
    if case.get("current"):
        current = [Current(row["time"], {full[len(module.top) + 1:]: declarations[full[len(module.top) + 1:]].decode(value)
                                         for full, value in row["values"].items()}) for row in data["current"]]
        if not current:
            raise TraceError("missing audited current-value events")
    return trace, bridge.engine_from_trace(module, trace, current=current)


@dataclass(frozen=True)
class Event:
    label: str
    start: int
    end: int
    time: int
    branch: str
    body: str


def events_for(module, engine, trace):
    events, summaries = [], {}
    for directive in module.directives:
        item = directive.source
        if item.kind == "cover sequence":
            matches = engine.sequence_coverage(directive.spec)
            summaries[item.label] = {"attempted": len(trace.ticks), "matches": len(matches)}
            for match in matches:
                if match.end < match.start:
                    raise Unsupported("empty top-level cover sequence action boundary")
                if item.passed != ";":
                    events.append(Event(item.label, match.start, match.end, trace.ticks[match.end].time, "pass", item.passed))
        else:
            attempts = engine.attempts(directive.spec, kind=item.kind)
            from collections import Counter
            summaries[item.label] = dict(Counter(attempt.status for attempt in attempts))
            for attempt in attempts:
                branch = "pass" if attempt.status in {"success", "vacuous"} else "fail" if attempt.status == "failure" and item.kind != "cover property" else None
                body = item.passed if branch == "pass" else item.failed
                if branch and body != ";":
                    events.append(Event(item.label, attempt.start, attempt.tick, attempt.time, branch, body))
    return tuple(sorted(events, key=lambda e: (e.time, e.label, e.start))), summaries


def evaluate_report(text, state, local, module, time):
    text = "".join(token.text for token in tokens(text))
    if text in local:
        return local[text]
    if text == "$time":
        return time
    if text == "order[i]":
        return local["order[i]"]
    if text.startswith('"'):
        return json.loads(text)
    if text == "failed()":
        return "".join(" " + label for target, label in [("f_top", "top"), ("nested_f", "nested"), ("nested_own_f", "nested_own")]
                       if state.get(target, 0))
    call = re.fullmatch(r"(times|ends|n)\((.*)\)", text)
    if call:
        arg = evaluate_report(call[2], state, local, module, time)
        value = state.get(arg, [] if call[1] != "n" else 0) if isinstance(arg, str) else arg
        return int(value) if call[1] == "n" else "".join(f" {v}" for v in value) if isinstance(value, list) else value
    indexed = re.fullmatch(r"(\w+)\.exists\(order\[i\]\)\?\1\[order\[i\]\]:(0|\"\")", text)
    if indexed:
        return state.get(local["order[i]"], 0 if indexed[2] == "0" else [])
    if text in state:
        return state[text]
    node = expression(text)
    spec = expand(Spec(Node("bool", (node,))), module.definitions)
    return evaluate(spec.body.args[0], {**module.parameters, **state, **{key: value for key, value in local.items() if isinstance(value, (Bits, int))}})


def initial_state(source):
    state = {}
    for match in re.finditer(r"\bint\s+([^;]+);", source):
        if "(" in match[1]:
            continue
        for part in match[1].split(","):
            queue = re.fullmatch(r"\s*(\w+)\s*\[.*", part)
            if queue:
                state[queue[1]] = []
                continue
            item = re.fullmatch(r"\s*(\w+)\s*(?:=\s*(-?\d+))?\s*", part)
            if item:
                state[item[1]] = int(item[2] or 0)
    return state


def apply_action(event, state, local, module, case):
    body = event.body.strip()
    if body.startswith("begin"):
        body = body[5:]
        body = re.sub(r"end\s*$", "", body).strip()
    for statement in [part.strip() for part in body.split(";") if part.strip()]:
        increment = re.fullmatch(r"(\w+)\+\+", statement)
        if increment:
            state[increment[1]] = state.get(increment[1], 0) + 1
            continue
        push = re.fullmatch(r"(\w+)\.push_back\(\s*\$time\s*\)", statement)
        if push:
            state.setdefault(push[1], []).append(event.time)
            continue
        assignment = re.fullmatch(r"(\w+)\s*=\s*(.*)", statement)
        if assignment:
            state[assignment[1]] = evaluate_report(assignment[2], state, local, module, event.time)
            continue
        call = re.fullmatch(r"(\w+)\((.*)\)", statement)
        if call and call[1] in case.get("functions", {}):
            kind = case["functions"][call[1]]
            ts = tokens("(" + call[2] + ")")
            arguments, _ = _arguments("(" + call[2] + ")", ts, 0)
            arguments = [json.loads(argument) for argument in arguments]
            key = arguments[0]
            if kind == "increment":
                state[key] = state.get(key, 0) + 1
            elif kind == "push_time":
                state.setdefault(key, []).append(event.time)
            elif kind == "append":
                state[key] = state.get(key, "") + arguments[1]
            else:
                raise Unsupported("report-only function cannot be used as an assertion action")
            continue
        if statement.startswith("$display"):
            local.setdefault("__action_lines", []).extend(format_displays(displays(statement + ";"), state, local, module, event.time))
            continue
        raise Unsupported("unhandled M3 action: " + statement)


def format_displays(items, state, local, module, time):
    result = []
    for display in items:
        args = [evaluate_report(arg, state, local, module, time) for arg in display.arguments]
        args = ["".join(f" {value}" for value in arg) if isinstance(arg, list) else arg for arg in args]
        # All audited %0t displays use an integral unit equal to precision.
        result.append(_printf(display.format.replace("%0t", "%0d"), args))
    return result


def render(source, module, trace, events, case):
    # Action displays are in the original source, so get the report list from
    # the declaration/directive-free stimulus instead.
    reports = displays(module.stimulus)
    plans = []
    if case.get("period"):
        for index, args in enumerate(initial_calls(module.stimulus, case.get("task", "phase"))):
            local = {}
            for formal, arg in zip(case["formals"], args):
                local[formal] = json.loads(arg) if arg.startswith('"') else evaluate(expression(arg), {})
            plans.append(((index + 1) * case["period"] - case.get("report_early", 0), index * case["period"], local))
    else:
        plans.append((trace.end_time, 0, {}))
    lines = []
    order = order_values(source)
    for time, since, local in plans:
        state = initial_state(source)
        for event in events:
            if since <= event.time < time:
                apply_action(event, state, local, module, case)
            elif event.time == time:
                raise Unsupported("M3 action/report collision requires a scheduling review")
        lines.extend(local.get("__action_lines", []))
        if order:
            for key in order:
                lines.extend(format_displays(reports, state, {**local, "order[i]": key}, module, time))
        else:
            lines.extend(format_displays(reports, state, local, module, time))
    return "\n".join(lines) + ("\n" if lines else "")


def generate(test, *, refresh=False, iverilog_bin=None):
    manifest = json.loads(MANIFEST.read_text())
    if test not in manifest:
        raise Unsupported("no M3 source/dependency audit")
    case = manifest[test]
    source = (ROOT / test).read_bytes()
    if hashlib.sha256(source).hexdigest() != case["source_sha256"]:
        raise Unsupported("source changed; repeat M3 independence and display audit")
    view = source_view(source.decode(), case.get("prepare"))
    module = parse_module(view)
    projected = project(module, case)
    signals = signals_for(module)
    trace, engine = load_input(FIXTURES / (Path(test).stem + ".json"), source, projected, module, signals, case, refresh, iverilog_bin)
    events, summaries = events_for(module, engine, trace)
    return Generated(Path(test).stem, render(view, module, trace, events, case), len(trace.ticks), events, summaries)

"""M2 audited pilot configuration, action events and output-only adapters.

SVA expressions are evaluated exclusively by Engine. The adapters interpret
only increments, pushes of $time, and audited display/report schedules.
No function in this module opens an expected-output file.
"""

from collections import Counter
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re

from .bridge import capture_projected, engine_from_trace, load_projected, project_stimulus
from .module import parse_module
from .parser import Parser, Unsupported
from .source import _balanced, _statement, tokens
from .trace import TraceError
from .values import Bits, evaluate


ROOT = Path(__file__).resolve().parents[2]
FIXTURES = Path(__file__).with_name("fixtures") / "m2"
AUDITS = Path(__file__).with_name("fixtures") / "pilot_sources.json"


@dataclass(frozen=True)
class Pilot:
    signals: tuple
    formals: tuple = ()
    period: int | None = None
    queue: bool = False


PILOTS = {
    "test_sequence_goto_nonconsecutive": Pilot(("s", "b", "c")),
    "test_sequence_throughout_within": Pilot(("req", "en", "ack", "s", "x"), queue=True),
    "test_property_until_strong_forms": Pilot(("start", "a", "b", "c", "d"), ("as", "bs", "cs", "ds"), 50),
    "test_sequence_first_match": Pilot(("a", "b", "c"), queue=True),
    "test_sequence_and_or_intersect": Pilot(("a", "b", "c"), queue=True),
    "test_sequence_consecutive_repetition": Pilot(("a", "b", "c"), queue=True),
    "test_property_nexttime_eventually": Pilot(("start", "x"), ("later",), 60),
    "test_followed_by_existential": Pilot(("go", "p", "q"), ("ps", "qs"), 50),
    "test_property_binary_operator_forms": Pilot(("start", "p", "q"), ("ps", "qs"), 50),
    "test_sequence_empty_match_concatenation": Pilot(("a", "b", "c"), queue=True),
}


@dataclass(frozen=True)
class Event:
    label: str
    start: int
    end: int
    time: int
    branch: str
    target: str
    operation: str


@dataclass(frozen=True)
class Display:
    format: str
    arguments: tuple[str, ...]


@dataclass(frozen=True)
class Generated:
    name: str
    output: str
    ticks: int
    events: tuple[Event, ...]
    attempts: dict


def audit_source(name, source):
    manifest = json.loads(AUDITS.read_text())
    if name not in PILOTS or manifest.get(name) != hashlib.sha256(source).hexdigest():
        raise Unsupported(f"{name}: source changed or lacks an M2 independence/report audit")


def _arguments(source, ts, opening):
    final = _balanced(ts, opening)
    begin, i, result = opening + 1, opening + 1, []
    while i < final - 1:
        if ts[i].text == ",":
            result.append(source[ts[begin].start:ts[i].start].strip())
            begin = i + 1
        i = _balanced(ts, i) if ts[i].text in {"(", "[", "{"} else i + 1
    if begin < final - 1:
        result.append(source[ts[begin].start:ts[final - 1].start].strip())
    return tuple(result), final


def displays(source):
    ts = tokens(source)
    result = []
    for i, token in enumerate(ts):
        if token.text == "$display":
            arguments, _ = _arguments(source, ts, i + 1)
            if not arguments:
                raise Unsupported("empty display is not part of the pilot adapter")
            result.append(Display(json.loads(arguments[0]), tuple("".join(token.text for token in tokens(arg)) for arg in arguments[1:])))
    return tuple(result)


def initial_calls(source, task):
    ts = tokens(source)
    found = []
    for i, token in enumerate(ts):
        if token.text == "initial":
            end = _statement(ts, i + 1)
            j = i + 1
            while j < end:
                if ts[j].text == task and ts[j + 1].text == "(":
                    arguments, j = _arguments(source, ts, j + 1)
                    found.append(arguments)
                else:
                    j += 1
    return tuple(found)


def _action(body):
    compact = re.sub(r"\s+", "", body)
    if compact == ";":
        return None
    counter = re.fullmatch(r"([a-zA-Z_]\w*)\+\+;", compact)
    if counter:
        return counter[1], "increment"
    queue = re.fullmatch(r"([a-zA-Z_]\w*)\.push_back\(\$time\);", compact)
    if queue:
        return queue[1], "push_time"
    raise Unsupported(f"action requires a new adapter/dependency audit: {body}")


def action_events(module, trace):
    engine = engine_from_trace(module, trace)
    events, summaries = [], {}
    for directive in module.directives:
        item, spec = directive.source, directive.spec
        passed, failed = _action(item.passed), _action(item.failed)
        if item.kind == "cover sequence":
            matches = engine.sequence_coverage(spec)
            summaries[item.label] = {"attempted": len(trace.ticks), "matches": len(matches)}
            for match in matches:
                if match.end < match.start:
                    raise Unsupported("an empty top-level coverage match requires a time-boundary adapter")
                if passed:
                    events.append(Event(item.label, match.start, match.end, trace.ticks[match.end].time,
                                        "pass", *passed))
        else:
            attempts = engine.attempts(spec, kind=item.kind)
            summaries[item.label] = dict(Counter(attempt.status for attempt in attempts))
            for attempt in attempts:
                branch = "pass" if attempt.status in {"success", "vacuous"} else "fail" if attempt.status == "failure" else None
                if branch is None or branch == "fail" and item.kind == "cover property":
                    continue
                action = passed if branch == "pass" else failed
                if action:
                    events.append(Event(item.label, attempt.start, attempt.tick, attempt.time, branch, *action))
    return tuple(sorted(events, key=lambda e: (e.time, e.label, e.start))), summaries


def _printf(format_string, arguments):
    items = iter(arguments)
    def replace(match):
        if match[0] == "%%":
            return "%"
        try:
            value = next(items)
        except StopIteration as exc:
            raise Unsupported("too few display arguments") from exc
        conversion = match[0][-1]
        if conversion == "b":
            if not isinstance(value, Bits):
                raise Unsupported("binary display requires a declared bit width")
            return value.bits
        if conversion == "d":
            return str(value.integer() if isinstance(value, Bits) else int(value))
        return str(value)
    if re.search(r"%(?!%|0?[bds])", format_string):
        raise Unsupported("unhandled pilot display conversion")
    result = re.sub(r"%%|%0?[bds]", replace, format_string)
    if next(items, None) is not None:
        raise Unsupported("too many display arguments")
    return result


def render(name, source, trace, events):
    """Option A: format event counters/queues using the source's display text."""
    pilot = PILOTS[name]
    output = displays(source)
    schedules = []
    if pilot.queue:
        schedules.append((trace.end_time, 0, {}))
    elif pilot.period is not None:
        for i, arguments in enumerate(initial_calls(source, "phase")):
            if len(arguments) != len(pilot.formals):
                raise Unsupported("phase adapter argument count changed")
            context = {}
            for formal, argument in zip(pilot.formals, arguments):
                parser = Parser(argument)
                expression = parser.boolean()
                parser.finish()
                context[formal] = evaluate(expression, {})
            schedules.append(((i + 1) * pilot.period, i * pilot.period, context))
    else:
        # report() follows six tick() calls and delays one then nine units.
        for time, arguments in zip((61, 131, 201), initial_calls(source, "report")):
            if len(arguments) != 1:
                raise Unsupported("report adapter argument count changed")
            schedules.append((time, 0, {"phase": json.loads(arguments[0])}))
    if not schedules or not output:
        raise Unsupported("pilot has no report schedule or display")
    targets = {event.target for event in events}
    # A counter with no events still needs to print zero, so parse all actions.
    for directive in parse_module(source).directives:
        for body in (directive.source.passed, directive.source.failed):
            action = _action(body)
            if action:
                targets.add(action[0])
    lines = []
    for time, since, local in schedules:
        if time > trace.end_time:
            raise TraceError("report is beyond the captured simulation end")
        if any(event.time == time for event in events):
            raise Unsupported("action/report collision requires a region-order adapter")
        for display in output:
            arguments = []
            for expression in display.arguments:
                queue = re.fullmatch(r"times\(([a-zA-Z_]\w*)\)", expression)
                if queue:
                    arguments.append("".join(f" {event.time}" for event in events
                                             if event.target == queue[1] and event.operation == "push_time" and event.time < time))
                elif expression in local:
                    arguments.append(local[expression])
                elif expression in targets:
                    arguments.append(sum(event.target == expression and event.operation == "increment" and since <= event.time < time for event in events))
                else:
                    raise Unsupported(f"unhandled display expression: {expression}")
            lines.append(_printf(display.format, arguments))
    return "\n".join(lines) + "\n"


def generate(name, *, iverilog_bin=None, refresh=False):
    if name not in PILOTS:
        raise Unsupported(f"no M2 adapter for {name}")
    path = ROOT / "tests/ch16" / (name + ".sv")
    source = path.read_bytes()
    audit_source(name, source)
    module = parse_module(source.decode())
    pilot = PILOTS[name]
    projected = project_stimulus(module, remove_functions=("times",) if pilot.queue else ())
    cache = FIXTURES / (name + ".json")
    if refresh:
        if iverilog_bin is None:
            raise Unsupported("refresh requires Icarus Verilog 13.0 stable")
        FIXTURES.mkdir(parents=True, exist_ok=True)
        trace = capture_projected(source, projected, module, pilot.signals, iverilog_bin, cache)
    else:
        trace = load_projected(cache, source, projected, module, pilot.signals)
    if trace.timescale != "1ns":
        raise Unsupported("M2 report schedules require a 1ns VCD time unit")
    events, summaries = action_events(module, trace)
    output = render(name, source.decode(), trace, events)
    return Generated(name, output, len(trace.ticks), events, summaries)

"""M4 single-clock sampled-function audits and report adapters.

Only stimulus runs in Icarus. Outputs use History/Engine, never simulator SVA
or sampled functions. Whole-source audits cover procedural report schedules,
absence of action feedback and use of settled values for action-only reads.
"""

from collections import Counter
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import tempfile

from . import bridge, m3, survey
from .engine import Engine
from .module import parse_module
from .parser import SAMPLED, Unsupported
from .pilots import Display, Generated, ROOT, _arguments, _printf
from .sampled import History
from .source import tokens
from .trace import TraceError, load_trace, read_vcd, run_icarus, save_trace


HERE = Path(__file__).parent
MANIFEST = HERE / "fixtures/m4_cases.json"
DEFERRED = HERE / "fixtures/m4_deferred.json"
FIXTURES = HERE / "fixtures/m4"
PROTOCOL = "m4-static-sampled-v1"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def displays(source):
    """Keep token boundaries such as 'posedge clk' in expression arguments."""
    ts = tokens(source)
    result = []
    for i, token in enumerate(ts):
        if token.text == "$display":
            args, _ = _arguments(source, ts, i + 1)
            result.append(Display(json.loads(args[0]), args[1:]))
    return tuple(result)


def load_input(test, source, module, case, *, refresh=False, binary=None):
    # The source audit establishes that removed reports never drive inputs.
    projected = m3.project(module, {})
    if any(token.text in SAMPLED for token in tokens(projected)):
        raise Unsupported("projection retained a sampled function in stimulus")
    declarations = bridge.signal_types(module)
    selected = case["signals"]
    if any(declarations.get(name) is None for name in [case["clock"], *selected]):
        raise Unsupported("M4 selected input lacks supported integral metadata")
    defaults = bridge.signal_defaults(module)
    provenance = {"protocol": PROTOCOL, "source_sha256": digest(source),
                  "projection_sha256": digest(projected.encode()),
                  "clock": module.top + "." + case["clock"], "edge": case["edge"],
                  "signals": [module.top + "." + name for name in selected],
                  "types": {name: asdict(declarations[name]) for name in selected},
                  "defaults": {name: asdict(defaults[name]) for name in selected},
                  "current_mode": "audited_settled_equals_action_reads" if case["mode"] == "actions" else None}
    key = bridge.cache_input(source, provenance)
    destination = FIXTURES / (Path(test).stem + ".json")
    if refresh:
        _, vcd = run_icarus(projected, module.top, binary)
        if vcd is None:
            raise TraceError("M4 stimulus did not produce VCD")
        with tempfile.TemporaryDirectory(prefix="sva-m4-") as directory:
            path = Path(directory) / "trace.vcd"
            path.write_text(vcd)
            trace = read_vcd(path, provenance["clock"], provenance["signals"], provenance["edge"])
        destination.parent.mkdir(parents=True, exist_ok=True)
        save_trace(destination, trace, key, provenance["signals"])
        data = json.loads(destination.read_text())
        data["projection"] = provenance
        destination.write_text(json.dumps(data, indent=2) + "\n")
    else:
        data = json.loads(destination.read_text())
        if data.get("projection") != provenance:
            raise TraceError("stale M4 source, projection, default, type or scheduling audit")
        trace = load_trace(destination, key, provenance["clock"], provenance["signals"], provenance["edge"])
    def decode(snapshot):
        return {name: declarations[name].decode(snapshot[module.top + "." + name]) for name in selected}
    samples = [decode(tick.sampled) for tick in trace.ticks]
    live = [decode(tick.settled) for tick in trace.ticks]
    return trace, samples, live, defaults


def generate(test, *, refresh=False, iverilog_bin=None):
    audits = json.loads(MANIFEST.read_text())
    if test not in audits:
        raise Unsupported("no M4 source/dependency/report audit")
    case = audits[test]
    source = (ROOT / test).read_bytes()
    if digest(source) != case["source_sha256"]:
        raise Unsupported("source changed; repeat M4 input/report/region audit")
    module = parse_module(source.decode())
    trace, samples, live, defaults = load_input(test, source, module, case, refresh=refresh, binary=iverilog_bin)
    history = History(samples, defaults=defaults, clock=(case["clock"], case["edge"]))
    lines, reports, state = [], [], {}

    def display(item, tick, *, action=False):
        time = trace.ticks[tick].time
        values = {**(live[tick] if action else samples[tick]), **state, "__time": time}
        if case.get("tick_counter"):
            values[case["tick_counter"]] = tick + 1
        args = [history.evaluate(m3.expression(arg.replace("$time", "__time")), tick, live=values)
                for arg in item.arguments]
        lines.append(_printf(item.format.replace("%0t", "%0d"), args))
        reports.append({"time": time, "context": "action" if action else "procedure",
                        "arguments": [asdict(value) for value in args]})

    events, attempts = (), {}
    if case["mode"] == "procedure":
        if module.directives:
            raise Unsupported("procedural-report audit unexpectedly has concurrent directives")
        items = displays(module.stimulus)
        schedule = case.get("display_times")
        if schedule is not None and len(schedule) != len(items):
            raise Unsupported("M4 conditional-display schedule no longer applies")
        for tick, sample in enumerate(trace.ticks):
            for i, item in enumerate(items):
                if schedule is None or sample.time == schedule[i]:
                    display(item, tick)
    elif case["mode"] == "actions":
        if any((d.spec.clock, d.spec.edge) != (case["clock"], case["edge"]) for d in module.directives):
            raise Unsupported("M4 action adapter requires the audited single clock")
        engine = Engine(samples, defaults=defaults, clock=history.clock,
                        times=[t.time for t in trace.ticks], end_time=trace.end_time)
        events, attempts = m3.events_for(module, engine, trace)
        for event in events:
            # These audited actions only have optional report-counter ++
            # followed by displays, with no scheduling or stimulus feedback.
            if case.get("counter"):
                name = case["counter"]
                state[name] = state.get(name, 0) + 1
            for item in displays(event.body):
                display(item, event.end, action=True)
        for item in displays(module.stimulus):
            args = [state.get(arg, 0) for arg in item.arguments]
            if any(arg != case.get("counter") for arg in item.arguments):
                raise Unsupported("M4 final report requires another dependency audit")
            lines.append(_printf(item.format, args))
    else:
        raise Unsupported("unknown M4 reporting mode")
    attempts["sampled_reports"] = reports
    return Generated(Path(test).stem, "\n".join(lines) + ("\n" if lines else ""), len(trace.ticks), events, attempts)


def inventory():
    audits = json.loads(MANIFEST.read_text())
    deferred = json.loads(DEFERRED.read_text())
    rows = []
    for row in survey.candidates(include_sampled=True):
        words = {token.text for token in tokens(row["body"]) if not token.text.startswith('"')}
        functions = sorted(words & SAMPLED)
        if row["illegal"] or not functions:
            continue
        item = {key: row[key] for key in ["test", "chapter", "source_sha256"]}
        item["functions"] = functions
        if row["test"] in audits:
            item.update(status="audited", reason="single-clock static integral input/report audit")
        elif row["test"] in deferred:
            audit = deferred[row["test"]]
            item.update(status="deferred" if audit["source_sha256"] == row["source_sha256"] else "unhandled",
                        reason=audit["reason"], evidence=audit["evidence"])
        else:
            item.update(status="unhandled", reason="new sampled-function candidate needs an explicit scope/input audit")
        rows.append(item)
    present = {row["test"] for row in rows}
    for test in sorted(set(audits) - present):
        path = ROOT / test
        rows.append({"test": test, "chapter": path.parent.name,
                     "source_sha256": digest(path.read_bytes()) if path.exists() else None,
                     "functions": [], "status": "unhandled",
                     "reason": "audited M4 source disappeared or no longer qualifies as a sampled-function candidate"})
    return rows


def run(*, refresh=False, iverilog_bin=None, emit_only=False, output_dir=None):
    rows, generated = inventory(), {}
    # All selected outputs are produced before consulting any expectation.
    for row in rows:
        if row["status"] == "audited":
            try:
                item = generate(row["test"], refresh=refresh, iverilog_bin=iverilog_bin)
                generated[row["test"]] = item
                row.update(status="generated", ticks=item.ticks, actions=len(item.events),
                           report_lines=len(item.output.splitlines()), actual_sha256=digest(item.output.encode()))
            except (ValueError, OSError) as exc:
                row.update(status="error", reason=str(exc))
    if not emit_only:
        for row in rows:
            if row["test"] in generated:
                row.update(survey.compare(row["test"], generated[row["test"]]))
    result = {"schema": 1, "scope": "M4 approved single-clock static sampled functions; mixed features explicitly deferred",
              "counts": dict(sorted(Counter(row["status"] for row in rows).items())), "tests": rows}
    if output_dir is not None:
        folder = Path(output_dir)
        folder.mkdir(parents=True, exist_ok=True)
        for test, item in generated.items():
            (folder / (item.name + ".actual")).write_text(item.output)
            (folder / (item.name + ".events.json")).write_text(json.dumps({"test": test, "attempts": item.attempts,
                "events": [asdict(event) for event in item.events]}, indent=2) + "\n")
        (folder / "inventory.json").write_text(json.dumps(result, indent=2) + "\n")
    return result

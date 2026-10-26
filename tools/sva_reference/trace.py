"""VCD sampling (1800-2023 16.5.1, 21.7.2) and hash-bound JSON traces.

Only static integral signals and one scalar, glitch-free clock are supported.
Values are full-width bit strings, including x/z. Same-time VCD changes never
enter the sampled snapshot. End-of-slot values are separate, and are NOT a
substitute for unsampled disable conditions in the Observed region.
"""

import argparse
from dataclasses import asdict, dataclass
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

from .source import inspect_source, rewrite, tokens


SCHEMA = 1
PROTOCOL = "sva-reference-m0-v1"
EDGES = {"posedge": {("0", "1"), ("0", "x"), ("0", "z"), ("x", "1"), ("z", "1")},
         "negedge": {("1", "0"), ("1", "x"), ("1", "z"), ("x", "0"), ("z", "0")}}


class TraceError(ValueError):
    pass


@dataclass(frozen=True)
class Signal:
    code: str
    width: int
    kind: str


@dataclass(frozen=True)
class Tick:
    time: int
    sampled: dict[str, str]
    settled: dict[str, str]


@dataclass(frozen=True)
class Trace:
    timescale: str
    clock: str
    edge: str
    widths: dict[str, int]
    ticks: list[Tick]
    end_time: int


def _bits(value, width):
    value = value.lower()
    if not re.fullmatch("[01xz]+", value) or len(value) > width:
        raise TraceError(f"invalid {width}-bit VCD value: {value}")
    fill = value[0] if value[0] in "xz" else "0"
    return value.rjust(width, fill)


def read_vcd(path, clock, signals, edge="posedge", *, current_callback=None):
    """Sample selected exact hierarchical names before each clock timestamp.

    Aliased identifiers share state. Time-zero selected edges, dump gaps,
    real/event samples and clock glitches are rejected. A VCD producer may
    hide delta-cycle glitches, so the stimulus must also be audited.
    """
    if edge not in EDGES:
        raise TraceError(f"unknown edge: {edge}")
    words = iter(Path(path).read_text(encoding="utf-8").split())
    scope, declarations, timescale = [], {}, None

    def command():
        result = []
        for word in words:
            if word == "$end":
                return result
            result.append(word)
        raise TraceError("unterminated VCD command")

    for word in words:
        if word == "$scope":
            args = command()
            scope.append(args[1])
        elif word == "$upscope":
            command()
            if not scope:
                raise TraceError("unbalanced VCD scope")
            scope.pop()
        elif word == "$var":
            args = command()
            kind, width, code, reference = args[:4]
            name = ".".join([*scope, reference])
            if name in declarations:
                raise TraceError(f"duplicate VCD name: {name}")
            declarations[name] = Signal(code, int(width), kind)
        elif word == "$timescale":
            timescale = "".join(command())
        elif word == "$enddefinitions":
            command()
            break
        elif word.startswith("$"):
            command()
        else:
            raise TraceError(f"unexpected VCD header token: {word}")
    else:
        raise TraceError("missing VCD enddefinitions")
    if timescale is None or not re.fullmatch(r"(?:1|10|100)(?:s|ms|us|ns|ps|fs)", timescale):
        raise TraceError("missing or invalid VCD timescale")
    selected = list(dict.fromkeys(signals))
    required = list(dict.fromkeys([clock, *selected]))
    for name in required:
        if name not in declarations:
            raise TraceError(f"signal not found (use exact hierarchical name): {name}")
        signal = declarations[name]
        if signal.kind in {"real", "realtime", "event", "string"} or signal.width < 1:
            raise TraceError(f"not an integral static signal: {name}")
    if declarations[clock].width != 1:
        raise TraceError("clock must be scalar")
    by_code = {}
    for name in required:
        signal = declarations[name]
        if signal.code in by_code and by_code[signal.code] != signal.width:
            raise TraceError("aliases disagree on width")
        by_code[signal.code] = signal.width
    values = {code: "x" * width for code, width in by_code.items()}
    before = values.copy()
    time, clock_changes, ticks = 0, [], []
    clock_code = declarations[clock].code

    def snapshot(state):
        return {name: state[declarations[name].code] for name in selected}

    def finish_slot():
        if current_callback is not None:
            current_callback(time, snapshot(values))
        if len(clock_changes) > 1:
            raise TraceError(f"multiple clock transitions at VCD time {time}")
        if clock_changes and clock_changes[0] in EDGES[edge]:
            if time == 0:
                raise TraceError("time-zero sampling requires declaration/type defaults (16.5.1)")
            ticks.append(Tick(time, snapshot(before), snapshot(values)))

    for word in words:
        if word.startswith("#"):
            new_time = int(word[1:])
            if new_time < time:
                raise TraceError("VCD timestamps are not monotonic")
            if new_time != time:
                finish_slot()
                time = new_time
                before = values.copy()
                clock_changes = []
            continue
        if word in {"$dumpvars", "$dumpall", "$end"}:
            continue
        if word in {"$dumpoff", "$dumpon"}:
            raise TraceError("VCD dump gaps cannot provide an assertion trace")
        if word == "$comment":
            command()
            continue
        if word.startswith("$"):
            raise TraceError(f"unsupported VCD command: {word}")
        if word[0].lower() in {"b", "r", "s"}:
            code = next(words)
            if word[0].lower() != "b":
                if code in by_code:
                    raise TraceError("non-integral VCD sample")
                continue
            value = word[1:]
        elif word[0].lower() in "01xz":
            value, code = word[0], word[1:]
        else:
            raise TraceError(f"unsupported VCD change: {word}")
        if code not in by_code:
            continue
        value = _bits(value, by_code[code])
        if code == clock_code and value != values[code]:
            clock_changes.append((values[code], value))
        values[code] = value
    finish_slot()
    if not ticks:
        raise TraceError("no selected clock edges in VCD")
    return Trace(timescale, clock, edge,
                 {name: declarations[name].width for name in selected}, ticks, time)


def fingerprint(source, clock, signals, edge):
    """Hash source bytes and extraction configuration; never reads .expected."""
    config = {"protocol": PROTOCOL, "clock": clock, "signals": list(signals), "edge": edge}
    return hashlib.sha256(source + b"\0" + json.dumps(config, sort_keys=True).encode()).hexdigest()


def save_trace(path, trace, source, signals):
    data = {"schema": SCHEMA, "protocol": PROTOCOL, "producer": "iverilog@13.0",
            "inputs_sha256": fingerprint(source, trace.clock, signals, trace.edge),
            "signals": list(signals), "trace": asdict(trace)}
    Path(path).write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def load_trace(path, source, clock, signals, edge="posedge"):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if (data.get("schema") != SCHEMA or data.get("protocol") != PROTOCOL
            or data.get("producer") != "iverilog@13.0"):
        raise TraceError("unknown trace schema/protocol/producer")
    if data.get("inputs_sha256") != fingerprint(source, clock, signals, edge):
        raise TraceError("stale trace: source or sampling configuration changed")
    raw = data["trace"]
    if raw["clock"] != clock or raw["edge"] != edge or data["signals"] != list(signals):
        raise TraceError("trace configuration disagrees with provenance")
    trace = Trace(**{**raw, "ticks": [Tick(**tick) for tick in raw["ticks"]]})
    if set(trace.widths) != set(signals) or not trace.ticks:
        raise TraceError("invalid trace signal set or empty trace")
    previous = 0
    for tick in trace.ticks:
        if tick.time <= previous or tick.time > trace.end_time:
            raise TraceError("invalid tick order or end time")
        previous = tick.time
        for state in (tick.sampled, tick.settled):
            if set(state) != set(trace.widths):
                raise TraceError("invalid trace snapshot")
            for name, value in state.items():
                if _bits(value, trace.widths[name]) != value:
                    raise TraceError("trace values must be full-width lowercase bits")
    return trace


def _run(argv, directory):
    try:
        result = subprocess.run(argv, cwd=directory, capture_output=True, text=True,
                                timeout=30, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise TraceError(f"simulator could not run: {exc}") from exc
    if result.returncode:
        raise TraceError(f"simulator exited {result.returncode}:\n{result.stdout}{result.stderr}")
    return result.stdout


def run_icarus(source, top, iverilog_bin):
    """Compile/run in a disposable directory, using only the pinned release."""
    binaries = Path(iverilog_bin).resolve()
    version = _run([str(binaries / "iverilog"), "-V"], None)
    if not re.search(r"Icarus Verilog version 13\.0 \(stable\)", version):
        raise TraceError("trace/replay requires Icarus Verilog 13.0 stable")
    with tempfile.TemporaryDirectory(prefix="sva-reference-") as directory:
        root = Path(directory)
        (root / "source.sv").write_text(source, encoding="utf-8")
        _run([str(binaries / "iverilog"), "-g2012", "-s", top,
              "-o", "sim.vvp", "source.sv"], directory)
        stdout = _run([str(binaries / "vvp"), "-n", "sim.vvp"], directory)
        vcd = (root / "trace.vcd").read_text() if (root / "trace.vcd").exists() else None
    return stdout, vcd


def capture(path, clock, signals, iverilog_bin, edge="posedge"):
    source_bytes = Path(path).read_bytes()
    source = source_bytes.decode("utf-8")
    top, _ = inspect_source(source)
    if any(t.text in {"$dumpvars", "$dumpfile", "$dumpoff", "$dumpon", "$dumpall"}
           for t in tokens(source)):
        raise TraceError("source already controls VCD dumping")
    extra = f'\ninitial begin $dumpfile("trace.vcd"); $dumpvars(0, {top}); end\n'
    _, vcd = run_icarus(rewrite(source, extra=extra), top, iverilog_bin)
    if vcd is None:
        raise TraceError("simulation did not produce a VCD")
    with tempfile.TemporaryDirectory(prefix="sva-vcd-") as directory:
        vcd_path = Path(directory) / "trace.vcd"
        vcd_path.write_text(vcd)
        trace = read_vcd(vcd_path, clock, signals, edge)
    return trace, source_bytes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--clock", required=True, help="exact hierarchical VCD name")
    parser.add_argument("--signals", nargs="+", required=True)
    parser.add_argument("--edge", choices=EDGES, default="posedge")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        trace, source = capture(args.source, args.clock, args.signals, args.iverilog_bin, args.edge)
        save_trace(args.output, trace, source, args.signals)
    except (TraceError, ValueError) as exc:
        parser.exit(1, f"{exc}\n")
    print(f"{len(trace.ticks)} ticks ({trace.timescale}); saved {args.output}")


if __name__ == "__main__":
    main()

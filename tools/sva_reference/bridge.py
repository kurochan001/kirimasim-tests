"""Audited stimulus projection, declared integral types, and M2 trace caches.

The caller must establish action/report independence before projecting source.
This module never reads expected output or executes an assertion action.
"""

from dataclasses import asdict, dataclass
import hashlib
import json
from pathlib import Path
import re
import tempfile

from .engine import Engine
from .parser import Parser, Unsupported
from .source import _balanced, _statement, tokens
from .trace import TraceError, load_trace, read_vcd, run_icarus, save_trace
from .values import Bits, evaluate


PROTOCOL = "sva-reference-projection-v1"


@dataclass(frozen=True)
class SignalType:
    width: int
    signed: bool = False
    two_state: bool = False
    lsb: int = 0
    ascending: bool = False

    def decode(self, bits):
        if len(bits) != self.width:
            raise TraceError("VCD width disagrees with the source declaration")
        if self.two_state and any(c in "xz" for c in bits):
            raise TraceError("unknown VCD value in a declared two-state signal")
        return Bits(bits, self.signed, False, self.lsb, self.ascending)


def _constant(text, parameters):
    parser = Parser(text)
    expression = parser.boolean()
    parser.finish()
    return evaluate(expression, parameters).integer()


def signal_types(module):
    """Read top-level primitive integral declarations, not subroutine locals.

    No typedefs, unpacked arrays or elaboration are inferred. Such a selected
    signal fails explicitly rather than silently becoming an unsigned scalar.
    """
    source = module.stimulus
    ts = tokens(source)
    words = [token.text for token in ts]
    atom_types = {"byte": 8, "shortint": 16, "int": 32, "integer": 32, "longint": 64, "time": 64}
    vectors = {"logic", "reg", "bit", "wire", "tri"}
    types = {}
    i = words.index("module") + 2
    # M2 does not elaborate module ports/parameters. The pilot tops have none.
    if words[i] != ";":
        raise Unsupported("typed trace bridge requires a portless, unparameterized top")
    i += 1
    while i < len(ts) and words[i] != "endmodule":
        word = words[i]
        if word in {"task", "function"}:
            i = words.index("end" + word, i + 1) + 1
            continue
        if word in {"initial", "always", "always_ff", "always_comb", "always_latch", "final"}:
            i = _statement(ts, i + 1)
            continue
        if word not in vectors | set(atom_types):
            i += 1
            continue
        j = i + 1
        base = word
        if base in {"wire", "tri"} and words[j] in {"logic", "reg", "bit"}:
            base = words[j]
            j += 1
        signed = base in set(atom_types) - {"time"}
        if words[j] in {"signed", "unsigned"}:
            signed = words[j] == "signed"
            j += 1
        width = atom_types.get(base, 1)
        lsb, ascending = 0, False
        if words[j] == "[":
            end = _balanced(ts, j)
            if base in atom_types or words[j:end].count(":") != 1:
                raise Unsupported("unsupported packed declaration")
            colon = words.index(":", j + 1, end)
            msb = _constant(source[ts[j].end:ts[colon].start], module.parameters)
            lsb = _constant(source[ts[colon].end:ts[end - 1].start], module.parameters)
            width, ascending = abs(msb - lsb) + 1, msb < lsb
            j = end
        metadata = SignalType(width, signed, base in {"bit", "byte", "shortint", "int", "longint"}, lsb, ascending)
        while True:
            name = words[j]
            if not re.fullmatch(r"[a-zA-Z_]\w*", name):
                raise Unsupported("unsupported declaration in the trace bridge")
            j += 1
            # Keep reporting queues/unpacked arrays unselected, but do not
            # assign integral metadata to them.
            types[name] = None if words[j] == "[" else metadata
            while j < len(ts) and words[j] not in {",", ";"}:
                j = _balanced(ts, j) if words[j] in {"(", "[", "{"} else j + 1
            if j >= len(ts):
                raise Unsupported("unterminated integral declaration")
            if words[j] == ";":
                i = j + 1
                break
            j += 1
    return types


def _blank(source, begin, end, replacement=""):
    old = source[begin:end]
    filler = "".join("\n" if c == "\n" else " " for c in old)
    if replacement:
        filler = replacement + filler[len(replacement):]
    return source[:begin] + filler + source[end:]


def project_stimulus(module, *, remove_functions=()):
    """Strip only audited reporting code, keeping stimulus delays and finish.

    Null statements replace displays, preserving timing/conditional statement
    boundaries. Function names are explicit; stimulus functions stay intact.
    """
    source = module.stimulus
    ts = tokens(source)
    words = [token.text for token in ts]
    spans, removed, i = [], set(), 0
    while i < len(ts):
        if words[i] == "function":
            end = words.index("endfunction", i + 1)
            opening = words.index("(", i + 1, end) if "(" in words[i + 1:end] else None
            name = words[opening - 1] if opening is not None else None
            if name in remove_functions:
                spans.append((ts[i].start, ts[end].end, ""))
                removed.add(name)
                i = end + 1
                continue
        if words[i] == "$display":
            end = _statement(ts, i)
            spans.append((ts[i].start, ts[end - 1].end, ";"))
            i = end
            continue
        if words[i] in {"$dumpfile", "$dumpvars", "$dumpon", "$dumpoff", "$dumpall"}:
            raise Unsupported("source already controls VCD dumping")
        i += 1
    if removed != set(remove_functions):
        raise Unsupported("a reporting function selected for removal was not found")
    for begin, end, replacement in sorted(spans, reverse=True):
        source = _blank(source, begin, end, replacement)
    if any(t.text in remove_functions for t in tokens(source)):
        raise Unsupported("removed reporting function is still referenced by stimulus")
    end = next(token.start for token in tokens(source) if token.text == "endmodule")
    extra = f'\ninitial begin $dumpfile("trace.vcd"); $dumpvars(0, {module.top}); end\n'
    return source[:end] + extra + source[end:]


def context(source_bytes, projected, module, signals):
    if not module.directives:
        raise Unsupported("no concurrent directives")
    spec = module.directives[0].spec
    declarations = signal_types(module)
    selected = list(dict.fromkeys([spec.clock, *signals]))
    for name in selected:
        if name not in declarations or declarations[name] is None:
            raise Unsupported(f"selected signal lacks supported declaration metadata: {name}")
    if declarations[spec.clock].width != 1:
        raise Unsupported("clock must be a scalar signal")
    return {"protocol": PROTOCOL, "source_sha256": hashlib.sha256(source_bytes).hexdigest(),
            "projection_sha256": hashlib.sha256(projected.encode()).hexdigest(),
            "clock": f"{module.top}.{spec.clock}", "edge": spec.edge,
            "signals": [f"{module.top}.{name}" for name in signals],
            "types": {name: asdict(declarations[name]) for name in selected}}


def cache_input(source_bytes, provenance):
    return source_bytes + b"\0" + json.dumps(provenance, sort_keys=True).encode()


def capture_projected(source_bytes, projected, module, signals, iverilog_bin, destination):
    provenance = context(source_bytes, projected, module, signals)
    _, vcd = run_icarus(projected, module.top, iverilog_bin)
    if vcd is None:
        raise TraceError("projected stimulus did not produce a VCD")
    with tempfile.TemporaryDirectory(prefix="sva-projected-") as directory:
        path = Path(directory) / "trace.vcd"
        path.write_text(vcd)
        trace = read_vcd(path, provenance["clock"], provenance["signals"], provenance["edge"])
    save_trace(destination, trace, cache_input(source_bytes, provenance), provenance["signals"])
    data = json.loads(Path(destination).read_text())
    data["projection"] = provenance
    Path(destination).write_text(json.dumps(data, indent=2) + "\n")
    return trace


def load_projected(path, source_bytes, projected, module, signals):
    provenance = context(source_bytes, projected, module, signals)
    data = json.loads(Path(path).read_text())
    if data.get("projection") != provenance:
        raise TraceError("stale trace: stimulus projection or declaration metadata changed")
    return load_trace(path, cache_input(source_bytes, provenance), provenance["clock"], provenance["signals"], provenance["edge"])


def engine_from_trace(module, trace, *, current=None, defaults=None):
    spec = module.directives[0].spec
    if trace.clock != f"{module.top}.{spec.clock}" or trace.edge != spec.edge:
        raise TraceError("trace clock/edge disagrees with the parsed directives")
    declarations = signal_types(module)
    samples = []
    for tick in trace.ticks:
        row = {}
        for full_name, bits in tick.sampled.items():
            if not full_name.startswith(module.top + "."):
                raise Unsupported("sample is outside the selected top scope")
            name = full_name[len(module.top) + 1:]
            metadata = declarations.get(name)
            if metadata is None:
                raise Unsupported(f"sample has no supported declaration: {name}")
            if trace.widths.get(full_name) != metadata.width:
                raise TraceError("VCD width disagrees with the source declaration")
            row[name] = row[full_name] = metadata.decode(bits)
        samples.append(row)
    return Engine(samples, times=[tick.time for tick in trace.ticks], current=current,
                  end_time=trace.end_time, defaults=defaults, clock=(spec.clock, spec.edge))


def signal_defaults(module):
    """Declaration/type defaults for top-level static integral signals (16.5.1).

    Nets use type defaults even with a continuous declaration assignment.
    A selected unsupported declaration/initializer fails; no first VCD sample
    or time-zero settled value is substituted for a declaration default.
    """
    declarations = signal_types(module)
    source = module.stimulus
    ts = tokens(source)
    words = [token.text for token in ts]
    types = {"logic", "reg", "bit", "wire", "tri", "byte", "shortint", "int", "integer", "longint", "time"}
    result = dict(module.parameters)
    i = words.index("module") + 3
    while i < len(ts) and words[i] != "endmodule":
        if words[i] in {"task", "function"}:
            i = words.index("end" + words[i], i + 1) + 1
            continue
        if words[i] in {"initial", "always", "always_ff", "always_comb", "always_latch", "final"}:
            i = _statement(ts, i + 1)
            continue
        if words[i] not in types:
            i += 1
            continue
        net = words[i] in {"wire", "tri"}
        j = i + 1
        while words[j] in types | {"signed", "unsigned"}:
            j += 1
        if words[j] == "[":
            j = _balanced(ts, j)
        while True:
            name = words[j]
            metadata = declarations[name]
            end = j + 1
            while words[end] not in {",", ";"}:
                end = _balanced(ts, end) if words[end] in {"(", "[", "{"} else end + 1
            if metadata is not None:
                value = Bits(("0" if metadata.two_state else "x") * metadata.width, metadata.signed,
                             False, metadata.lsb, metadata.ascending)
                if not net and words[j + 1] == "=":
                    parser = Parser(source[ts[j + 1].end:ts[end].start])
                    expression = parser.boolean()
                    parser.finish()
                    raw = evaluate(expression, result, metadata.width).resize(metadata.width, metadata.signed)
                    value = Bits(raw.bits.translate(str.maketrans("xz", "00")) if metadata.two_state else raw.bits,
                                 metadata.signed, False, metadata.lsb, metadata.ascending)
                result[name] = result[module.top + "." + name] = value
            if words[end] == ";":
                i = end + 1
                break
            j = end + 1
    return result

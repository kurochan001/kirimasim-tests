"""Cross bit-vector system queries with shape, position and control sets.

20.9 counts exact four-state values, deduplicates countbits controls, and
defines onehot/onehot0 from the number of known ones. The oracle counts
characters in the fully formed argument after source-state conversion.
"""

from common import Case
from interaction_bits import two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_query"
VERSION = 1
CHAPTER = 20
CONTROLS = {"zero": "0", "one": "1", "unknown": "xz", "mixed": "1xz",
            "duplicate": "11xxzz"}


def legal(row: Row) -> bool:
    w, _, shape, value, position, _ = row
    if (value == "zero") != (position == "none"):
        return False
    return w != "1" or (shape != "half" and value not in ("many", "mixed")
                         and position in ("none", "low"))


MODEL = Model(
    "bit_vector_queries",
    (("width", ("1", "32", "33", "64", "65", "129")), ("state", ("bit", "logic")),
     ("expression", ("direct", "half", "prefix", "repeat")),
     ("value", ("zero", "one", "many", "x", "z", "mixed")),
     ("position", ("none", "low", "middle", "high")), ("controls", tuple(CONTROLS))),
    legal,
    groups=(("value", "state", "controls"), ("expression", "value", "state")),
    anchors=(("129", "logic", "repeat", "mixed", "middle", "duplicate"),
             ("65", "logic", "direct", "x", "high", "unknown"),
             ("33", "bit", "half", "one", "high", "one"),
             ("32", "logic", "prefix", "z", "low", "mixed")),
    constraints=("zeroの位置はnone。他の値はlow/middle/high。幅1ではlowだけを使い、"
                 "many/mixedとhalfを除外。halfは下位半分。制御ビットは1ビット定数",),
)


def case_name(row: Row) -> str:
    w, state, shape, value, position, controls = row
    return f"test_gen_cross_query_w{w}_{state[0]}_{shape}_{value}_{position}_{controls}"


def source_bits(row: Row) -> str:
    w, _, _, value, position, _ = row
    w = int(w)
    bits = ["0"] * w
    p = {"none": 0, "low": 0, "middle": w // 2, "high": w - 1}[position]
    if value == "one":
        bits[w - 1 - p] = "1"
    elif value == "many":
        for i in (p, (p + 1) % w):
            bits[w - 1 - i] = "1"
    elif value in ("x", "z"):
        bits[w - 1 - p] = value
        if w > 1:
            bits[w - 1 - (p + 1) % w] = "1"
    elif value == "mixed":
        for i, c in enumerate("xz1"):
            bits[w - 1 - (p + i) % w] = c
    return "".join(bits)


def reference(row: Row) -> tuple[str, str, tuple[int, int, int, int, int, int]]:
    _, state, shape, _, _, control = row
    raw = source_bits(row)
    source = two_state(raw) if state == "bit" else raw
    expression = {"direct": source, "half": source[-(len(source) // 2):],
                  "prefix": "1" + source, "repeat": source * 2}[shape]
    ones = expression.count("1")
    controls = set(CONTROLS[control])
    result = (len(expression), sum(c in controls for c in expression), ones,
              int(ones == 1), int(ones <= 1), int(any(c in "xz" for c in expression)))
    return source, expression, result


def icarus_unstable(row: Row) -> bool:
    n = len(reference(row)[1])
    return row[2] in ("prefix", "repeat") and n > 64 and n % 32 != 0


def make_case(row: Row) -> Case:
    w, state, shape, value, _, control = row
    w = int(w)
    name = case_name(row)
    source, expression, result = reference(row)
    expr = {"direct": "source", "half": f"source[{w // 2 - 1}:0]",
            "prefix": "{1'b1, source}", "repeat": "{2{source}}"}[shape]
    controls = ", ".join(f"1'b{c}" for c in CONTROLS[control])
    lines = [f"module {name};", f"  {state} [{w - 1}:0] source;",
             "  integer bits, count, ones;", "  bit hot, hot0, unknown;", "  initial begin",
             f"    source = {literal(source_bits(row))};", f"    bits = $bits({expr});",
             f"    count = $countbits({expr}, {controls});", f"    ones = $countones({expr});",
             f"    hot = $onehot({expr});", f"    hot0 = $onehot0({expr});",
             f"    unknown = $isunknown({expr});", f'    $display("source=%b expr=%b", source, {expr});',
             '    $display("bits=%0d count=%0d ones=%0d", bits, count, ones);',
             '    $display("onehot=%b onehot0=%b unknown=%b", hot, hot0, unknown);',
             "    $finish;", "  end", "endmodule"]
    b, c, o, h, h0, u = result
    note = (" Icarus Verilog 13.0 gives differing countones results across identical "
            "reruns for this wide concatenation/replication. It is not registered as "
            "this case's fixed oracle; the standard-based expectation is unchanged."
            if icarus_unstable(row) else "")
    return Case(
        name, "Bit-vector query functions respect expression shape, unknowns and duplicate controls",
        "20.9 20.6.2 6.11.2 11.4.12 11.5.1",
        "The argument is a direct vector, lower-half select, prefixed concatenation or "
        "replication. The source state conversion happens before the query. Countbits "
        "counts a set of exact 0/1/X/Z values; duplicate controls do not multiply hits. "
        "Onehot functions count known ones even when X/Z is present. Source, argument, "
        "width and all query results are observed, including unknowns above bit 64." + note,
        "\n".join(lines), f"source={source} expr={expression}\nbits={b} count={c} ones={o}\n"
        f"onehot={h} onehot0={h0} unknown={u}\n",
        fourstate=value in ("x", "z", "mixed") or control in ("unknown", "mixed", "duplicate"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

"""Cross event OR terms with conditional filtering and trigger regions.

9.4.2.1 makes comma and or synonymous; 9.4.2.3 binds iff to its own
term and evaluates the guard on that event, not on guard-only changes.
Each stimulus settles for a tick before observation and the next stimulus.
"""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_iff"
VERSION = 1
CHAPTER = 9

MODEL = Model(
    "event_or_iff",
    (("join", ("or", "comma")), ("source", ("signals", "named", "mixed")),
     ("edge", ("change", "posedge", "negedge")),
     ("filter", ("both", "first", "second")),
     ("guard", ("known", "xz", "mixed")), ("update", ("blocking", "nba"))),
    lambda r: r[1] != "named" or r[2] == "change",
    groups=(("source", "filter", "guard"), ("join", "filter", "edge"),
            ("source", "edge", "update")),
    anchors=(("or", "mixed", "posedge", "both", "mixed", "nba"),
             ("comma", "signals", "negedge", "second", "xz", "blocking"),
             ("or", "named", "change", "first", "known", "nba"),
             ("comma", "signals", "change", "first", "known", "blocking")),
    constraints=("名前付きイベントだけの行はedge=changeに統一。mixedは左が信号、右が名前付き。"
                 "エッジ指定は信号項だけに適用。条件と二つのイベントを別時刻で更新し、"
                 "初期設定後に計数をクリアする。同時発火、グリッチ、sequenceイベント、"
                 "条件式の副作用は対象外。未対応による除外はしない",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_iff_" + "_".join(row)


def named(row: Row, side: int) -> bool:
    return row[1] == "named" or (row[1] == "mixed" and side == 1)


def actions(row: Row) -> list[tuple[str, str, str, str]]:
    """Input protocol: change guards alone, then separate the two sources."""
    width = 33 if row[4] == "mixed" else 1
    zero, one = "0" * width, "0" * (width - 1) + "1"
    gates = [(zero, zero), (one, zero), (zero, one), (one, one)]
    if row[4] == "xz":
        gates += [("x", "0"), ("0", "z"), ("x", "z"), ("z", "x")]
    elif row[4] == "mixed":
        gates += [("1" + "x" * 32, zero), (zero, "z" * 32 + "1"),
                  ("x" * 33, "z" * 33), ("x" * 32 + "1", "1" + "z" * 32)]
    gates += [(zero, zero), (one, one)]
    result = []
    for i, (a, b) in enumerate(gates):
        result += [(f"p{i}_guards", "guards", a, b),
                   (f"p{i}_left_up", "left", "1", ""),
                   (f"p{i}_right_up", "right", "1", ""),
                   (f"p{i}_left_down", "left", "0", ""),
                   (f"p{i}_right_down", "right", "0", ""),
                   (f"p{i}_left_repeat", "left", "0", "")]
    return result


def reference(row: Row) -> str:
    """Count individual events and the per-term qualified OR independently."""
    signal = ["0", "0"]
    gates = ["0" * (33 if row[4] == "mixed" else 1)] * 2
    raw = [0, 0]
    filtered = 0
    output = []
    for label, kind, a, b in actions(row):
        if kind == "guards":
            gates = [a, b]
        else:
            side = int(kind == "right")
            old = signal[side]
            is_named = named(row, side)
            immediate = signal.copy()
            if not is_named and row[5] == "blocking":
                immediate[side] = a
            output.append(f"{label}_scheduled={immediate[0]},{immediate[1]}")
            if not is_named:
                signal[side] = a
            event = is_named or (old != a and (row[2] == "change" or
                    a == ("1" if row[2] == "posedge" else "0")))
            if event:
                raw[side] += 1
                guarded = row[3] == "both" or row[3] == ("first" if side == 0 else "second")
                if not guarded or "1" in gates[side]:
                    filtered += 1
        output.append(f"{label} gates={gates[0]},{gates[1]} "
                      f"raw={raw[0]},{raw[1]} hit={filtered}")
    return "\n".join(output) + "\n"


def make_case(row: Row) -> Case:
    join, _, edge, filter_, guard, update = row
    name = case_name(row)
    gate_type = "logic [32:0]" if guard == "mixed" else "logic"
    terms = []
    for side, suffix in enumerate(("a", "b")):
        term = "event_" + suffix if named(row, side) else (
            (edge + " " if edge != "change" else "") + "signal_" + suffix)
        terms.append(term)
    qualified = [term + (" iff gate_" + suffix if filter_ in ("both", where) else "")
                 for term, suffix, where in zip(terms, ("a", "b"), ("first", "second"))]
    separator = " or " if join == "or" else ", "
    lines = ["`timescale 1ns/1ns", f"module {name};",
             "  bit signal_a = 0, signal_b = 0;", "  event event_a, event_b;",
             f"  {gate_type} gate_a = '0, gate_b = '0;",
             "  int raw_a = 0, raw_b = 0, hits = 0;",
             f"  always @({terms[0]}) raw_a = raw_a + 1;",
             f"  always @({terms[1]}) raw_b = raw_b + 1;",
             f"  always @({separator.join(qualified)}) hits = hits + 1;",
             "  initial begin", "    #1;", "    raw_a = 0; raw_b = 0; hits = 0;", "    #1;"]
    for label, kind, a, b in actions(row):
        if kind == "guards":
            lines += [f"    gate_a = {literal(a)};", f"    gate_b = {literal(b)};"]
        else:
            side = int(kind == "right")
            suffix = "b" if side else "a"
            if named(row, side):
                lines.append(f"    {'->>' if update == 'nba' else '->'} event_{suffix};")
            else:
                lines.append(f"    signal_{suffix} {'<=' if update == 'nba' else '='} 1'b{a};")
            lines += [f'    $display("{label}_scheduled=%b,%b", signal_a, signal_b);']
        lines += ["    #1;", f'    $display("{label} gates=%b,%b raw=%0d,%0d hit=%0d",',
                  "             gate_a, gate_b, raw_a, raw_b, hits);"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Event OR applies iff to each selected term and ignores guard-only changes",
        "9.4.2.1 9.4.2.3 9.4.2 12.4 15.5.1 " +
        ("10.4.2" if update == "nba" else "10.4.1"),
        "Unparenthesized or/comma terms have a guard on the first, second or both "
        "terms. Independent raw counters identify each source event. Guard-only "
        "changes precede distinct left/right rising and falling changes and a "
        "repeated left trigger; every action settles for a tick before counts are "
        "read. A repeated value is silent for a signal but retriggers a named event. "
        "Every row includes zero/one guards; X/Z guards are false unless a wide "
        "guard also has a known one. Immediate signal values identify blocking "
        "versus NBA capture; event counts are only read after settling. Sources "
        "never fire together, so no coalescing or process ordering is assumed.",
        "\n".join(lines), reference(row), fourstate=guard != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

"""Cross event expression changes, edge classification and typed updates.

9.4.2 applies posedge/negedge only to an expression's least significant
bit, while a non-edge event detects any change of its complete value.
Both constant backgrounds run inside every case. Setup changes settle
before counters clear; only next-time counts are observed, without races.
"""

from common import Case
from interaction_bits import two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_edge"
VERSION = 1
CHAPTER = 9

MODEL = Model(
    "edge_event_expression",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")),
     ("expression", ("vector", "lsb", "msb", "reduce_or")),
     ("position", ("low", "middle", "high")),
     ("before", ("0", "1", "x", "z")), ("after", ("0", "1", "x", "z")),
     ("update", ("blocking", "nba"))),
    lambda r: r[0] != "1" or r[3] == "low",
    groups=(("expression", "before", "after"), ("state", "before", "after"),
            ("width", "position", "state"), ("expression", "position", "update")),
    anchors=(("129", "logic", "vector", "high", "x", "z", "nba"),
             ("65", "logic", "msb", "high", "x", "1", "blocking"),
             ("33", "bit", "lsb", "low", "z", "1", "nba"),
             ("1", "logic", "vector", "low", "0", "z", "nba"),
             ("64", "logic", "reduce_or", "middle", "0", "1", "blocking")),
    constraints=("幅1の注目位置はlowに統一。各行で背景0/1、既知0→1と指定遷移を観測。"
                 "全体／LSB／MSB／OR式を対象に、posedge・negedge・非エッジの変化を同時に測る。"
                 "初期設定を収束させてカウンタをクリアし、更新の次時刻に計数。"
                 "イベントOR・iff・複数更新・グリッチ・複数クロックは対象外",),
)


def case_name(row: Row) -> str:
    w, state, shape, position, before, after, update = row
    return (f"test_gen_cross_edge_w{w}_{state[0]}_{shape}_{position}_"
            f"{before}{after}_{update[0]}")


def source_bits(row: Row, background: int, *, baseline: bool = False) -> tuple[str, str]:
    w, _, _, position, before, after, _ = row
    w = int(w)
    pos = {"low": 0, "middle": w // 2, "high": w - 1}[position]
    if baseline:
        before, after = "0", "1"
    a, b = [str(background)] * w, [str(background)] * w
    a[w - 1 - pos], b[w - 1 - pos] = before, after
    return "".join(a), "".join(b)


def expression_bits(bits: str, shape: str) -> str:
    if shape == "vector":
        return bits
    if shape == "lsb":
        return bits[-1]
    if shape == "msb":
        return bits[0]
    return "1" if "1" in bits else "x" if any(c in "xz" for c in bits) else "0"


def events(before: str, after: str) -> tuple[int, int, int]:
    """Posedge, negedge and complete-expression change from Table 9-2."""
    a, b = before[-1], after[-1]
    pos = (a == "0" and b in "1xz") or (a in "xz" and b == "1")
    neg = (a == "1" and b in "0xz") or (a in "xz" and b == "0")
    return int(pos), int(neg), int(before != after)


def reference(row: Row, background: int, *, baseline: bool = False) -> tuple:
    """Raw pair, stored pair, expression pair and expected three counters."""
    raw_before, raw_after = source_bits(row, background, baseline=baseline)
    before, after = (two_state(raw_before), two_state(raw_after)) if row[1] == "bit" \
        else (raw_before, raw_after)
    expr_before, expr_after = expression_bits(before, row[2]), expression_bits(after, row[2])
    return (raw_before, raw_after, before, after, expr_before, expr_after,
            events(expr_before, expr_after))


def make_case(row: Row) -> Case:
    width, state, shape, _, before, after, update = row
    w = int(width)
    expr = {"vector": "source", "lsb": "source[0]", "msb": f"source[{w - 1}]",
            "reduce_or": "(|source)"}[shape]
    op = "<=" if update == "nba" else "="
    name = case_name(row)
    lines = ["`timescale 1ns/1ns", f"module {name};", f"  {state} [{w - 1}:0] source;",
             f"  logic [{w - 1}:0] raw_before, raw_after;",
             "  integer pos_count, neg_count, change_count;",
             f"  always @(posedge {expr}) pos_count = pos_count + 1;",
             f"  always @(negedge {expr}) neg_count = neg_count + 1;",
             f"  always @({expr}) change_count = change_count + 1;",
             "  initial begin", "    pos_count = 0;", "    neg_count = 0;", "    change_count = 0;"]
    expected = []
    stimuli = (("p", False),) if (before, after) == ("0", "1") \
        else (("k", True), ("p", False))
    for background in (0, 1):
        for prefix, baseline in stimuli:
            ra, rb, a, b, ea, eb, counts = reference(row, background, baseline=baseline)
            label = f"b{background}_{prefix}"
            immediate = a if update == "nba" else b
            lines += [f"    raw_before = {literal(ra)};", f"    raw_after = {literal(rb)};",
                      "    source = raw_before;", "    #1;",
                      "    pos_count = 0;", "    neg_count = 0;", "    change_count = 0;", "    #1;",
                      f'    $display("{label}_input=%b %b source=%b expr=%b",',
                      f"             raw_before, raw_after, source, {expr});",
                      f"    source {op} raw_after;",
                      f'    $display("{label}_scheduled=%b", source);', "    #1;",
                      f'    $display("{label}_final=%b expr=%b pos=%0d neg=%0d change=%0d",',
                      f"             source, {expr}, pos_count, neg_count, change_count);"]
            expected += [f"{label}_input={ra} {rb} source={a} expr={ea}",
                         f"{label}_scheduled={immediate}",
                         f"{label}_final={b} expr={eb} pos={counts[0]} neg={counts[1]} change={counts[2]}"]
    lines += ["    $finish;", "  end", "endmodule"]
    clauses = "9.4.2 6.11.2 " + ("10.4.2" if update == "nba" else "10.4.1")
    clauses += " 11.4.9" if shape == "reduce_or" else " 11.5.1" if shape in ("lsb", "msb") else ""
    return Case(
        name, "Event controls classify typed X/Z transitions and observe only expression changes",
        clauses,
        "One source bit changes among 0/1/X/Z against both all-zero and all-one backgrounds. "
        "Every case includes a known zero-to-one transition, then its selected transition. "
        "Two-state conversion happens before event expression evaluation. Posedge and "
        "negedge inspect only the expression LSB; non-edge controls inspect its full value. "
        "An unchanged selected bit or reduction result causes no event even when another "
        "source bit changes. Setup settles for a tick before all three counters clear. "
        "A further tick separates reset from the target update. Immediate source output "
        "distinguishes blocking from NBA; counters are observed only on the next tick "
        "after updates and event processes settle. No interprocess execution order is assumed.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=before in "xz" or after in "xz",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

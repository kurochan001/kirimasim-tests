"""Cross shift rules with assignment context and four-state conversion.

11.4.10 and 11.8 evaluate the context-sized left operand before shifting.
The count is self-determined and cannot change the expression's sign.
The oracle moves character positions, including X/Z, rather than calling
a simulator. Unknown counts produce X before any 2-state assignment.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal  # Rendering only; no conditional oracle is used.
from interaction_cover import Model, Row

NAME = "interaction_shift"
VERSION = 1
CHAPTER = 11
OPS = {"shl": "<<", "shr": ">>", "ashl": "<<<", "ashr": ">>>"}


def legal(row: Row) -> bool:
    return row[0] != "1" or (row[3] not in ("one", "last") and row[5] != "narrow")


MODEL = Model(
    "shift_context",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("sign", ("unsigned", "signed")), ("operator", tuple(OPS)),
     ("count", ("zero", "one", "last", "width", "beyond", "x", "z")),
     ("value", ("known", "x", "z")), ("result_width", ("narrow", "same", "wide")),
     ("state", ("bit", "logic"))),
    legal,
    groups=(("operator", "count", "sign"), ("width", "value", "state")),
    anchors=(("65", "signed", "ashr", "width", "z", "wide", "logic"),
             ("129", "unsigned", "shl", "one", "x", "narrow", "bit"),
             ("33", "signed", "shr", "width", "known", "wide", "logic"),
             ("64", "signed", "ashr", "beyond", "known", "narrow", "logic")),
    constraints=("幅1のnarrowは幅0のため除外。幅1で数値が重複するone/lastは"
                 "width/zeroへ統合。countのwidth/last/beyondは元の左オペランド幅を基準とする",),
)


def case_name(row: Row) -> str:
    w, sign, op, count, value, result, state = row
    return f"test_gen_cross_shift_w{w}_{sign[0]}_{op}_{count}_{value[0]}_{result[0]}_{state[0]}"


def count_value(width: int, count: str) -> int | None:
    return {"zero": 0, "one": 1, "last": width - 1, "width": width,
            "beyond": width + 1, "x": None, "z": None}[count]


def reference(row: Row) -> tuple[str, str, str]:
    w, sign, op, count, value, relation, state = row
    w = int(w)
    wr = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    n = max(w, wr)
    source = pattern(w, value)
    operand = resize(source, n, sign == "signed")
    k = count_value(w, count)
    count_bits = count * 32 if k is None else f"{k:032b}"
    if k is None:
        result = "x" * n
    elif op in ("shl", "ashl"):
        result = operand[k:] + "0" * k if k < n else "0" * n
    else:
        fill = operand[0] if op == "ashr" and sign == "signed" else "0"
        result = fill * k + operand[:n - k] if k < n else fill * n
    result = result[-wr:]
    return source, count_bits, two_state(result) if state == "bit" else result


def make_case(row: Row) -> Case:
    w, sign, op, count, value, relation, state = row
    w = int(w)
    wr = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    source, count_bits, result = reference(row)
    name = case_name(row)
    k = count_value(w, count)
    count_literal = f"'{count}" if k is None else str(k)
    lines = [f"module {name};", f"  logic {sign} [{w - 1}:0] source;",
             "  logic [31:0] count;", f"  {state} [{wr - 1}:0] result;", "  initial begin",
             f"    source = {literal(source)};", f"    count = {count_literal};",
             f"    result = source {OPS[op]} count;",
             '    $display("source=%b count=%b", source, count);',
             '    $display("result=%b", result);', "    $finish;", "  end", "endmodule"]
    return Case(
        name, "Shift count, sign, assignment width and four-state conversion interact correctly",
        "11.4.10 11.6.1 11.8.1 11.8.2 6.11.2",
        "The destination contributes to the left operand width before shifting. Counts "
        "near the original width can therefore differ from counts near the evaluation "
        "width. The count is unsigned and does not change signedness. Arithmetic right "
        "shift copies the sign bit, including X/Z; logical shifts fill with zero. An "
        "unknown count gives all X, followed by truncation and any bit conversion.",
        "\n".join(lines), f"source={source} count={count_bits}\nresult={result}\n",
        fourstate=value != "known" or count in ("x", "z"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

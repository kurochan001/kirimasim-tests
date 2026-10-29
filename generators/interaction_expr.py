"""Cross assignment context, operand widths, signedness and arithmetic.

The oracle follows 1800-2023 11.6.1 and 11.8.1/2 using Python integers.
Operands extend to max(lhs, rhs, destination); both must be signed for
sign extension. Arithmetic wraps there, then truncates to the destination.
Four deterministic input pairs expose negative values, carries and top bits.
"""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_expr"
VERSION = 1
CHAPTER = 11
WIDTHS = ("1", "32", "33", "64", "65", "129")
RELATIONS = ("narrow", "same", "wide")


def width(base: int, relation: str) -> int:
    return base + {"narrow": -1, "same": 0, "wide": 1}[relation]


MODEL = Model(
    "expression_context",
    (("width", WIDTHS), ("rhs_width", RELATIONS), ("result_width", RELATIONS),
     ("sign_a", ("unsigned", "signed")), ("sign_b", ("unsigned", "signed")),
     ("operator", ("add", "sub", "mul"))),
    lambda r: r[0] != "1" or "narrow" not in r[1:3],
    groups=(("width", "result_width", "operator"), ("sign_a", "sign_b", "operator")),
    anchors=(("129", "narrow", "wide", "signed", "signed", "mul"),
             ("65", "wide", "narrow", "signed", "unsigned", "add"),
             ("33", "same", "wide", "unsigned", "signed", "sub")),
    constraints=("幅1に対するnarrowは幅0になるため除外。幅の差は1ビット",),
)


def case_name(row: Row) -> str:
    w, rhs, result, sa, sb, op = row
    return f"test_gen_cross_expr_w{w}_{rhs[0]}_{result[0]}_{sa[0]}{sb[0]}_{op}"


def vectors(wa: int, wb: int) -> tuple[tuple[int, int], ...]:
    ma, mb = (1 << wa) - 1, (1 << wb) - 1
    return ((ma, 1), (1 << (wa - 1), mb), (ma >> 1, mb >> 1), (1, mb))


def reference(row: Row, a: int, b: int) -> int:
    w, rb, rr, sa, sb, op = row
    wa = int(w)
    wb, wr = width(wa, rb), width(wa, rr)
    n = max(wa, wb, wr)
    if sa == sb == "signed":
        a -= (1 << wa) if a & (1 << (wa - 1)) else 0
        b -= (1 << wb) if b & (1 << (wb - 1)) else 0
    result = {"add": lambda: a + b, "sub": lambda: a - b, "mul": lambda: a * b}[op]()
    return (result & ((1 << n) - 1)) & ((1 << wr) - 1)


def make_case(row: Row) -> Case:
    w, rb, rr, sa, sb, op = row
    wa = int(w)
    wb, wr = width(wa, rb), width(wa, rr)
    name = case_name(row)
    symbol = {"add": "+", "sub": "-", "mul": "*"}[op]
    lines = [f"module {name};", f"  logic {sa} [{wa - 1}:0] a;",
             f"  logic {sb} [{wb - 1}:0] b;", f"  logic [{wr - 1}:0] result;",
             "  initial begin"]
    expected = []
    for i, (a, b) in enumerate(vectors(wa, wb)):
        lines += [f"    a = {wa}'h{a:x};", f"    b = {wb}'h{b:x};",
                  f"    result = a {symbol} b;", f'    $display("v{i}=%b", result);']
        expected.append(f"v{i}={reference(row, a, b):0{wr}b}")
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Arithmetic respects operand signs and assignment width across word boundaries",
        "11.6.1 11.8.1 11.8.2",
        "The RHS and destination widths differ by at most one bit from the left operand. "
        "Both operands must be signed for sign extension; a mixed pair extends with zeros. "
        "The destination contributes to the expression width before the operation. Four "
        "input pairs check negative operands, carries, high bits and final truncation. "
        "The Python oracle uses integers and masks, without a simulator.",
        "\n".join(lines), "\n".join(expected) + "\n",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

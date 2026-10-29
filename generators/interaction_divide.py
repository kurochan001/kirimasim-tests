"""Cross division and remainder with signedness, context and four-state values.

The reference uses integer magnitudes for division toward zero; Python's
floor division and remainder are not used for signed SystemVerilog results.
Both a natural-width intermediate and the directly assigned expression are
observed, so widening before division cannot be confused with later extension.
"""

from common import Case
from interaction_bits import resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row
from interaction_expr import width

NAME = "interaction_divide"
VERSION = 1
CHAPTER = 11
OPERATORS = {"div": "/", "mod": "%"}

MODEL = Model(
    "division_context",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("rhs_width", ("narrow", "same", "wide")),
     ("result_width", ("narrow", "same", "wide")),
     ("sign_a", ("unsigned", "signed")), ("sign_b", ("unsigned", "signed")),
     ("operator", tuple(OPERATORS)),
     ("value", ("known", "zero", "lhs_x", "lhs_z", "rhs_x", "rhs_z")),
     ("state", ("bit", "logic"))),
    lambda r: r[0] != "1" or "narrow" not in r[1:3],
    groups=(("width", "value", "state"), ("sign_a", "sign_b", "operator"),
            ("rhs_width", "result_width", "operator")),
    anchors=(("129", "same", "same", "signed", "signed", "div", "known", "logic"),
             ("65", "narrow", "wide", "signed", "unsigned", "mod", "known", "logic"),
             ("33", "wide", "narrow", "signed", "signed", "mod", "known", "bit"),
             ("32", "same", "wide", "signed", "signed", "div", "zero", "bit"),
             ("1", "same", "wide", "signed", "signed", "div", "known", "logic")),
    constraints=("幅1に対するnarrowは幅0になるため除外。両入力はlogicのパック整数。"
                 "stateは代入先の型で、演算後に2状態変換する。"
                 "全行で既知値4組を確認し、zero/X/Z行は同じ4組に指定値も適用する。"
                 "最小負値/-1と正負の商・剰余を確認。実数は対象外",),
)


def case_name(row: Row) -> str:
    w, rhs, result, sa, sb, op, value, state = row
    return (f"test_gen_cross_divide_w{w}_{rhs[0]}_{result[0]}_{sa[0]}{sb[0]}_"
            f"{op}_{value}_{state[0]}")


def inputs(row: Row, phase: int, *, baseline: bool = False) -> tuple[str, str]:
    w, rhs, _, _, _, _, value, _ = row
    wa, wb = int(w), width(int(w), rhs)
    a, b = ((1 << (wa - 1), -1), (-7, 3), (7, -3), (-7, -3))[phase]
    a = f"{a & ((1 << wa) - 1):0{wa}b}"
    b = f"{b & ((1 << wb) - 1):0{wb}b}"
    if baseline:
        return a, b
    if value == "zero":
        b = "0" * wb
    elif value.startswith("lhs_"):
        a = value[-1] + a[1:]
    elif value.startswith("rhs_"):
        b = value[-1] + b[1:]
    return a, b


def quotient_remainder(a: int, b: int) -> tuple[int, int]:
    """Signed integer division with truncation toward zero, without floats."""
    q = abs(a) // abs(b)
    if (a < 0) != (b < 0):
        q = -q
    return q, a - q * b


def reference(row: Row, a: str, b: str, context_width: int) -> str:
    _, _, _, sa, sb, op, _, _ = row
    signed = sa == sb == "signed"
    n = max(len(a), len(b), context_width)
    a, b = resize(a, n, signed), resize(b, n, signed)
    if any(c in "xz" for c in a + b) or int(b, 2) == 0:
        return "x" * context_width
    ai, bi = int(a, 2), int(b, 2)
    if signed:
        ai -= (1 << n) if a[0] == "1" else 0
        bi -= (1 << n) if b[0] == "1" else 0
    q, r = quotient_remainder(ai, bi)
    result = q if op == "div" else r
    return f"{result & ((1 << context_width) - 1):0{context_width}b}"


def make_case(row: Row) -> Case:
    w, rhs, result, sa, sb, op, value, state = row
    wa = int(w)
    wb, wr = width(wa, rhs), width(wa, result)
    natural = max(wa, wb)
    name = case_name(row)
    expr = f"a {OPERATORS[op]} b"
    lines = [f"module {name};", f"  logic {sa} [{wa - 1}:0] a;",
             f"  logic {sb} [{wb - 1}:0] b;", f"  logic [{natural - 1}:0] raw;",
             f"  {state} [{wr - 1}:0] result;", "  initial begin"]
    expected = []
    stimuli = (("p", False),) if value == "known" else (("k", True), ("p", False))
    for prefix, baseline in stimuli:
        for phase in range(4):
            a, b = inputs(row, phase, baseline=baseline)
            raw = reference(row, a, b, natural)
            final = reference(row, a, b, wr)
            if state == "bit":
                final = two_state(final)
            label = f"{prefix}{phase}"
            lines += [f"    a = {literal(a)};", f"    b = {literal(b)};",
                      f"    raw = {expr};", f"    result = {expr};",
                      f'    $display("{label}_inputs=%b %b", a, b);',
                      f'    $display("{label}_result=%b direct=%b bits=%0d",',
                      f"             raw, result, $bits({expr}));"]
            expected += [f"{label}_inputs={a} {b}",
                         f"{label}_result={raw} direct={final} bits={natural}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Division and remainder honor signed operands and assignment context before conversion",
        "11.4.3 11.6.1 11.8.1 11.8.2 6.11.2",
        "Every case observes four known input pairs before any selected zero or X/Z "
        "perturbation, keeping sign and context effects visible even in unknown-value "
        "rows. The pairs include the minimum signed numerator divided by minus one, "
        "negative and positive numerators, and positive and negative divisors. Values "
        "are first stored at their declared operand widths. Both operands must be "
        "signed for sign extension; a mixed pair zero-extends before arithmetic. "
        "The independent integer reference truncates the quotient toward zero and "
        "computes the remainder as a minus quotient times b. Natural-width and direct "
        "assignment results are separate observations. Zero divisors and any X/Z "
        "operand produce all X, converted to zero only on storage into bit.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

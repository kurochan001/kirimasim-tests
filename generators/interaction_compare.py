"""Cross four-state comparisons with operand width, sign and result context.

11.4.4/5/6 extend operands using their joint signedness. Relational
operators reject any unknown bit; equality can resolve a known mismatch.
Only the right operand supplies wildcard bits. Every result is unsigned
and one bit, independent of the wider destination receiving it.
"""

from common import Case
from interaction_bits import resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row
from interaction_expr import vectors, width

NAME = "interaction_compare"
VERSION = 1
CHAPTER = 11
OPERATORS = {"lt": "<", "le": "<=", "gt": ">", "ge": ">=", "eq": "==", "ne": "!=",
             "ceq": "===", "cne": "!==", "weq": "==?", "wne": "!=?"}

MODEL = Model(
    "comparison_context",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("rhs_width", ("narrow", "same", "wide")),
     ("sign_a", ("unsigned", "signed")), ("sign_b", ("unsigned", "signed")),
     ("operator", tuple(OPERATORS)),
     ("value", ("known", "lhs_x", "rhs_x", "rhs_z", "both_unknown"))),
    lambda r: r[0] != "1" or r[1] != "narrow",
    groups=(("operator", "value", "sign_b"), ("width", "rhs_width", "sign_a"),
            ("sign_a", "sign_b", "operator")),
    anchors=(("129", "narrow", "signed", "unsigned", "weq", "rhs_z"),
             ("65", "wide", "signed", "signed", "eq", "both_unknown"),
             ("33", "wide", "unsigned", "signed", "ge", "known"),
             ("1", "same", "signed", "signed", "ceq", "both_unknown")),
    constraints=("幅1に対するnarrowは幅0になるため除外。比較対象はパック整数。"
                 "4組の入力を使い、both_unknownはX/X・Z/Z・X/Z・Z/Xを先頭ビットへ置く",),
)


def case_name(row: Row) -> str:
    w, rhs, sa, sb, op, value = row
    return f"test_gen_cross_compare_w{w}_{rhs[0]}_{sa[0]}{sb[0]}_{op}_{value}"


def inputs(row: Row, phase: int) -> tuple[str, str]:
    w, rhs, _, _, _, value = row
    wa, wb = int(w), width(int(w), rhs)
    a, b = vectors(wa, wb)[phase]
    a, b = f"{a:0{wa}b}", f"{b:0{wb}b}"
    if value == "lhs_x":
        a = "x" + a[1:]
    elif value in ("rhs_x", "rhs_z"):
        b = value[-1] + b[1:]
    elif value == "both_unknown":
        ca, cb = ("xx", "zz", "xz", "zx")[phase]
        a, b = ca + a[1:], cb + b[1:]
    return a, b


def compare(a: str, b: str, sa: str, sb: str, op: str) -> str:
    signed = sa == sb == "signed"
    n = max(len(a), len(b))
    a, b = resize(a, n, signed), resize(b, n, signed)
    if op in ("lt", "le", "gt", "ge"):
        if any(c in "xz" for c in a + b):
            return "x"
        ai, bi = int(a, 2), int(b, 2)
        if signed:
            ai -= (1 << n) if a[0] == "1" else 0
            bi -= (1 << n) if b[0] == "1" else 0
        return str(int({"lt": ai < bi, "le": ai <= bi, "gt": ai > bi, "ge": ai >= bi}[op]))
    if op in ("ceq", "cne"):
        equal = str(int(a == b))
    else:
        pairs = [(x, y) for x, y in zip(a, b) if not (op in ("weq", "wne") and y in "xz")]
        if any(x in "01" and y in "01" and x != y for x, y in pairs):
            equal = "0"
        elif any(x in "xz" or y in "xz" for x, y in pairs):
            equal = "x"
        else:
            equal = "1"
    return equal if op in ("eq", "ceq", "weq") or equal == "x" else str(1 - int(equal))


def make_case(row: Row) -> Case:
    w, rhs, sa, sb, op, value = row
    wa, wb = int(w), width(int(w), rhs)
    name = case_name(row)
    expr = "a " + OPERATORS[op] + " b"
    lines = [f"module {name};", f"  logic {sa} [{wa - 1}:0] a;",
             f"  logic {sb} [{wb - 1}:0] b;", "  logic raw;",
             "  logic [6:0] wide;", "  bit [6:0] binary;", "  initial begin"]
    expected = []
    for phase in range(4):
        a, b = inputs(row, phase)
        result = compare(a, b, sa, sb, op)
        lines += [f"    a = {literal(a)};", f"    b = {literal(b)};",
                  f"    raw = {expr};", f"    wide = {expr};", f"    binary = {expr};",
                  f'    $display("p{phase}_inputs=%b %b", a, b);',
                  f'    $display("p{phase}_result=%b wide=%b binary=%b bits=%0d",',
                  f"             raw, wide, binary, $bits({expr}));"]
        expected += [f"p{phase}_inputs={a} {b}",
                     f"p{phase}_result={result} wide=000000{result} "
                     f"binary=000000{two_state(result)} bits=1"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Comparisons extend operands and preserve one-bit results before destination conversion",
        "11.4.4 11.4.5 11.4.6 11.6.1 11.8.2 6.11.2",
        "Four input pairs expose negative values, top bits, equal lower bits and mismatches. "
        "Both signed operands sign-extend; otherwise both zero-extend. A relational result "
        "is X for any X/Z operand. Logical equality resolves a known differing bit before "
        "unknown bits; case equality compares all four states. Wildcards come only from "
        "the right operand. The unsigned one-bit result zero-extends into a wider logic "
        "destination, with X converted only on storage into bit. Operand values, direct "
        "results and result widths are all observed.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

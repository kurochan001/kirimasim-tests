"""Cross integral value ranges in inside with bound types, forms and unknowns.

11.4.13 matches a range when the left operand lies inclusively between its
bounds, compared with the relational operators (11.4.4), while a set value
is compared with ==? (11.4.6). A $ bound stands for the lowest or highest
value of the left operand's type, and a range whose left bound is greater
than its right bound is empty. [A +/- B] and [A +%- B] are ranges of the type
of A: A minus and plus B, or A's percentage B truncated toward zero, with the
two bounds swapped when needed. Every set member and bound has one type, so
each comparison has the same joint width and signedness (11.8.2).
"""

from fractions import Fraction

from common import Case
from interaction_bits import resize, two_state
from interaction_compare import compare
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_range"
VERSION = 1
CHAPTER = 11
FORMS = ("closed", "reversed", "low_open", "high_open", "abs_tol", "rel_tol")
SOURCE = {"closed": "[lo:hi]", "reversed": "[lo:hi]", "low_open": "[$:hi]",
          "high_open": "[lo:$]", "abs_tol": "[a +/- b]", "rel_tol": "[a +%- b]"}
# The bound that carries an unknown bit, and the member of a mixed set that
# repeats it as a plain value.
CARRIER = {"closed": "lo", "reversed": "lo", "low_open": "hi", "high_open": "lo",
           "abs_tol": "a", "rel_tol": "a"}


def legal(row: Row) -> bool:
    w, relation, _, _, _, form, value, _ = row
    if w == "1" and relation == "narrow":
        return False
    if form == "reversed":
        return w != "1" and value == "known"
    return True


MODEL = Model(
    "membership_range",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("needle_width", ("narrow", "same", "wide")),
     ("needle_sign", ("unsigned", "signed")), ("bound_sign", ("unsigned", "signed")),
     ("bound_state", ("bit", "logic")),
     ("form", FORMS),
     ("value", ("known", "lhs_x", "bound_x", "bound_z")),
     ("members", ("single", "mixed"))),
    legal,
    groups=(("width", "needle_width", "needle_sign"),
            ("needle_sign", "bound_sign", "form"),
            ("bound_state", "value", "form"),
            ("form", "value", "members"),
            ("needle_width", "bound_sign", "form")),
    anchors=(("33", "wide", "unsigned", "signed", "logic", "closed", "known", "single"),
             ("129", "wide", "unsigned", "signed", "bit", "abs_tol", "known", "single"),
             ("65", "narrow", "signed", "signed", "logic", "rel_tol", "known", "single"),
             ("64", "same", "signed", "unsigned", "logic", "closed", "bound_x", "mixed"),
             ("32", "same", "unsigned", "unsigned", "logic", "reversed", "known", "mixed"),
             ("1", "wide", "signed", "signed", "logic", "low_open", "lhs_x", "single")),
    constraints=("幅1のnarrowは幅0になるため除外。逆順の範囲は、符号の解釈によらず"
                 "左端が大きい正の2値（3と1）で表すため幅1を除き、X/Zを含む空の範囲の"
                 "扱いは本文が定めないので既知値だけにする。全端点と集合要素は同じ型・幅で、"
                 "許容差は型の範囲を超えない値に限る。閉区間の端点X/Zでは、もう一方の端点を"
                 "満たす入力だけを使う。非整数、異種の集合要素、副作用付き式は対象外",),
)


def case_name(row: Row) -> str:
    w, relation, ns, bs, state, form, value, members = row
    return (f"test_gen_cross_range_w{w}_{relation[0]}_{ns[0]}{bs[0]}_{state[0]}_"
            f"{form}_{value}_{members[0]}")


def widths(row: Row) -> tuple[int, int]:
    """Return the needle width and the width of every bound and member."""
    right = int(row[0])
    return right + {"narrow": -1, "same": 0, "wide": 1}[row[1]], right


def word(value: int, width: int) -> str:
    return f"{value & ((1 << width) - 1):0{width}b}"


def number(bits: str, signed: bool) -> int:
    value = int(bits, 2)
    return value - (1 << len(bits)) if signed and bits[0] == "1" else value


def operands(row: Row) -> dict[str, str]:
    """Return the known bounds as written, before any unknown bit is placed."""
    wb, signed, form = int(row[0]), row[3] == "signed", row[5]
    if wb == 1:
        low = high = "1"
    else:
        low, high = "1" + "0" * (wb - 2) + "1", "1" * (wb - 1) + "0"
    if form == "closed":
        return {"lo": low, "hi": high}
    if form == "reversed":
        return {"lo": word(3, wb), "hi": word(1, wb)}
    if form == "low_open":
        return {"hi": high}
    if form == "high_open":
        return {"lo": low}
    if wb == 1:
        return {"a": "1", "b": "0"}
    if form == "abs_tol":
        return {"a": word(-4, wb), "b": word(-2 if signed else 2, wb)}
    return {"a": word(-30 if signed else 30, wb), "b": word(15, wb)}


def with_unknown(row: Row, ops: dict[str, str]) -> dict[str, str]:
    value, carrier = row[6], CARRIER[row[5]]
    if value not in ("bound_x", "bound_z"):
        return dict(ops)
    bits = ops[carrier]
    i = bits.rindex("1")
    return {**ops, carrier: bits[:i] + value[-1] + bits[i + 1:]}


def tolerance_bounds(row: Row, a: str, b: str) -> tuple[str, str]:
    """Return the bounds of a tolerance range in A's type, low bound first."""
    wb, signed = int(row[0]), row[3] == "signed"
    if any(c in "xz" for c in a + b):
        return "x" * wb, "x" * wb
    av, bv = number(a, signed), number(b, signed)
    if row[5] == "abs_tol":
        delta = bv
    else:
        # Exact arithmetic, then truncation toward zero of the tolerance.
        exact = Fraction(av * bv, 100)
        delta = int(exact) if exact >= 0 else -int(-exact)
    low, high = sorted((av - delta, av + delta))
    least, most = (-(1 << (wb - 1)), (1 << (wb - 1)) - 1) if signed else (0, (1 << wb) - 1)
    if not least <= low <= high <= most:
        raise ValueError("a tolerance range in this model stays within A's type")
    return word(low, wb), word(high, wb)


def both(left: str, right: str) -> str:
    return "0" if "0" in (left, right) else "x" if "x" in (left, right) else "1"


def range_result(row: Row, needle: str, stored: dict[str, str]) -> str:
    ns, bs, form = row[2], row[3], row[5]
    unknown = "x" if any(c in "xz" for c in needle) else "1"
    if form in ("abs_tol", "rel_tol"):
        low, high = tolerance_bounds(row, stored["a"], stored["b"])
        return both(compare(needle, low, ns, bs, "ge"), compare(needle, high, ns, bs, "le"))
    above = compare(needle, stored["lo"], ns, bs, "ge") if "lo" in stored else unknown
    below = compare(needle, stored["hi"], ns, bs, "le") if "hi" in stored else unknown
    return both(above, below)


def needles(row: Row) -> list[str]:
    """Return four known needles near the bounds, in the needle's width."""
    wa, wb = widths(row)
    ns, bs, form, value = row[2] == "signed", row[3] == "signed", row[5], row[6]
    ops = operands(row)
    if form in ("abs_tol", "rel_tol"):
        low, high = tolerance_bounds(row, ops["a"], ops["b"])
    else:
        low = ops.get("lo", "1" + "0" * (wa - 1) if ns else "0" * wa)
        high = ops.get("hi", "0" + "1" * (wa - 1) if ns else "1" * wa)
    # The bounds as the comparison extends them match; extended by their own
    # sign instead, they are the needles that a sign-extending error accepts.
    common = ns and bs
    step = lambda bits, d: word(int(bits, 2) + d, wa)
    low_joint, high_joint = resize(low, wa, common), resize(high, wa, common)
    candidates = [low_joint, high_joint, resize(low, wa, bs), resize(high, wa, bs),
                  step(low_joint, -1), "1" * wa, "0" * wa, step(high_joint, 1), word(1, wa)]
    if form == "closed" and value in ("bound_x", "bound_z") and row[4] == "logic":
        # An unknown low bound leaves the result open only when the other
        # bound holds, under either reading of a range with one unknown side.
        candidates = [c for c in candidates
                      if compare(c, ops["hi"], row[2], row[3], "le") == "1"]
    distinct = list(dict.fromkeys(candidates))
    if not distinct:
        raise ValueError("no needle satisfies the known bound of " + case_name(row))
    # A one-bit needle has only two values, so its phases repeat them.
    return [distinct[i % len(distinct)] for i in range(4)]


def phase_inputs(row: Row, phase: int) -> tuple[str, dict[str, str], dict[str, str]]:
    """Return the needle, the bounds as supplied, and the bounds as stored."""
    needle = needles(row)[phase]
    if row[6] == "lhs_x":
        needle = needle[:-1] + "x"
    supplied = with_unknown(row, operands(row))
    stored = {k: two_state(v) if row[4] == "bit" else v for k, v in supplied.items()}
    return needle, supplied, stored


def membership(row: Row, needle: str, stored: dict[str, str]) -> str:
    results = [range_result(row, needle, stored)]
    if row[7] == "mixed":
        top = "1" * int(row[0])
        results += [compare(needle, stored[CARRIER[row[5]]], row[2], row[3], "weq"),
                    compare(needle, top, row[2], row[3], "weq")]
    return "1" if "1" in results else "x" if "x" in results else "0"


def relation_source(form: str) -> str | None:
    return {"closed": "(needle >= lo) && (needle <= hi)",
            "reversed": "(needle >= lo) && (needle <= hi)",
            "low_open": "needle <= hi", "high_open": "needle >= lo"}.get(form)


def make_case(row: Row) -> Case:
    _, _, ns, bs, state, form, value, members = row
    wa, wb = widths(row)
    name = case_name(row)
    names = list(operands(row))
    carrier = CARRIER[form]
    set_items = SOURCE[form] + (f", {carrier}, top" if members == "mixed" else "")
    expression = "needle inside {" + set_items + "}"
    relation = relation_source(form)
    lines = [f"module {name};", f"  typedef {state} {bs} [{wb-1}:0] word_t;",
             f"  logic {ns} [{wa-1}:0] needle;"]
    lines += [f"  logic [{wb-1}:0] {n}_given;" for n in names]
    lines += [f"  word_t {', '.join(names)};"]
    if members == "mixed":
        lines += ["  word_t top;"]
    lines += ["  logic raw, related;", "  logic [6:0] wide;", "  bit [6:0] binary;",
              "  initial begin"]
    if members == "mixed":
        lines += [f"    top = {literal('1' * wb)};"]
    expected = []
    for phase in range(4):
        needle, supplied, stored = phase_inputs(row, phase)
        result = membership(row, needle, stored)
        lines += [f"    needle = {literal(needle)};"]
        for n in names:
            lines += [f"    {n}_given = {literal(supplied[n])};", f"    {n} = {n}_given;"]
        lines += [f'    $display("p{phase} needle=%b", needle);']
        expected += [f"p{phase} needle={needle}"]
        for n in names:
            lines += [f'    $display("p{phase} {n} given=%b stored=%b", {n}_given, {n});']
            expected += [f"p{phase} {n} given={supplied[n]} stored={stored[n]}"]
        if members == "mixed":
            lines += [f'    $display("p{phase} top=%b", top);']
            expected += [f"p{phase} top={'1' * wb}"]
        lines += [f"    raw = {expression};", f"    wide = {expression};",
                  f"    binary = {expression};",
                  f'    $display("p{phase} raw=%b wide=%b binary=%b bits=%0d",',
                  f"             raw, wide, binary, $bits({expression}));"]
        expected += [f"p{phase} raw={result} wide=000000{result} "
                     f"binary=000000{two_state(result)} bits=1"]
        if relation:
            lines += [f"    related = {relation};", f'    $display("p{phase} relation=%b", related);']
            expected += [f"p{phase} relation={range_result(row, needle, stored)}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Inside value ranges combine bound forms, widths, signs, unknowns and set members",
        "11.4.13 11.4.4 11.4.6 11.8.1 11.8.2 6.11.2",
        "Four known needles sit at and next to the bounds of one range, in the needle's own "
        "width. Every bound has one type, so the needle and a bound are compared at their "
        "joint width and signedness, and an unsigned side zero-extends a signed bound. A $ "
        "bound leaves that side open for the needle's type. A reversed range of the positive "
        "values 3 and 1 is empty under any sign. A tolerance range has A's type, so a negative "
        "signed B or a negative A swaps its bounds, and a relative tolerance is truncated "
        "toward zero. An unknown bound bit makes its comparison X; for a closed range the "
        "needles then satisfy the known bound. Bit storage turns given X/Z bits into zero "
        "first. A mixed set repeats the bound that carries the unknown as a plain value, "
        "where ==? treats X/Z as a wildcard, and adds all ones, so a match outweighs an "
        "unknown range. The raw, widened and two-state results, the one-bit width and, for "
        "colon ranges, the same bounds written as relational operators are observed. "
        "Nonintegral and mixed-type members, side effects and evaluation order are outside "
        "this finite model.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

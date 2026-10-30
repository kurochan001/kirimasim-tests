"""Cross integral membership with typed set storage and array traversal.

11.4.13 flattens unpacked-array members and ORs their comparisons. Integral
members use right-sided wildcard equality (11.4.6). All RHS elements have
one type, so each comparison has the same joint width and signedness.
"""

from common import Case
from interaction_compare import compare
from interaction_cond import literal
from interaction_cover import Model, Row
from interaction_bits import two_state

NAME = "interaction_inside"
VERSION = 1
CHAPTER = 11


def legal(row: Row) -> bool:
    w, relation, _, _, _, container, size, value = row
    if w == "1" and relation == "narrow":
        return False
    if size == "0":
        return container in ("dynamic", "queue") and value in ("known", "lhs_x")
    return True


MODEL = Model(
    "membership_container",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("needle_width", ("narrow", "same", "wide")),
     ("needle_sign", ("unsigned", "signed")), ("set_sign", ("unsigned", "signed")),
     ("set_state", ("bit", "logic")),
     ("container", ("list", "fixed", "dynamic", "queue")),
     ("size", ("0", "1", "3")),
     ("value", ("known", "lhs_x", "rhs_x", "rhs_z", "both_unknown"))),
    legal,
    groups=(("width", "needle_width", "needle_sign"),
            ("set_state", "value", "container"),
            ("needle_sign", "set_sign", "value"),
            ("size", "container", "value"),
            ("needle_width", "size", "value")),
    anchors=(("129", "wide", "signed", "signed", "logic", "dynamic", "3", "both_unknown"),
             ("65", "narrow", "signed", "unsigned", "bit", "queue", "1", "rhs_z"),
             ("33", "wide", "unsigned", "signed", "logic", "fixed", "3", "rhs_x"),
             ("1", "same", "signed", "signed", "logic", "queue", "0", "lhs_x"),
             ("33", "same", "unsigned", "unsigned", "logic", "list", "3", "both_unknown")),
    constraints=("幅1のnarrowは幅0になるため除外。空集合は動的配列・キューだけで表し、"
                 "空の個別列挙や0要素の固定配列は作らない。空集合にはRHSの値がないため"
                 "known/lhs_xだけを残す。集合の全要素は同じ型・幅。範囲、非整数、異種の"
                 "集合要素、入れ子配列、副作用付き式と走査順の観測は対象外",),
)


def case_name(row: Row) -> str:
    w, relation, ns, ss, state, container, size, value = row
    return (f"test_gen_cross_inside_w{w}_{relation[0]}_{ns[0]}{ss[0]}_{state[0]}_"
            f"{container}_n{size}_{value}")


def widths(row: Row) -> tuple[int, int]:
    right = int(row[0])
    return right + {"narrow": -1, "same": 0, "wide": 1}[row[1]], right


def inputs(row: Row, phase: int) -> tuple[str, list[str], list[str]]:
    """Return needle, supplied set words, stored words in the observed order."""
    wa, wb = widths(row)
    value, size = row[7], int(row[6])
    needle = f"{(0, 1, 1 << (wa - 1), (1 << wa) - 1)[phase]:0{wa}b}"
    supplied = ["1" * wb] if size == 1 else (["1" * wb, "1" * wb, f"{1:0{wb}b}"] if size else [])
    if value == "lhs_x":
        needle = needle[:-1] + "x"
    elif value in ("rhs_x", "rhs_z"):
        i = 1 if size == 3 else 0
        supplied[i] = value[-1] + supplied[i][1:]
    elif value == "both_unknown":
        left, right = ("xx", "zz", "xz", "zx")[phase]
        needle = needle[:-1] + left
        i = 1 if size == 3 else 0
        supplied[i] = supplied[i][:-1] + right
    if size == 3:
        order = ((0, 1, 2), (2, 1, 0), (1, 0, 2), (0, 2, 1))[phase]
        supplied = [supplied[i] for i in order]
    stored = [two_state(v) if row[4] == "bit" else v for v in supplied]
    return needle, supplied, stored


def membership(needle: str, values: list[str], needle_sign: str, set_sign: str) -> str:
    comparisons = [compare(needle, v, needle_sign, set_sign, "weq") for v in values]
    return "1" if "1" in comparisons else "x" if "x" in comparisons else "0"


def make_case(row: Row) -> Case:
    _, _, ns, ss, state, container, size_text, value = row
    wa, wb = widths(row)
    size = int(size_text)
    name = case_name(row)
    if container == "fixed":
        declaration = f"  word_t bag[0:{size-1}];"
    elif container == "dynamic":
        declaration = "  word_t bag[];"
    elif container == "queue":
        declaration = "  word_t bag[$];"
    else:
        declaration = ""
    items = ", ".join(f"terms[{i}]" for i in range(size))
    reversed_items = ", ".join(f"terms[{i}]" for i in range(size - 1, -1, -1))
    expression = "needle inside {" + (items if container == "list" else "bag") + "}"
    reverse_expr = "needle inside {" + reversed_items + "}"
    lines = [f"module {name};", f"  typedef {state} {ss} [{wb-1}:0] word_t;",
             f"  logic {ns} [{wa-1}:0] needle;", f"  logic [{wb-1}:0] supplied[0:2];",
             "  word_t terms[0:2];", declaration, "  logic raw, listed;",
             "  logic [6:0] wide;", "  bit [6:0] binary;", "  initial begin"]
    expected = []
    for phase in range(4):
        needle, supplied, stored = inputs(row, phase)
        result = membership(needle, stored, ns, ss)
        lines += [f"    needle = {literal(needle)};"]
        for i, bits in enumerate(supplied):
            lines += [f"    supplied[{i}] = {literal(bits)};", f"    terms[{i}] = supplied[{i}];"]
        if container == "dynamic":
            lines += [f"    bag = new[{size}];"]
        elif container == "queue":
            lines += ["    bag.delete();"]
        if container != "list":
            for i in range(size):
                lines += ([f"    bag.push_back(terms[{i}]);"] if container == "queue"
                          else [f"    bag[{i}] = terms[{i}];"])
        lines += [f'    $display("p{phase} needle=%b size={size}", needle);']
        expected += [f"p{phase} needle={needle} size={size}"]
        for i, bits in enumerate(stored):
            expr = f"terms[{i}]" if container == "list" else f"bag[{i}]"
            lines += [f'    $display("p{phase} item{i} supplied=%b stored=%b", supplied[{i}], {expr});']
            expected += [f"p{phase} item{i} supplied={supplied[i]} stored={bits}"]
        if container in ("dynamic", "queue"):
            lines += [f'    $display("p{phase} actual_size=%0d", bag.size());']
            expected += [f"p{phase} actual_size={size}"]
        lines += [f"    raw = {expression};", f"    wide = {expression};",
                  f"    binary = {expression};",
                  f'    $display("p{phase} raw=%b wide=%b binary=%b bits=%0d",',
                  f"             raw, wide, binary, $bits({expression}));"]
        expected += [f"p{phase} raw={result} wide=000000{result} binary=000000{two_state(result)} bits=1"]
        if size:
            lines += [f"    listed = {reverse_expr};", f'    $display("p{phase} reversed=%b", listed);']
            expected += [f"p{phase} reversed={result}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Inside membership combines set storage, widths, signs, wildcards and result conversion",
        "11.4.13 11.4.6 11.6.1 11.8.2 6.11.2 7.4.1",
        "Four input phases check zero, one, the top bit and all ones. Set elements share one "
        "type. A supplied X/Z can become zero in bit storage before wildcard comparison. "
        "The needle stays four-state; only RHS X/Z bits are wildcards. Three-element sets "
        "include duplicates and permute their physical order. In both_unknown, one known "
        "comparison can be X while a wildcard member matches, so the OR must be one. "
        "A reversed explicit list checks the same membership without depending on scan order. "
        "Empty dynamic arrays/queues return zero even for an unknown needle. Input bits, "
        "supplied/stored members, sizes, raw/wide/two-state results and one-bit result width "
        "are observed. Ranges, heterogeneous members, nonintegral and nested arrays, side "
        "effects and expression evaluation order are outside this finite model.",
        "\n".join(line for line in lines if line), "\n".join(expected) + "\n",
        fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

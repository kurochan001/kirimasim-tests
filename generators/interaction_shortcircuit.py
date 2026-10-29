"""Cross logical short-circuit evaluation with typed words and side effects.

11.4.7 requires left evaluation and specified right-operand skipping for
AND, OR and implication; equivalence evaluates each operand exactly once.
Independent counters and seen values avoid any dependence on operand order.
Every row checks all four operators at scalar and wide assignment contexts.
"""

from common import Case
from interaction_bits import two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_shortcircuit"
VERSION = 1
CHAPTER = 11
OPERATORS = {"and": "&&", "or": "||", "imply": "->", "equiv": "<->"}
STATES = {"bb": ("bit", "bit"), "bl": ("bit", "logic"),
          "lb": ("logic", "bit"), "ll": ("logic", "logic")}
CLASSES = ("zero", "one", "unknown", "mixed")


def geometry(row: Row) -> tuple[int, int]:
    width, relation, *_ = row
    left = int(width)
    return left, left + {"narrow": -1, "same": 0, "wide": 1}[relation]


def legal(row: Row) -> bool:
    left, right = geometry(row)
    return (right > 0 and (left > 1 or row[3] != "mixed")
            and (right > 1 or row[4] != "mixed"))


MODEL = Model(
    "logical_short_circuit",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("rhs_width", ("narrow", "same", "wide")), ("state", tuple(STATES)),
     ("value_a", CLASSES), ("value_b", CLASSES), ("result_state", ("bit", "logic"))),
    legal,
    groups=(("width", "state", "value_a"), ("value_a", "value_b", "state"),
            ("value_a", "value_b", "result_state"), ("rhs_width", "state", "value_b")),
    anchors=(("129", "narrow", "ll", "unknown", "one", "logic"),
             ("65", "wide", "bl", "unknown", "mixed", "bit"),
             ("33", "same", "lb", "mixed", "unknown", "logic"),
             ("1", "wide", "ll", "unknown", "mixed", "logic"),
             ("32", "narrow", "bb", "zero", "unknown", "bit")),
    constraints=("幅0の右入力を除外。mixedは最上位X/Zと最下位1なので幅1では除外。"
                 "stateは左／右のbit/logic。未知値はX/Zを同じ行の別刺激で両方確認。"
                 "全行で4演算を実行し、左右の副作用は独立。入力はsignedに固定",),
)


def case_name(row: Row) -> str:
    width, relation, state, left, right, result = row
    return f"test_gen_cross_sc_w{width}_{relation[0]}_{state}_{left}_{right}_{result[0]}"


def word(width: int, kind: str, unknown: str) -> str:
    bits = ["0"] * width
    if kind != "zero":
        bits[0] = "1" if kind == "one" else unknown
    if kind == "mixed":
        bits[-1] = "1"
    return "".join(bits)


def inputs(row: Row, phase: int = 0, *, baseline: int | None = None) -> tuple[str, ...]:
    left, right = geometry(row)
    _, _, state, a_kind, b_kind, _ = row
    if baseline is None:
        raw_a = word(left, a_kind, "xz"[phase // 2])
        raw_b = word(right, b_kind, "xz"[phase % 2])
    else:
        raw_a = word(left, "zero" if baseline == 0 else "one", "x")
        raw_b = word(right, "one" if baseline == 0 else "zero", "x")
    a = two_state(raw_a) if STATES[state][0] == "bit" else raw_a
    b = two_state(raw_b) if STATES[state][1] == "bit" else raw_b
    return raw_a, raw_b, a, b


def truth(bits: str) -> str:
    if "1" in bits:
        return "1"
    return "x" if any(c in "xz" for c in bits) else "0"


def negate(value: str) -> str:
    return {"0": "1", "1": "0", "x": "x"}[value]


def logical(operator: str, left: str, right: str) -> str:
    if operator == "imply":
        return logical("or", negate(left), right)
    if operator == "equiv":
        return logical("and", logical("imply", left, right),
                       logical("imply", right, left))
    control, identity = ("0", "1") if operator == "and" else ("1", "0")
    if control in (left, right):
        return control
    return identity if left == right == identity else "x"


def right_calls(operator: str, left_truth: str) -> int:
    return int(not ((operator in ("and", "imply") and left_truth == "0")
                   or (operator == "or" and left_truth == "1")))


def initial_seen(bits: str) -> str:
    return "".join("0" if c == "1" else "1" for c in bits)


def reference(row: Row, operator: str, phase: int = 0, *, baseline: int | None = None) -> dict:
    raw_a, raw_b, a, b = inputs(row, phase, baseline=baseline)
    calls = right_calls(operator, truth(a))
    scalar = logical(operator, truth(a), truth(b))
    wide = "0" * 6 + scalar
    return {"raw_a": raw_a, "raw_b": raw_b, "a": a, "b": b, "scalar": scalar,
            "wide": two_state(wide) if row[-1] == "bit" else wide,
            "calls_b": calls, "seen_a": a, "seen_b": b if calls else initial_seen(b),
            "marker_a": "a5", "marker_b": "3c" if calls else "69"}


def stimuli(row: Row) -> list[tuple[str, int, int | None]]:
    if not any(kind in ("unknown", "mixed") for kind in row[3:5]):
        return [("p0", 0, None)]
    result = [("k0", 0, 0), ("k1", 0, 1)]
    seen = set()
    for phase in range(4):
        pair = inputs(row, phase)[:2]
        if pair not in seen:
            result.append((f"p{phase}", phase, None))
            seen.add(pair)
    return result


def make_case(row: Row) -> Case:
    left, right = geometry(row)
    left_state, right_state = STATES[row[2]]
    name = case_name(row)
    lines = [f"module {name};",
             f"  typedef {left_state} signed [{left - 1}:0] left_t;",
             f"  typedef {right_state} signed [{right - 1}:0] right_t;",
             f"  logic [{left - 1}:0] raw_left, seen_left;",
             f"  logic [{right - 1}:0] raw_right, seen_right;",
             "  left_t left_value;", "  right_t right_value;",
             "  int left_count, right_count;", "  logic [7:0] left_marker, right_marker;",
             "  logic scalar;", f"  {row[-1]} [6:0] wide;",
             "  function automatic left_t read_left();", "    left_count++;",
             "    left_marker = 8'ha5;", "    seen_left = left_value;",
             "    read_left = left_value;", "  endfunction",
             "  function automatic right_t read_right();", "    right_count++;",
             "    right_marker = 8'h3c;", "    seen_right = right_value;",
             "    read_right = right_value;", "  endfunction", "  initial begin"]
    expected = []
    for label, phase, baseline in stimuli(row):
        raw_a, raw_b, a, b = inputs(row, phase, baseline=baseline)
        lines += [f"    raw_left = {literal(raw_a)};", f"    raw_right = {literal(raw_b)};",
                  "    left_value = raw_left;", "    right_value = raw_right;",
                  f'    $display("{label}_input=%b %b typed=%b %b",',
                  "             raw_left, raw_right, left_value, right_value);"]
        expected.append(f"{label}_input={raw_a} {raw_b} typed={a} {b}")
        for operator, symbol in OPERATORS.items():
            result = reference(row, operator, phase, baseline=baseline)
            for target in ("scalar", "wide"):
                lines += ["    left_count = 0; right_count = 0;",
                          "    left_marker = 8'h5a; right_marker = 8'h69;",
                          f"    seen_left = {literal(initial_seen(a))};",
                          f"    seen_right = {literal(initial_seen(b))};",
                          f"    {target} = read_left() {symbol} read_right();",
                          f'    $display("{label}_{operator}_{target}=%b counts=%0d,%0d",',
                          f"             {target}, left_count, right_count);",
                          f'    $display("{label}_{operator}_{target}_seen=%b %b markers=%h,%h",',
                          "             seen_left, seen_right, left_marker, right_marker);"]
                expected += [f"{label}_{operator}_{target}={result[target]} "
                             f"counts=1,{result['calls_b']}",
                             f"{label}_{operator}_{target}_seen={result['seen_a']} "
                             f"{result['seen_b']} markers={result['marker_a']},{result['marker_b']}"]
            lines += [f'    $display("{label}_{operator}_bits=%0d",',
                      f"             $bits(left_value {symbol} right_value));"]
            expected.append(f"{label}_{operator}_bits=1")
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Logical operators short-circuit typed operands and preserve independent side effects",
        "11.4.7 11.6.1 11.8.1 6.11.2 13.4",
        "Each row observes AND, OR, implication and equivalence with scalar and wide "
        "destinations, resetting independent left/right counters, seen words and markers "
        "before each expression. Neither function changes the other operand or its "
        "side effects, so no unspecified evaluation order is assumed. False left skips "
        "right for AND/implication; true left skips right for OR; equivalence evaluates "
        "each operand once. Typed source conversion precedes truth evaluation; final "
        "bit conversion follows the unsigned one-bit result. Unknown rows include "
        "known branch witnesses and every distinct X/Z input pair. Widths are "
        "self-determined, with known ones and unknowns at the top word bit.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=any(kind in ("unknown", "mixed") for kind in row[3:5]),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

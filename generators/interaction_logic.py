"""Cross packed unary reductions with expression shape and state conversion.

Every row observes all six reduction operators and logical negation. The
source is converted before expression formation; the unsigned one-bit result
is zero-extended before any final two-state conversion. Known all-one inputs
keep width and controlling-bit effects observable in unknown-value rows.
"""

from common import Case
from interaction_bits import two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_logic"
VERSION = 1
CHAPTER = 11
OPERATORS = {"and": "&", "nand": "~&", "or": "|", "nor": "~|",
             "xor": "^", "xnor": "~^", "not": "!"}


def legal(row: Row) -> bool:
    w, _, shape, value, position, _ = row
    if (value in ("zero", "ones")) != (position == "none"):
        return False
    return w != "1" or (shape != "half" and value != "mixed"
                         and position in ("none", "low"))


MODEL = Model(
    "packed_logical_reduction",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")),
     ("expression", ("direct", "half", "prefix_zero", "prefix_one")),
     ("value", ("zero", "ones", "one", "x", "z", "mixed")),
     ("position", ("none", "low", "middle", "high")),
     ("result_state", ("bit", "logic"))),
    legal,
    groups=(("width", "state", "value"), ("expression", "state", "value"),
            ("state", "result_state", "value")),
    anchors=(("129", "logic", "direct", "mixed", "high", "logic"),
             ("65", "logic", "prefix_one", "z", "high", "bit"),
             ("33", "bit", "half", "x", "high", "logic"),
             ("1", "logic", "direct", "z", "low", "logic"),
             ("64", "logic", "prefix_zero", "ones", "none", "bit"),
             ("65", "logic", "direct", "ones", "none", "bit")),
    constraints=("zero/onesの位置はnone、他はlow/middle/high。幅1はlowだけを使い、"
                 "mixedと幅0になるhalfを除外。halfは下位半分。各行で全6リダクションと!を観測。"
                 "入力と代入先の状態型を分け、全行で既知の全1入力も観測する。"
                 "入力はsignedに固定し、演算結果がunsignedであることを確認する",),
)


def case_name(row: Row) -> str:
    w, state, shape, value, position, result_state = row
    return (f"test_gen_cross_logic_w{w}_{state[0]}_{shape}_{value}_{position}_"
            f"{result_state[0]}")


def source_bits(row: Row, *, baseline: bool = False) -> str:
    w, _, _, value, position, _ = row
    w = int(w)
    if baseline or value == "ones":
        return "1" * w
    bits = ["0"] * w
    if value == "zero":
        return "".join(bits)
    pos = {"low": 0, "middle": w // 2, "high": w - 1}[position]
    if value == "mixed":
        for offset, char in enumerate("xz1"):
            bits[w - 1 - (pos + offset) % w] = char
    else:
        bits[w - 1 - pos] = "1" if value == "one" else value
    return "".join(bits)


def evaluate(bits: str) -> dict[str, str]:
    """Use known controlling values and parity, independently of SV syntax."""
    unknown = any(c in "xz" for c in bits)
    and_value = "0" if "0" in bits else "x" if unknown else "1"
    or_value = "1" if "1" in bits else "x" if unknown else "0"
    xor_value = "x" if unknown else str(bits.count("1") % 2)
    invert = {"0": "1", "1": "0", "x": "x"}
    return {"and": and_value, "nand": invert[and_value],
            "or": or_value, "nor": invert[or_value],
            "xor": xor_value, "xnor": invert[xor_value], "not": invert[or_value]}


def reference(row: Row, *, baseline: bool = False) -> tuple[str, str, str, dict[str, tuple[str, str]]]:
    _, state, shape, _, _, result_state = row
    raw = source_bits(row, baseline=baseline)
    source = two_state(raw) if state == "bit" else raw
    expression = {"direct": source, "half": source[-(len(source) // 2):],
                  "prefix_zero": "0" + source, "prefix_one": "1" + source}[shape]
    result = {}
    for op, scalar in evaluate(expression).items():
        wide = "0" * 6 + scalar
        result[op] = (scalar, two_state(wide) if result_state == "bit" else wide)
    return raw, source, expression, result


def make_case(row: Row) -> Case:
    w, state, shape, value, _, result_state = row
    w = int(w)
    name = case_name(row)
    expr = {"direct": "source", "half": f"source[{w // 2 - 1}:0]",
            "prefix_zero": "{1'b0, source}", "prefix_one": "{1'b1, source}"}[shape]
    ew = w // 2 if shape == "half" else w + int(shape.startswith("prefix"))
    lines = [f"module {name};", f"  logic [{w - 1}:0] raw_input;",
             f"  {state} signed [{w - 1}:0] source;", f"  logic [{ew - 1}:0] expression_bits;"]
    for op in OPERATORS:
        lines += [f"  logic r_{op};", f"  {result_state} [6:0] wide_{op};"]
    lines.append("  initial begin")
    expected = []
    stimuli = (("p", False),) if value == "ones" else (("k", True), ("p", False))
    for prefix, baseline in stimuli:
        raw, source, expression, result = reference(row, baseline=baseline)
        lines += [f"    raw_input = {literal(raw)};", "    source = raw_input;",
                  f"    expression_bits = {expr};",
                  f'    $display("{prefix}_input=%b source=%b expr=%b",',
                  "             raw_input, source, expression_bits);"]
        expected.append(f"{prefix}_input={raw} source={source} expr={expression}")
        for op, symbol in OPERATORS.items():
            operation = f"{symbol}({expr})"
            scalar, wide = result[op]
            lines += [f"    r_{op} = {operation};", f"    wide_{op} = {operation};",
                      f'    $display("{prefix}_{op}=%b wide=%b bits=%0d",',
                      f"             r_{op}, wide_{op}, $bits({operation}));"]
            expected.append(f"{prefix}_{op}={scalar} wide={wide} bits=1")
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Packed reductions and logical negation preserve self-determined width and state order",
        "11.4.9 11.4.7 11.6.1 11.8.1 6.11.2"
        + (" 11.5.1" if shape == "half" else " 11.4.12" if shape.startswith("prefix") else ""),
        "Every row observes all six unary reductions and logical negation. A direct vector, "
        "lower-half select, or prefixed known bit forms a self-determined operand. Known "
        "zero controls AND; known one controls OR and makes logical negation false even "
        "with X/Z elsewhere. XOR propagates unknowns. Source bit conversion precedes "
        "expression formation; the unsigned one-bit result is extended to seven bits "
        "before final bit conversion. Known all-one inputs keep width and controlling-bit "
        "effects visible in every row. Raw input, source, expression and results are "
        "observed separately. The source is signed to expose incorrect result sign "
        "extension. Binary connectives and side effects are outside this model.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=value in ("x", "z", "mixed"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

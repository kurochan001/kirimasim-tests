"""Cross array reductions with container, element type and with-expression.

7.12.3 fixes the return type to the element/with-expression type. Conversion
therefore precedes reduction, and a wider assignment cannot prevent overflow.
Two backgrounds expose both controlling values and unknown propagation.
"""

from math import prod

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_method"
VERSION = 1
CHAPTER = 7

MODEL = Model(
    "array_reduction_pipeline",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("sign", ("unsigned", "signed")),
     ("storage", ("fixed", "dynamic", "queue")),
     ("method", ("sum", "product", "and", "or", "xor")),
     ("transform", ("plain", "widen", "int", "integer")),
     ("value", ("known", "high_x", "high_z"))),
    lambda r: True,
    groups=(("width", "transform", "value"), ("method", "storage", "transform"),
            ("method", "state", "value")),
    anchors=(("129", "logic", "signed", "queue", "xor", "int", "high_z"),
             ("65", "bit", "unsigned", "dynamic", "product", "widen", "high_x"),
             ("33", "logic", "unsigned", "fixed", "sum", "plain", "known"),
             ("1", "logic", "unsigned", "queue", "sum", "widen", "known"),
             ("1", "logic", "unsigned", "fixed", "or", "int", "high_x"),
             ("1", "logic", "unsigned", "fixed", "or", "integer", "high_x"),
             ("32", "logic", "unsigned", "fixed", "product", "widen", "known"),
             ("129", "bit", "unsigned", "dynamic", "and", "widen", "known")),
    constraints=("各コンテナは3要素。固定長配列は[3:1]。widenは要素幅+1のサイズキャスト、"
                 "int/integerは32ビットsignedの2/4状態型へのキャスト。"
                 "空配列、連想配列、副作用付きwith式は対象外",),
)


def case_name(row: Row) -> str:
    w, state, sign, storage, method, transform, value = row
    return f"test_gen_cross_method_w{w}_{state[0]}_{sign[0]}_{storage[0]}_{method}_{transform}_{value}"


def inputs(row: Row, phase: int) -> list[str]:
    w, state, _, _, _, _, value = row
    w = int(w)
    first = pattern(w, "known")
    if value != "known":
        first = value[-1] + first[1:]
    result = [first, ("1" if phase == 0 else "0") * w, ("1" if phase == 0 else "0") * w]
    return [two_state(x) for x in result] if state == "bit" else result


def return_type(row: Row) -> tuple[int, str, str]:
    w, state, sign, _, _, transform, _ = row
    if transform in ("int", "integer"):
        return 32, "bit" if transform == "int" else "logic", "signed"
    return int(w) + (transform == "widen"), state, sign


def reduce_values(values: list[str], method: str) -> str:
    n = len(values[0])
    if method in ("sum", "product"):
        if any(c in "xz" for bits in values for c in bits):
            return "x" * n
        numbers = [int(bits, 2) for bits in values]
        result = sum(numbers) if method == "sum" else prod(numbers)
        return f"{result & ((1 << n) - 1):0{n}b}"
    result = []
    for column in zip(*values):
        if method == "and":
            bit = "0" if "0" in column else "x" if any(c in "xz" for c in column) else "1"
        elif method == "or":
            bit = "1" if "1" in column else "x" if any(c in "xz" for c in column) else "0"
        else:
            bit = "x" if any(c in "xz" for c in column) else str(column.count("1") % 2)
        result.append(bit)
    return "".join(result)


def reference(row: Row, phase: int) -> tuple[str, str]:
    n, state, sign = return_type(row)
    values = [resize(v, n, row[2] == "signed") for v in inputs(row, phase)]
    if state == "bit":
        values = [two_state(v) for v in values]
    reduced = reduce_values(values, row[4])
    return reduced, resize(reduced, n + 1, sign == "signed")


def make_case(row: Row) -> Case:
    w, state, sign, storage, method, transform, value = row
    w = int(w)
    n, rs, rsign = return_type(row)
    name = case_name(row)
    suffix = {"fixed": "[3:1]", "dynamic": "[]", "queue": "[$]"}[storage]
    indices = (3, 2, 1) if storage == "fixed" else (0, 1, 2)
    expr = f"a.{method}()"
    if transform != "plain":
        cast = f"{w + 1}'(item)" if transform == "widen" else f"{transform}'(item)"
        expr += f" with ({cast})"
    lines = [f"module {name};", f"  typedef {state} {sign} [{w - 1}:0] word_t;",
             f"  word_t a{suffix};", f"  {rs} {rsign} [{n - 1}:0] reduced;",
             f"  logic [{n}:0] direct, saved;", "  initial begin"]
    expected = []
    for phase in (0, 1):
        values = inputs(row, phase)
        # Preserve raw unknown literals at the source-state conversion boundary.
        raw = list(values)
        if value != "known":
            raw[0] = value[-1] + pattern(w, "known")[1:]
        if storage == "dynamic":
            lines.append("    a = new[3];")
        elif storage == "queue":
            lines.append("    a = {};")
        for index, bits in zip(indices, raw):
            lines.append(f"    a.push_back({literal(bits)});" if storage == "queue" else
                         f"    a[{index}] = {literal(bits)};")
        result, extended = reference(row, phase)
        lines += [f"    reduced = {expr};", f"    direct = {expr};", "    saved = reduced;",
                  f'    $display("p{phase}_inputs=%b %b %b", a[{indices[0]}], a[{indices[1]}], a[{indices[2]}]);',
                  f'    $display("p{phase}_value=%b direct=%b saved=%b bits=%0d",',
                  f"             reduced, direct, saved, $bits({expr}));"]
        expected += [f"p{phase}_inputs=" + " ".join(values),
                     f"p{phase}_value={result} direct={extended} saved={extended} bits={n}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Array reductions convert each element before reducing in the fixed return type",
        "7.12.3 7.5 7.10 6.24.1 11.4.3 11.4.8 11.8.2 6.11.2",
        "Three-element fixed arrays, dynamic arrays and queues use the same values. "
        "The optional with expression casts each element to width+1, int or integer before "
        "reduction; it sets the return width independently of the destination. Two input "
        "backgrounds exercise overflow, X/Z propagation and bitwise controlling values. "
        "Int converts X/Z to zero while integer preserves them; either 32-bit cast "
        "truncates high bits. Direct wide "
        "assignment and widening a captured result must agree, including sign extension. "
        "Inputs, returned bits and method-expression width are all observed.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

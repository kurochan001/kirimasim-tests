"""Cross unpacked array value copies with order, slices and wide elements.

7.6 requires equivalent element types, so both arrays use the same typedef.
Copying follows declaration order, not numeric index. Two rotated input
phases distinguish positions even for one-bit elements; source mutation
checks value-copy behavior, and a partial slice leaves a guard element.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_array"
VERSION = 1
CHAPTER = 7

MODEL = Model(
    "unpacked_array_copy",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("sign", ("unsigned", "signed")), ("state", ("bit", "logic")),
     ("source_order", ("ascending", "descending")),
     ("target_order", ("ascending", "descending")), ("value", ("known", "x", "z")),
     ("operation", ("whole", "slice"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("source_order", "target_order", "operation"),
            ("sign", "operation", "source_order")),
    anchors=(("129", "signed", "logic", "descending", "ascending", "z", "slice"),
             ("65", "unsigned", "bit", "ascending", "descending", "x", "whole"),
             ("33", "signed", "bit", "descending", "descending", "known", "whole")),
    constraints=("両配列の要素型は同じtypedef。各3要素、sliceは宣言順の先頭2要素。"
                 "非ゼロ添字の固定長配列を使い、動的配列・キュー・要素型変換は対象外",),
)


def case_name(row: Row) -> str:
    w, sign, state, source, target, value, operation = row
    return f"test_gen_cross_array_w{w}_{sign[0]}_{state[0]}_{source[0]}{target[0]}_{value[0]}_{operation[0]}"


def values(row: Row, phase: int) -> tuple[list[str], list[str], str]:
    w, _, state, _, _, value, _ = row
    w = int(w)
    raw = [pattern(w, value), "0" * w, "1" * w]
    if phase:
        raw = [raw[-1], *raw[:-1]]
    actual = [two_state(v) if state == "bit" else v for v in raw]
    changed = "".join("0" if c == "1" else "1" for c in actual[0])
    return raw, actual, changed


def reference(row: Row, phase: int) -> tuple[list[str], list[str], str]:
    _, sign, _, _, _, _, operation = row
    w = int(row[0])
    _, source, changed = values(row, phase)
    result = source if operation == "whole" else [*source[:2], "1" * w]
    return result, [resize(v, w + 1, sign == "signed") for v in result], changed


def make_case(row: Row) -> Case:
    w, sign, state, source_order, target_order, value, operation = row
    w = int(w)
    src = [2, 3, 4] if source_order == "ascending" else [4, 3, 2]
    dst = [5, 6, 7] if target_order == "ascending" else [7, 6, 5]
    name = case_name(row)
    assignment = ("target = source;" if operation == "whole" else
                  f"target[{dst[0]}:{dst[1]}] = source[{src[0]}:{src[1]}];")
    lines = [f"module {name};", f"  typedef {state} {sign} [{w - 1}:0] word_t;",
             f"  word_t source[{src[0]}:{src[-1]}], target[{dst[0]}:{dst[-1]}];",
             f"  logic [{w}:0] extended0, extended1, extended2;", "  initial begin"]
    expected = []
    for phase in (0, 1):
        raw, _, changed = values(row, phase)
        result, extended, _ = reference(row, phase)
        for i, v in zip(src, raw):
            lines.append(f"    source[{i}] = {literal(v)};")
        for i in dst:
            lines.append(f"    target[{i}] = '1;")
        lines += ["    " + assignment, f"    source[{src[0]}] = {literal(changed)};"]
        for n, i in enumerate(dst):
            lines.append(f"    extended{n} = target[{i}];")
        lines += [f'    $display("p{phase}=%b %b %b", target[{dst[0]}], target[{dst[1]}], target[{dst[2]}]);',
                  f'    $display("e{phase}=%b %b %b", extended0, extended1, extended2);',
                  f'    $display("changed{phase}=%b", source[{src[0]}]);']
        expected += [f"p{phase}=" + " ".join(result), f"e{phase}=" + " ".join(extended),
                     f"changed{phase}={changed}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Unpacked array copies preserve declaration order, values and slice guards",
        "7.6 7.4.6 6.11.2 11.8.2",
        "Equivalent element types are shared by source and target. Nonzero ascending or "
        "descending bounds map in declaration order. Whole assignment copies three words; "
        "slice assignment copies the first two and preserves the third. Two rotated input "
        "phases distinguish one-bit positions. Source mutation must not change the copy. "
        "Reading copied elements into wider vectors also checks their signedness. "
        "Icarus Verilog 13.0 does not compile these differing-bound whole/slice assignments.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

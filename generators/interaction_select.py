"""Cross indexed packed part-select writes with direction, width and X/Z.

The oracle numbers bits by significance, independently of SV index syntax.
The generator maps that offset into nonzero ascending/descending bounds and
either +: or -:. Whole-vector output checks preservation outside the slice.
"""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_select"
VERSION = 1
CHAPTER = 11


def geometry(row: Row) -> tuple[int, int, int]:
    w, _, _, span, position, *_ = row
    w = int(w)
    size = 1 if span == "single" else w // 2
    gap = w - size
    offset = {"low": 0, "high": gap, "interior": gap // 2}[position]
    return w, size, offset


def legal(row: Row) -> bool:
    w, size, offset = geometry(row)
    return size > 0 and (row[4] == "low" or
                        (row[4] == "high" and offset > 0) or
                        (row[4] == "interior" and 0 < offset < w - size))


MODEL = Model(
    "packed_part_select",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("direction", ("ascending", "descending")), ("select", ("plus", "minus")),
     ("span", ("single", "half")), ("position", ("low", "high", "interior")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z"))),
    legal,
    groups=(("width", "state", "value"), ("direction", "select", "position")),
    anchors=(("65", "ascending", "minus", "half", "high", "logic", "z"),
             ("129", "descending", "plus", "half", "interior", "logic", "x"),
             ("33", "ascending", "plus", "single", "high", "bit", "x")),
    constraints=("幅0の選択を除外。high/interiorがlowと同じ位置になる組合せを除外。"
                 "選択範囲はベクタ内。添字の下限は4",),
)


def case_name(row: Row) -> str:
    w, direction, select, span, pos, state, value = row
    return f"test_gen_cross_select_w{w}_{direction[0]}_{select[0]}_{span[0]}_{pos}_{state[0]}_{value[0]}"


def reference(row: Row) -> tuple[str, str, str, str]:
    w, size, offset = geometry(row)
    before = ("10" * ((w + 1) // 2))[:w]
    start = w - offset - size
    old_slice = before[start:start + size]
    data = ("".join("0" if c == "1" else "1" for c in old_slice)
            if row[6] == "known" else row[6] * size)
    stored = data if row[5] == "logic" else data.replace("x", "0").replace("z", "0")
    after = before[:start] + stored + before[start + size:]
    return before, data, old_slice, after


def make_case(row: Row) -> Case:
    _, direction, select, _, _, state, _ = row
    w, size, offset = geometry(row)
    left, right = (4, w + 3) if direction == "ascending" else (w + 3, 4)
    if direction == "ascending":
        base = right - offset - size + 1 if select == "plus" else right - offset
    else:
        base = right + offset if select == "plus" else right + offset + size - 1
    before, data, old_slice, after = reference(row)
    stored = data if state == "logic" else data.replace("x", "0").replace("z", "0")
    expr = f"target[index {'+:' if select == 'plus' else '-:'} {size}]"
    initial = f"{size}'h{int(data, 2):x}" if row[6] == "known" else f"'{row[6]}"
    name = case_name(row)
    lines = [f"module {name};", f"  {state} [{left}:{right}] target;",
             f"  logic [{size - 1}:0] data;", "  integer index;", "  initial begin",
             f"    target = {w}'h{int(before, 2):x};", f"    data = {initial};",
             f"    index = {base};", f'    $display("before=%b slice=%b", target, {expr});',
             f"    {expr} = data;", f'    $display("after=%b slice=%b", target, {expr});',
             "    $finish;", "  end", "endmodule"]
    return Case(
        name, "Indexed packed slice writes preserve bit order and all unselected bits",
        "11.5.1 7.4.1 6.11.2",
        "A runtime base index and a constant positive slice width address a packed vector "
        "with nonzero bounds. Ascending/descending declarations and plus/minus indexed "
        "selects map the same significance-based slice. Before and after outputs check "
        "both the selected value and every unselected bit. Logic preserves X/Z from the "
        "source; bit storage converts X/Z to zero. Out-of-range accesses are not modeled.",
        "\n".join(lines), f"before={before} slice={old_slice}\nafter={after} slice={stored}\n",
        fourstate=row[6] != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

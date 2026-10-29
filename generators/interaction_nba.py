"""Constrained cross tests of NBA value/index capture (1800-2023 10.4.2).

All targets have static lifetime. Automatic task inputs supply a captured
value/index, then their frame returns before the update. The Python oracle
models capture, 4-to-2-state conversion and Active-before-NBA observation;
it does not call a simulator. Existing tests and expectations are untouched.
"""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_nba"
VERSION = 1
CHAPTER = 10


def legal(row: Row) -> bool:
    return (row[3] == "scalar") == (row[4] == "none")


MODEL = Model(
    "nba_capture",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")),
     ("value", ("known", "x", "z")),
     ("storage", ("scalar", "array")),
     ("direction", ("none", "ascending", "descending")),
     ("home", ("initial", "task")),
     ("timing", ("immediate", "delayed"))),
    legal,
    groups=(("width", "state", "value"), ("storage", "home", "timing")),
    anchors=(("65", "logic", "x", "array", "descending", "task", "delayed"),
             ("129", "logic", "z", "array", "ascending", "task", "delayed"),
             ("129", "bit", "x", "array", "descending", "task", "immediate")),
    constraints=("スカラの添字方向は非該当。配列では昇順または降順を選ぶ",),
)


def case_name(row: Row) -> str:
    width, state, value, storage, direction, home, timing = row
    return (f"test_gen_cross_nba_w{width}_{state[0]}_{value[0]}_{storage[0]}_"
            f"{direction[0]}_{home[0]}_{timing[0]}")


def reference(row: Row) -> tuple[str, str, str]:
    width, state, value, *_ = row
    w = int(width)
    mask = (1 << w) - 1
    pattern = (1 << (w - 1)) | 1
    if value == "known":
        captured = f"{pattern:0{w}b}"
        before = changed = f"{mask ^ pattern:0{w}b}"
    else:
        captured = value * w if state == "logic" else "0" * w
        before = "0" * w if state == "logic" else "1" * w
        changed = "1" * w
    return before, captured, changed


def make_case(row: Row) -> Case:
    width, state, value, storage, direction, home, timing = row
    w = int(width)
    before, captured, changed = reference(row)
    # Sized known patterns exercise both the top bit and the low bit. X/Z
    # literals are context-filled; a bit destination converts them to zero.
    initial = f"{w}'h{((1 << (w - 1)) | 1):x}" if value == "known" else f"'{value}"
    before_literal = f"{w}'h{int(before, 2):x}"
    changed_literal = f"{w}'h{int(changed, 2):x}"
    delay = " #1" if timing == "delayed" else ""
    left, right = (3, 2) if direction == "descending" else (2, 3)
    chosen = f"target[{left}]" if storage == "array" else "target"
    guard = f"target[{right}]" if storage == "array" else "untouched"
    destination = "target[index]" if storage == "array" else "target"
    task_destination = "target[where]" if storage == "array" else "target"
    name = case_name(row)
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef {state} [{w - 1}:0] word_t;", "  word_t source;",
             "  integer index;"]
    lines += ([f"  word_t target[{left}:{right}];"] if storage == "array" else
              ["  word_t target, untouched;"])
    if home == "task":
        lines += ["  task automatic enqueue(input word_t data, input integer where);",
                  f"    {task_destination} <={delay} data;", "  endtask"]
    lines += ["  initial begin", f"    {chosen} = {before_literal};",
              f"    {guard} = {before_literal};", f"    source = {initial};",
              f"    index = {left};"]
    lines += (["    enqueue(source, index);"] if home == "task" else
              [f"    {destination} <={delay} source;"])
    lines += [f'    $display("before=%b", {chosen});',
              f"    source = {changed_literal};", f"    index = {right};",
              '    $display("stimulus=%b index=%0d", source, index);',
              "    #1;", f'    $display("tick1=%b", {chosen});', "    #1;",
              f'    $display("captured=%b untouched=%b", {chosen}, {guard});',
              "    $finish;", "  end", "endmodule"]
    at_one = before if timing == "delayed" else captured
    expected = (f"before={before}\nstimulus={changed} index={right}\n"
                f"tick1={at_one}\ncaptured={captured} untouched={before}\n")
    return Case(
        name,
        "NBA captures its value and target before source/index mutation and task return",
        "10.4.2 9.4.5 4.4.2.2 4.4.2.4 6.11.2 13.5.1 7.4.1",
        "The target is static. The source and index change immediately after scheduling. "
        "An automatic task, when selected, has already returned. At time 1 the Active "
        "reader precedes a delayed NBA; at time 2 the original target holds the captured "
        "value and its neighbor is untouched. X/Z survive logic storage and become zero "
        "in bit storage. This checks interacting semantics, not keyword co-occurrence.",
        "\n".join(lines), expected, fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

"""Cross automatic task argument modes with storage, delay, width and X/Z.

13.5 copies output/inout values on return; input changes stay local; ref
changes the original immediately. A module-scope observation from inside
the task distinguishes these mechanisms without a race or NBA assignment.
All ref actuals have exactly the formal typedef and the task is automatic.
"""

from common import Case
from interaction_bits import pattern, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_task"
VERSION = 1
CHAPTER = 13

MODEL = Model(
    "task_argument_visibility",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("mode", ("input", "output", "inout", "ref")),
     ("storage", ("scalar", "element")), ("timing", ("immediate", "delayed"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("mode", "storage", "timing")),
    anchors=(("129", "logic", "z", "ref", "element", "delayed"),
             ("65", "logic", "x", "inout", "element", "delayed"),
             ("33", "bit", "x", "output", "scalar", "delayed")),
    constraints=("全行でautomaticタスクを使い、実引数と仮引数の型を同じtypedefにする。"
                 "配列は[2:3]の固定長。呼出し中に実引数の添字は変更しない",),
)


def case_name(row: Row) -> str:
    w, state, value, mode, storage, timing = row
    return f"test_gen_cross_task_w{w}_{state[0]}_{value[0]}_{mode}_{storage[0]}_{timing[0]}"


def reference(row: Row) -> tuple[str, str, str, str, str]:
    w, state, value, mode, *_ = row
    w = int(w)
    source = pattern(w, value)
    captured = two_state(source) if state == "bit" else source
    before = ("".join("0" if c == "1" else "1" for c in source) if value == "known"
              else ("1" if state == "bit" else "0") * w)
    inside = captured if mode == "ref" else before
    after = before if mode == "input" else captured
    return source, before, captured, inside, after


def make_case(row: Row) -> Case:
    w, state, value, mode, storage, timing = row
    w = int(w)
    source, before, captured, inside, after = reference(row)
    name = case_name(row)
    actual = "cells[index]" if storage == "element" else "target"
    chosen = "cells[2]" if storage == "element" else "target"
    guard = "cells[3]" if storage == "element" else "untouched"
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef {state} [{w - 1}:0] word_t;", f"  logic [{w - 1}:0] source;",
             "  integer index;"]
    lines += ["  word_t cells[2:3];"] if storage == "element" else ["  word_t target, untouched;"]
    lines += [f"  task automatic transfer({mode} word_t formal);"]
    expected = []
    if mode != "output":
        lines.append('    $display("entry=%b", formal);')
        expected.append(f"entry={before}")
    lines += ["    formal = source;",
              f'    $display("inside=%b actual=%b guard=%b", formal, {chosen}, {guard});']
    expected.append(f"inside={captured} actual={inside} guard={before}")
    if timing == "delayed":
        lines.append("    #1;")
    lines += [f'    $display("returning=%b actual=%b t=%0t", formal, {chosen}, $time);',
              "  endtask", "  initial begin", f"    {chosen} = {literal(before)};",
              f"    {guard} = {literal(before)};", f"    source = {literal(source)};",
              "    index = 2;", f"    transfer({actual});",
              f'    $display("after=%b guard=%b t=%0t", {chosen}, {guard}, $time);',
              "    $finish;", "  end", "endmodule"]
    time = 1 if timing == "delayed" else 0
    expected += [f"returning={captured} actual={inside} t={time}",
                 f"after={after} guard={before} t={time}"]
    note = (" Icarus Verilog 13.0 rejects ref ports as unsupported." if mode == "ref" else "")
    if name == "test_gen_cross_task_w33_b_k_ref_e_i":
        note += (" Verilator 5.052 rejects this array-element ref call with Error-IMPURE "
                 "because the non-inlined task reads external variables.")
    return Case(
        name, "Automatic task argument modes control when updates reach the original storage",
        "13.5 13.5.1 13.5.2 6.11.2 7.4.1 9.4.1",
        "The task overwrites its formal from a four-state source. Internal observations "
        "read the module's actual storage directly: input/output/inout writes stay local "
        "until return, while ref is visible immediately. Only output/inout copy back on "
        "return; input leaves the original unchanged. A neighboring word must never change. "
        "All ref types are equivalent and no NBA, concurrent writer or index mutation is used." + note,
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

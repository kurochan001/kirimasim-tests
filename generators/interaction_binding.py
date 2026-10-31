"""Cross argument binding with later index changes and bidirectional visibility.

13.5.1 copies an input value; 13.5.2 binds ref/const ref to the original
variable. A later selector change does not redirect that binding. The
selector is only invalidated after the call; no valid program reads an
out-of-range element. All argument expressions are side-effect free.
"""

from common import Case
from interaction_bits import two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_binding"
VERSION = 1
CHAPTER = 13

MODEL = Model(
    "argument_binding_index",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("mode", ("input", "ref", "const_ref")),
     ("storage", ("fixed", "dynamic", "queue")),
     ("index", ("same", "next", "invalid"))),
    lambda r: True,
    groups=(("width", "state", "value"), ("mode", "storage", "index")),
    anchors=(("1", "bit", "known", "ref", "fixed", "next"),
             ("129", "logic", "z", "const_ref", "dynamic", "invalid"),
             ("33", "bit", "known", "input", "queue", "next"),
             ("65", "logic", "x", "ref", "queue", "invalid"),
             ("64", "logic", "known", "const_ref", "fixed", "same")),
    constraints=("全行でautomaticタスクを使用。固定配列は[2:4]、動的配列とキューは3要素。"
                 "実引数の添字は呼出し時に先頭を指し、1 tick後に同値・次要素・-1へ変更。"
                 "変更後の添字で配列を読まない。型は同じtypedefでrefの型変換を避ける。"
                 "3組の入力を巡回し、X/Z行にも既知値の対照条件を含める。"
                 "output/inoutの復帰先評価、サイズ変更、副作用付き実引数、NBAは対象外",),
)


def case_name(row: Row) -> str:
    w, state, value, mode, storage, index = row
    return f"test_gen_cross_bind_w{w}_{state[0]}_{value}_{mode}_{storage}_{index}"


def phases(row: Row) -> tuple[tuple[str, int, str], ...]:
    return tuple((f"{kind[0]}{i}", i, kind) for i in range(3)
                 for kind in (("known",) if row[2] == "known" else ("known", row[2])))


def reference(row: Row, phase: int, value: str) -> dict:
    w, state, _, mode, storage, index = row
    w = int(w)
    initial = [("1" if phase == i else "0") * w for i in range(3)]
    source = "".join("0" if b == "1" else "1" for b in initial[0]) \
        if value == "known" else value * w
    stored = two_state(source) if state == "bit" else source
    other = "".join("0" if b == "1" else "1" for b in stored) \
        if all(b in "01" for b in stored) else "1" * w
    write = other if all(b in "01" for b in stored) else "0" * w
    tail = "".join("0" if b == "1" else "1" for b in write)
    first = [stored, other, initial[2]]
    seen = initial[0] if mode == "input" else stored
    after = seen if mode == "const_ref" else write
    after_write = [write if mode == "ref" else stored, other, initial[2]]
    final = [tail, other, initial[2]]
    base = 2 if storage == "fixed" else 0
    selector = base if index == "same" else base + 1 if index == "next" else -1
    return {"initial": initial, "source": source, "write": write, "tail": tail,
            "other": other, "selector": selector, "changed": first, "seen": seen,
            "formal_after": after, "after_write": after_write, "final": final,
            "returning": write if mode == "input" else tail}


def dump_lines(label: str, values: list[str], index: int) -> list[str]:
    return [f"{label} index={index} cells=" + ",".join(values)]


def make_case(row: Row) -> Case:
    width, state, _, mode, storage, _ = row
    w = int(width)
    base = 2 if storage == "fixed" else 0
    name = case_name(row)
    dimension = {"fixed": "[2:4]", "dynamic": "[]", "queue": "[$]"}[storage]
    direction = "const ref" if mode == "const_ref" else mode
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef {state} [{w - 1}:0] word_t;", f"  word_t cells{dimension};",
             f"  logic [{w - 1}:0] raw_source;", "  word_t write_value, tail_value, other_value;",
             "  int index;",
             f"  task automatic observe({direction} word_t formal, input word_t next_value,",
             "                         input string tag);",
             '    $display("%s entry=%b", tag, formal);', "    #2;",
             '    $display("%s seen=%b", tag, formal);']
    if mode != "const_ref":
        lines.append("    formal = next_value;")
    lines += ['    $display("%s after=%b", tag, formal);', "    #2;",
              '    $display("%s returning=%b", tag, formal);', "  endtask",
              "  task automatic dump(input string tag);",
              '    $display("%s index=%0d cells=%b,%b,%b", tag, index,',
              f"             cells[{base}], cells[{base + 1}], cells[{base + 2}]);",
              "  endtask", "  initial begin"]
    expected = []
    for label, phase, value in phases(row):
        r = reference(row, phase, value)
        if storage == "dynamic":
            lines.append("    cells = new[3];")
        elif storage == "queue":
            lines += ["    cells = {};", "    repeat (3) cells.push_back('0);"]
        lines += [f"    cells[{base + i}] = {literal(v)};" for i, v in enumerate(r['initial'])]
        lines += [f"    index = {base};", f"    raw_source = {literal(r['source'])};",
                  f"    write_value = {literal(r['write'])};",
                  f"    tail_value = {literal(r['tail'])};",
                  f"    other_value = {literal(r['other'])};",
                  f'    $display("{label} source=%b write=%b tail=%b",',
                  "             raw_source, write_value, tail_value);", f'    dump("{label}_start");',
                  "    fork", f'      observe(cells[index], write_value, "{label}");',
                  "    join_none", "    #1;", f"    index = {r['selector']};",
                  f"    cells[{base}] = raw_source;", f"    cells[{base + 1}] = other_value;",
                  f'    dump("{label}_changed");', "    #2;", f'    dump("{label}_after_write");',
                  f"    cells[{base}] = tail_value;", "    #2;", "    wait fork;",
                  f'    dump("{label}_final");']
        expected += [f"{label} source={r['source']} write={r['write']} tail={r['tail']}"]
        expected += dump_lines(label + '_start', r['initial'], base)
        expected += [f"{label} entry={r['initial'][0]}"]
        expected += dump_lines(label + '_changed', r['changed'], r['selector'])
        expected += [f"{label} seen={r['seen']}", f"{label} after={r['formal_after']}"]
        expected += dump_lines(label + '_after_write', r['after_write'], r['selector'])
        expected += [f"{label} returning={r['returning']}"]
        expected += dump_lines(label + '_final', r['final'], r['selector'])
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Argument binding survives selector changes and distinguishes input, ref and const ref",
        "13.5.2 13.5.1 13.5 7.4.1 6.11.2 9.3.2",
        "Each call binds the first valid element before the parent changes its index "
        "variable at +1. An index of -1 is only a stored scalar: no valid program "
        "dereferences it after the call. The caller then changes the original and "
        "neighbor elements. Input retains its entry copy; ref and const ref see the "
        "original element's new value at +2. Input/ref write a known marker while "
        "const ref only reads. The caller observes at +3 and writes a distinct tail "
        "value. Ref/const ref must see that value at +4; input keeps its private "
        "marker. Final array output at +5 detects copyback or neighbor corruption. "
        "Three rotated backgrounds identify every element at one-bit width. X/Z "
        "rows also run known controls. All observations avoid coincident writers; "
        "the arrays never resize while a reference is held and argument expressions "
        "have no side effects. This model makes no claim about output/inout binding.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=row[2] != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

"""Cross queue element identity, method/assignment updates and typed ref writes.

7.10.3 and 13.5.2 retain the referenced element in the called task even
after removal. Methods preserve surviving identities; whole-queue assignment
replaces them. Three rotated inputs distinguish identities at one-bit width.
"""

from dataclasses import dataclass

from common import Case
from interaction_bits import pattern, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_queue_ref"
VERSION = 1
CHAPTER = 7
OPERATIONS = ("push_front", "push_back", "insert", "pop_front", "pop_back",
              "delete_held", "delete_other", "copy", "concat", "clear")

MODEL = Model(
    "queue_element_reference",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("capacity", ("unbounded", "three")),
     ("held", ("first", "middle", "last")), ("operation", OPERATIONS),
     ("value", ("known", "x", "z"))),
    lambda r: True,
    groups=(("width", "state", "value"), ("capacity", "held", "operation")),
    anchors=(("129", "logic", "three", "last", "push_front", "z"),
             ("65", "bit", "unbounded", "middle", "copy", "x"),
             ("33", "logic", "three", "last", "delete_held", "known"),
             ("1", "bit", "unbounded", "middle", "push_front", "known"),
             ("64", "logic", "unbounded", "first", "pop_back", "known")),
    constraints=("初期要素数は3、容量は無制限または3。insertは添字1。delete_otherは"
                 "参照先がfirstなら添字2、それ以外は添字0。添字は呼出し中に変更しない。"
                 "3組の既知入力を巡回し、X/Z行にも既知値の対照条件を含める。"
                 "同時刻の競合、ref static、動的/連想配列、物理的メモリ回収は対象外。"
                 "未対応による除外はしない",),
)


@dataclass(eq=False)
class Cell:
    value: str


def case_name(row: Row) -> str:
    w, state, capacity, held, operation, value = row
    return f"test_gen_cross_qref_w{w}_{state[0]}_{capacity[0]}_{held[0]}_{operation}_{value}"


def phases(row: Row) -> tuple[tuple[str, int, str], ...]:
    return tuple((f"{kind[0]}{i}", i, kind) for i in range(3)
                 for kind in (("known",) if row[5] == "known" else ("known", row[5])))


def initial_values(row: Row, phase: int) -> list[str]:
    return [("1" if i == phase else "0") * int(row[0]) for i in range(3)]


def reference(row: Row, phase: int, value: str) -> dict:
    width, state, capacity, held_name, op, _ = row
    w = int(width)
    index = ("first", "middle", "last").index(held_name)
    initial = initial_values(row, phase)
    queue = [Cell(v) for v in initial]
    held = queue[index]
    before = held.value
    inverse = "".join("0" if c == "1" else "1" for c in before)
    raw_first = inverse if value == "known" else value * w
    raw_second = before if value == "known" else inverse
    first = two_state(raw_first) if state == "bit" else raw_first
    second = two_state(raw_second) if state == "bit" else raw_second
    incoming = pattern(w, "known")
    popped = "0" * w
    if op == "push_front":
        queue.insert(0, Cell(incoming))
    elif op == "push_back":
        queue.append(Cell(incoming))
    elif op == "insert":
        queue.insert(1, Cell(incoming))
    elif op in ("pop_front", "pop_back"):
        popped = queue.pop(0 if op == "pop_front" else -1).value
    elif op == "delete_held":
        queue.pop(index)
    elif op == "delete_other":
        queue.pop(2 if index == 0 else 0)
    elif op == "copy":
        queue = [Cell(v) for v in initial]
    elif op == "concat":
        queue = [Cell(v) for v in initial + [incoming]]
    else:
        queue = []
    if capacity == "three":
        queue = queue[:3]
    changed = [c.value for c in queue]
    valid = any(c is held for c in queue)
    held.value = first
    after_first = [c.value for c in queue]
    held.value = second
    return {"initial": initial, "before": before, "raw_first": raw_first,
            "raw_second": raw_second, "first": first, "second": second,
            "incoming": incoming, "popped": popped, "changed": changed,
            "after_first": after_first, "final": [c.value for c in queue], "valid": valid}


def dump_lines(label: str, values: list[str]) -> list[str]:
    return [f"{label} size={len(values)}"] + [f"{label} q{i}={v}" for i, v in enumerate(values)]


def make_case(row: Row) -> Case:
    width, state, capacity, held_name, op, _ = row
    w = int(width)
    index = ("first", "middle", "last").index(held_name)
    name = case_name(row)
    suffix = "[$:2]" if capacity == "three" else "[$]"
    operation = {"push_front": "q.push_front(added);", "push_back": "q.push_back(added);",
                 "insert": "q.insert(1, added);", "pop_front": "popped = q.pop_front();",
                 "pop_back": "popped = q.pop_back();", "delete_held": f"q.delete({index});",
                 "delete_other": f"q.delete({2 if index == 0 else 0});", "copy": "q = saved;",
                 "concat": "q = {q, added};", "clear": "q.delete();"}[op]
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef {state} [{w - 1}:0] word_t;", f"  word_t q{suffix};",
             "  word_t saved[$], added, popped;", f"  logic [{w - 1}:0] raw_first, raw_second;",
             "  task automatic hold(ref word_t r, input word_t first_value,",
             "                      input word_t second_value, input string tag);",
             '    $display("%s entry=%b", tag, r);', "    #2;",
             '    $display("%s before=%b", tag, r);', "    r = first_value;",
             '    $display("%s first=%b", tag, r);', "    #2;", "    r = second_value;",
             '    $display("%s second=%b", tag, r);', "  endtask",
             "  task automatic dump(input string tag);",
             '    $display("%s size=%0d", tag, q.size());',
             '    foreach (q[i]) $display("%s q%0d=%b", tag, i, q[i]);', "  endtask",
             "  initial begin"]
    expected = []
    for label, phase, value in phases(row):
        r = reference(row, phase, value)
        lines += ["    q = {};", *[f"    q.push_back({literal(v)});" for v in r['initial']],
                  "    saved = q;", f"    added = {literal(r['incoming'])};", "    popped = '0;",
                  f"    raw_first = {literal(r['raw_first'])};",
                  f"    raw_second = {literal(r['raw_second'])};",
                  f'    $display("{label} input=%b,%b", raw_first, raw_second);',
                  f'    dump("{label}_start");', "    fork",
                  f'      hold(q[{index}], raw_first, raw_second, "{label}");', "    join_none",
                  "    #1;", "    " + operation,
                  f'    $display("{label} popped=%b", popped);', f'    dump("{label}_changed");',
                  "    #2;", f'    dump("{label}_after_first");', "    #2;", "    wait fork;",
                  f'    dump("{label}_final");',
                  f'    $display("{label}_saved size=%0d", saved.size());',
                  f'    foreach (saved[i]) $display("{label}_saved q%0d=%b", i, saved[i]);']
        expected += [f"{label} input={r['raw_first']},{r['raw_second']}"]
        expected += dump_lines(label + '_start', r['initial'])
        expected += [f"{label} entry={r['before']}", f"{label} popped={r['popped']}"]
        expected += dump_lines(label + '_changed', r['changed'])
        expected += [f"{label} before={r['before']}", f"{label} first={r['first']}"]
        expected += dump_lines(label + '_after_first', r['after_first'])
        expected += [f"{label} second={r['second']}"]
        expected += dump_lines(label + '_final', r['final'])
        expected += dump_lines(label + '_saved', r['initial'])
    lines += ["    $finish;", "  end", "endmodule"]
    extra = {"interaction_model": f"{MODEL.name}@{MODEL.version}",
             "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())}
    if capacity == "three" and op in ("push_front", "push_back", "insert", "concat"):
        extra['expected_stderr_regex'] = r"(?i:\bwarn(?:ing)?\b|%Warning-)"
    return Case(
        name, "Queue ref arguments retain element identity across moves, removal and replacement",
        "7.10.3 13.5.2 7.10.2 7.10.4 6.11.2 9.3.2" +
        (" 7.10.5" if capacity == "three" else ""),
        "An automatic task holds a reference to one of three queue elements. The "
        "caller mutates the queue at time +1; the holder reads and writes at +2 "
        "and writes again before returning at +4. Queue snapshots at +1/+3/+5 "
        "avoid races. Surviving method elements keep identity even if their index "
        "moves; removed or assignment-replaced elements remain usable only in the "
        "holder and its writes must not reach the new queue. A saved value copy "
        "must stay unchanged. Three rotated one-hot backgrounds distinguish all "
        "positions even with one-bit words. Every X/Z row also runs known writes; "
        "the formal input converts to the exact bit/logic element type before use. "
        "Bounded overflow drops elements above index 2 and requires a warning.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=row[5] != "known", extra=extra,
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

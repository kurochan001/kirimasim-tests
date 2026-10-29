"""Cross queue updates, capacity, occupancy and typed word transfer.

7.10.5 applies an unbounded operation then discards indices above the bound.
Two rotated inputs distinguish ordering even for one-bit elements. Empty
pops use the element-type default; method arguments convert before storage.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_queue"
VERSION = 1
CHAPTER = 7
CAPACITY = {"unbounded": None, "two": 2, "three": 3}

MODEL = Model(
    "queue_update_capacity",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("sign", ("unsigned", "signed")),
     ("capacity", tuple(CAPACITY)), ("size", ("0", "2", "3")),
     ("operation", ("push_front", "push_back", "insert", "write_end", "pop_front", "pop_back")),
     ("value", ("known", "x", "z"))),
    lambda r: CAPACITY[r[3]] is None or int(r[4]) <= CAPACITY[r[3]],
    groups=(("width", "state", "value"), ("capacity", "size", "operation"),
            ("operation", "sign", "value")),
    anchors=(("129", "logic", "signed", "three", "3", "push_front", "z"),
             ("65", "bit", "unsigned", "two", "2", "insert", "x"),
             ("33", "logic", "signed", "unbounded", "0", "pop_back", "known"),
             ("1", "bit", "unsigned", "three", "3", "write_end", "known"),
             ("65", "bit", "unsigned", "three", "0", "pop_front", "z")),
    constraints=("初期サイズは0・2・3。容量2のサイズ3は除外。容量は要素数で表す。"
                 "追加値は要素幅+1、insertは中央、write_endはsize()への書き込み。"
                 "2組の入力を使い、操作前コピーも観測する。要素参照の有効期間は対象外",),
)


def case_name(row: Row) -> str:
    w, state, sign, capacity, size, op, value = row
    cap = {"unbounded": "u", "two": "2", "three": "3"}[capacity]
    return f"test_gen_cross_queue_w{w}_{state[0]}_{sign[0]}_c{cap}_n{size}_{op}_{value}"


def initial_values(row: Row, phase: int) -> list[str]:
    w, state, _, _, size, _, value = row
    w, size = int(w), int(size)
    first = pattern(w, value)
    stored = two_state(first) if state == "bit" else first
    other = "".join("0" if c == "1" else "1" for c in stored)
    values = ([first, other] if size == 2 else [first, "0" * w, "1" * w])[:size]
    return values[1:] + values[:1] if phase else values


def reference(row: Row, phase: int) -> tuple[list[str], list[str], str, str, str]:
    w, state, sign, capacity, _, op, value = row
    w = int(w)
    initial = [two_state(v) if state == "bit" else v for v in initial_values(row, phase)]
    incoming = pattern(w + 1, value)
    item = resize(incoming, w, False)
    if state == "bit":
        item = two_state(item)
    changed = "0" + "".join("0" if c == "1" else "1" for c in item)
    queue = list(initial)
    removed = "0" * w
    if op == "push_front":
        queue.insert(0, item)
    elif op in ("push_back", "write_end"):
        queue.append(item)
    elif op == "insert":
        queue.insert(len(queue) // 2, item)
    else:
        removed = queue.pop(0 if op == "pop_front" else -1) if queue else \
            ("0" if state == "bit" else "x") * w
    cap = CAPACITY[capacity]
    if cap is not None:
        queue = queue[:cap]
    # The non-pop sentinel is a wide zero, independent of element signedness.
    expanded = resize(removed, w + 1, sign == "signed")
    return initial, queue, incoming, changed, expanded


def make_case(row: Row) -> Case:
    w, state, sign, capacity, size, op, value = row
    w, size = int(w), int(size)
    cap = CAPACITY[capacity]
    suffix = "[$]" if cap is None else f"[$:{cap - 1}]"
    name = case_name(row)
    operation = {"push_front": "q.push_front(incoming);", "push_back": "q.push_back(incoming);",
                 "insert": "q.insert(q.size() / 2, incoming);", "write_end": "q[q.size()] = incoming;",
                 "pop_front": "removed = q.pop_front();", "pop_back": "removed = q.pop_back();"}[op]
    lines = [f"module {name};", f"  typedef {state} {sign} [{w - 1}:0] word_t;",
             f"  word_t q{suffix};", "  word_t saved[$];",
             f"  logic {sign} [{w}:0] incoming;", f"  logic [{w}:0] removed;", "  initial begin"]
    expected = []
    for phase in (0, 1):
        initial, queue, incoming, changed, popped = reference(row, phase)
        lines.append("    q = {};")
        for bits in initial_values(row, phase):
            lines.append(f"    q.push_back({literal(bits)});")
        lines += ["    saved = q;", f"    incoming = {literal(incoming)};", "    removed = '0;",
                  f'    $display("p{phase}_input=%b", incoming);', "    " + operation,
                  f"    incoming = {literal(changed)};",
                  f'    $display("p{phase}_size=%0d popped=%b source=%b", q.size(), removed, incoming);',
                  f'    foreach (q[i]) $display("p{phase}_q%0d=%b", i, q[i]);',
                  f'    $display("p{phase}_saved_size=%0d", saved.size());',
                  f'    foreach (saved[i]) $display("p{phase}_saved%0d=%b", i, saved[i]);']
        expected += [f"p{phase}_input={incoming}", f"p{phase}_size={len(queue)} popped={popped} source={changed}"]
        expected += [f"p{phase}_q{i}={bits}" for i, bits in enumerate(queue)]
        expected += [f"p{phase}_saved_size={len(initial)}"]
        expected += [f"p{phase}_saved{i}={bits}" for i, bits in enumerate(initial)]
    lines += ["    $finish;", "  end", "endmodule"]
    extra = {"interaction_model": f"{MODEL.name}@{MODEL.version}",
             "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())}
    if cap is not None and size == cap and op not in ("pop_front", "pop_back"):
        extra["expected_stderr_regex"] = r"(?i:\bwarn(?:ing)?\b|%Warning-)"
    primary = {"push_front": "7.10.2.6", "push_back": "7.10.2.7", "insert": "7.10.2.2",
               "write_end": "7.10.1", "pop_front": "7.10.2.4", "pop_back": "7.10.2.5"}[op]
    clauses = [primary, "7.10.1", "6.11.2", "11.8.2"]
    if size:
        clauses.append("7.10.2.7")
    elif op.startswith("pop"):
        clauses.append("7.4.5")
    if cap is not None:
        clauses.append("7.10.5")
    return Case(
        name, "Queue updates preserve typed values, ordering, capacity and independent value copies",
        " ".join(dict.fromkeys(clauses)),
        "Unbounded and bounded queues start empty, partially filled or full. Updates first "
        "act on an unbounded queue, then discard elements beyond the capacity, with a "
        "required warning on overflow. An argument one bit wider than the element tests "
        "truncation and state conversion. Empty pops return the element-type default and "
        "pop results extend using element signedness. Two rotated inputs distinguish "
        "ordering even for one-bit elements. A pre-operation copy and a changed argument "
        "verify that stored values are independent. Every element and size is observed.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=value != "known" or (state == "logic" and size == 0 and op.startswith("pop")),
        extra=extra,
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

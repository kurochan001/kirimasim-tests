"""Receiver dispatch, automatic recursive frames and typed argument aliases."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_class_method"
VERSION = 1
CHAPTER = 8

MODEL = Model(
    "class_method_reference",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("dispatch", ("direct", "base_virtual", "base_nonvirtual")),
     ("kind", ("function", "task")), ("mode", ("input", "ref", "const_ref")),
     ("depth", ("0", "1", "3"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("dispatch", "kind", "mode"),
            ("kind", "mode", "depth"), ("dispatch", "mode", "depth")),
    anchors=(("1", "bit", "known", "direct", "function", "ref", "3"),
             ("129", "logic", "z", "base_virtual", "task", "const_ref", "3"),
             ("65", "logic", "x", "base_nonvirtual", "function", "input", "1"),
             ("33", "bit", "x", "base_virtual", "function", "ref", "0"),
             ("32", "logic", "known", "base_nonvirtual", "task", "ref", "3"),
             ("64", "logic", "known", "direct", "task", "input", "1")),
    constraints=("同一typedefのプロパティと仮引数を用い、型不一致を作らない。"
                 "2個の派生インスタンスをA/B/A順に呼び、基底ハンドル経由のvirtual/非virtualと"
                 "派生ハンドル直呼びを区別。クラスメソッドはautomatic、深さは有限、"
                 "タスクも時間を消費しない。const ref自身には書かず、同じ実体のプロパティを更新。"
                 "未対応では除外しない。配列・並行呼出し・super・時間制御は対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_class_method_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, int, bool]]:
    result = [(f"k{i}", i, False) for i in range(3)]
    if row[2] != "known":
        result += [(f"u{i}", i, True) for i in range(3)]
    return result


def stimulus(row: Row, owner: int, phase: int, unknown: bool) -> dict:
    w, _, value, _, _, _, depth = row
    pattern = ("01" * int(w))[:int(w)]
    inverse = pattern.translate(str.maketrans("01", "10"))
    markers = [pattern if (d + owner + phase) % 2 else inverse for d in range(4)]
    updates = [value * int(w) if unknown and (d + owner + phase) % 2
               else m.translate(str.maketrans("01", "10")) for d, m in enumerate(markers)]
    return {"markers": markers, "updates": updates,
            "initial": value * int(w) if unknown else markers[int(depth)],
            "guard": pattern if (owner + phase) % 2 else inverse}


def stored(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits


def reference(row: Row) -> str:
    """Closed-form frame observations; no generated SV or simulator is evaluated."""
    depth, mode = int(row[6]), row[5]
    tag = 1 if row[3] == "base_nonvirtual" else 2
    output = []
    for label, phase, unknown in phases(row):
        data = {owner: stimulus(row, owner, phase, unknown) for owner in (2, 5)}
        payload = {o: stored(row, data[o]["initial"]) for o in data}
        visits = {2: 0, 5: 0}
        for o in data:
            output.append(f"{label} init owner={o} payload={payload[o]} guard={data[o]['guard']}")
        for index, owner in enumerate((2, 5, 2)):
            f = data[owner]
            updates = [stored(row, v) for v in f["updates"]]
            final = f["markers"][0] if mode == "ref" else updates[0]
            initial = payload[owner]
            for d in range(depth, -1, -1):
                formal = (initial if d == depth else f["markers"][d + 1]) if mode == "input" else updates[d]
                output.append(f"who={tag} owner={owner} d={d} entry={formal} property={updates[d]}")
            for d in range(depth + 1):
                formal = f["markers"][d] if mode == "input" else final
                output.append(f"who={tag} owner={owner} d={d} exit={formal} property={final}")
            visits[owner] += depth + 1
            total = (depth + 1) * (100 * tag + 10 * owner) + depth * (depth + 1) // 2
            payload[owner] = final
            output.append(f"{label} call={index} total={total}")
            for o in data:
                base, leaf = (visits[o], 0) if tag == 1 else (0, visits[o])
                output.append(f"{label} saved owner={o} payload={payload[o]} guard={data[o]['guard']} "
                              f"base={base} leaf={leaf}")
    return "\n".join(output) + "\n"


def method(row: Row, tag: int) -> list[str]:
    kind, mode = row[4:6]
    prefix = "virtual " if row[3] == "base_virtual" else ""
    formal = "const ref" if mode == "const_ref" else mode
    signature = (f"{prefix}function automatic int walk(input int d, {formal} word_t formal);"
                 if kind == "function" else
                 f"{prefix}task automatic walk(input int d, {formal} word_t formal, output int total);")
    counter = "base_visits" if tag == 1 else "leaf_visits"
    lines = ["  " + signature, "    int child;", "    child = 0;", f"    this.{counter}++;",
             "    case (d)"]
    lines += [f"      {d}: this.payload = this.u{d};" for d in range(4)]
    lines += ["    endcase", f'    $display("who={tag} owner=%0d d=%0d entry=%b property=%b",',
              "             this.owner, d, formal, this.payload);"]
    if mode != "const_ref":
        lines += ["    case (d)"] + [f"      {d}: formal = this.m{d};" for d in range(4)]
        lines += ["    endcase"]
    lines += ["    if (d > 0) " + ("child = walk(d - 1, formal);" if kind == "function"
                                     else "walk(d - 1, formal, child);"),
              f'    $display("who={tag} owner=%0d d=%0d exit=%b property=%b",',
              "             this.owner, d, formal, this.payload);"]
    lines += [("    return " if kind == "function" else "    total = ") +
              f"child + {100 * tag} + 10 * this.owner + d;", f"  end{kind}"]
    return lines


def make_case(row: Row) -> Case:
    width, state, value, dispatch, kind, mode, depth = row
    name = case_name(row)
    lines = [f"typedef {state} [{int(width)-1}:0] word_t;", "class base_t;",
             "  word_t payload, guard, u0, u1, u2, u3, m0, m1, m2, m3;",
             "  int owner, base_visits, leaf_visits;"] + method(row, 1)
    lines += ["endclass", "class leaf_t extends base_t;"] + method(row, 2)
    lines += ["endclass", f"module {name};", "  leaf_t a, b;", "  base_t view;", "  int total;",
              "  initial begin", "    a = new; b = new;"]
    for label, phase, unknown in phases(row):
        for handle, owner in (("a", 2), ("b", 5)):
            f = stimulus(row, owner, phase, unknown)
            lines += [f"    {handle}.owner = {owner};",
                      f"    {handle}.base_visits = 0; {handle}.leaf_visits = 0;",
                      f"    {handle}.payload = {literal(f['initial'])};",
                      f"    {handle}.guard = {literal(f['guard'])};"]
            for d in range(4):
                lines += [f"    {handle}.u{d} = {literal(f['updates'][d])};",
                          f"    {handle}.m{d} = {literal(f['markers'][d])};"]
        for handle in ("a", "b"):
            lines += [f'    $display("{label} init owner=%0d payload=%b guard=%b",',
                      f"             {handle}.owner, {handle}.payload, {handle}.guard);"]
        for index, handle in enumerate(("a", "b", "a")):
            target = handle
            if dispatch != "direct":
                lines.append(f"    view = {handle};")
                target = "view"
            call = (f"total = {target}.walk({depth}, {handle}.payload);" if kind == "function"
                    else f"{target}.walk({depth}, {handle}.payload, total);")
            lines += ["    " + call, f'    $display("{label} call={index} total=%0d", total);']
            for other in ("a", "b"):
                lines += [f'    $display("{label} saved owner=%0d payload=%b guard=%b base=%0d leaf=%0d",',
                          f"             {other}.owner, {other}.payload, {other}.guard,",
                          f"             {other}.base_visits, {other}.leaf_visits);"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Class receiver dispatch and automatic recursion preserve value and reference argument semantics",
        "8.6 8.20 13.5.1 13.5.2 13.3.1 13.4.2 6.11.2",
        "Two derived objects with distinct owner IDs are called in A/B/A order. A direct "
        "derived-handle call and a virtual base-handle call execute the leaf body; a "
        "nonvirtual base-handle call executes the base body. Both bodies use inherited "
        "storage, separate visit counters and identical argument types. Each recursive "
        "frame updates its receiver property before observing the formal, then writes "
        "a depth-specific marker unless the formal is const ref. Input formals retain "
        "private copies across recursion; ref and const ref follow the same property. "
        "Const ref is never written through the formal. Entry/exit observations, "
        "depth-sensitive return values and snapshots of both objects detect wrong "
        "dispatch, lost frame state and receiver leakage. Tasks consume no time. "
        "Known controls accompany X/Z stimuli; bit fields convert X/Z to zero. "
        "No arrays, concurrent calls or time controls are part of this model.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

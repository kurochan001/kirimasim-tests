"""Heap-container mutation, level-sensitive wait and typed element comparisons."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_wait"
VERSION = 1
CHAPTER = 9


def allowed(row: Row) -> bool:
    change, condition = row[4:6]
    if change in ("create", "clear"):
        return condition == "size"
    return change != "replace" or condition != "size"


MODEL = Model(
    "container_wait_visibility",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("container", ("dynamic", "queue")),
     ("change", ("create", "grow", "shrink", "clear", "replace")),
     ("condition", ("size", "element", "both")), ("timing", ("waiting", "ready"))),
    allowed,
    groups=(("width", "state", "value"), ("container", "change", "condition"),
            ("change", "condition", "timing"), ("container", "condition", "timing")),
    anchors=(("1", "bit", "known", "queue", "grow", "size", "waiting"),
             ("129", "logic", "z", "dynamic", "replace", "both", "waiting"),
             ("65", "logic", "x", "queue", "shrink", "element", "waiting"),
             ("33", "bit", "x", "dynamic", "create", "size", "ready"),
             ("32", "logic", "known", "queue", "clear", "size", "waiting"),
             ("64", "logic", "known", "dynamic", "grow", "both", "ready")),
    constraints=("空を含むcreate/clearはsize条件だけとし、無効な要素アクセスを作らない。"
                 "同サイズのreplaceはelement/both条件だけとし、待機開始前の条件を偽にする。"
                 "ready行は変更後に待機を開始。動的配列は準備済み配列からnewで置換し、"
                 "キューはpush_front/pop_front/delete/全体代入で変更。未対応では除外しない。"
                 "並行した複数変更・参照引数・連想配列・無効な添字は対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_wait_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, str, str]]:
    w = int(row[0])
    zero, one = "0" * w, "1" * w
    pattern = ("01" * w)[:w]
    result = [("k0", zero, one), ("k1", one, zero),
              ("k2", pattern, pattern.translate(str.maketrans("01", "10")))]
    if row[2] != "known":
        result += [(f"u{i}", guard, row[2] * w)
                   for i, guard in enumerate((zero, one, pattern))]
    return result


def frame(row: Row, guard: str, raw: str) -> dict:
    marker = raw.translate(str.maketrans("xz", "00")) if row[1] == "bit" else raw
    before = (marker.translate(str.maketrans("01", "10")) if set(marker) <= set("01")
              else "1" * len(marker))
    change = row[4]
    initial = {"create": [], "grow": [before], "shrink": [before, marker],
               "clear": [before, guard], "replace": [before, guard]}[change]
    final = {"create": [marker, guard], "grow": [marker, before], "shrink": [marker],
             "clear": [], "replace": [marker, guard]}[change]
    return {"marker": marker, "initial": initial, "final": final}


def reference(row: Row) -> str:
    output = []
    ready = row[6] == "ready"
    for label, guard, raw in phases(row):
        f = frame(row, guard, raw)
        before, final = f["initial"], f["final"]
        output += [f"{label} start={len(before)} raw={raw} marker={f['marker']}",
                   f"{label} noise wake={int(ready)} dt={0 if ready else -1} "
                   f"size={len(final) if ready else len(before)}",
                   f"{label} done wake=1 dt={0 if ready else 3} "
                   f"captured={len(final)} size={len(final)}"]
        output += [f"{label} live{i}={value}" for i, value in enumerate(final)]
        output += [f"{label} saved{i}={value}" for i, value in enumerate(final)]
    return "\n".join(output) + "\n"


def fill(name: str, values: list[str], container: str) -> list[str]:
    if container == "dynamic":
        return [f"    {name} = new[{len(values)}];", *[
            f"    {name}[{i}] = {literal(value)};" for i, value in enumerate(values)]]
    return [f"    {name} = {{}};", *[f"    {name}.push_back({literal(value)});" for value in values]]


def make_case(row: Row) -> Case:
    width, state, value, container, change, condition, timing = row
    w = int(width)
    name = case_name(row)
    dimension = "[]" if container == "dynamic" else "[$]"
    lines = ["`timescale 1ns/1ns", f"module {name};", f"  typedef {state} [{w-1}:0] word_t;",
             f"  word_t cells{dimension}, prepared{dimension}, noise{dimension}, captured{dimension};",
             f"  logic [{w-1}:0] raw_marker;", "  word_t marker, removed;",
             "  int wakes, elapsed, phase_start;", "  initial begin"]
    for label, guard, raw in phases(row):
        f = frame(row, guard, raw)
        target = len(f["final"])
        size = f"cells.size() == {target}"
        pred = {"size": size, "element": "cells[0] === marker",
                "both": f"({size}) && (cells[0] === marker)"}[condition]
        if change == "clear":
            update = "    cells.delete();"
        elif container == "dynamic":
            update = f"    cells = new[{target}](prepared);"
        elif change == "grow":
            update = "    cells.push_front(marker);"
        elif change == "shrink":
            update = "    removed = cells.pop_front();"
        else:
            update = "    cells = prepared;"
        lines += [f"    raw_marker = {literal(raw)};", "    marker = raw_marker;"]
        lines += fill("cells", f["initial"], container) + fill("prepared", f["final"], container)
        lines += fill("noise", [], container) + fill("captured", [], container)
        lines += ["    wakes = 0; elapsed = -1; phase_start = $time;",
                  f'    $display("{label} start=%0d raw=%b marker=%b", cells.size(), raw_marker, marker);']
        if timing == "ready":
            lines.append(update)
        lines += ["    fork", "      begin", f"        wait ({pred});",
                  "        wakes++; elapsed = $time - phase_start;", "        captured = cells;",
                  "      end", "    join_none", "    #1;",
                  f"    noise = {'new['+str(target)+'](prepared)' if container=='dynamic' else 'prepared'};",
                  "    #1;", f'    $display("{label} noise wake=%0d dt=%0d size=%0d",',
                  "             wakes, elapsed, cells.size());", "    #1;"]
        if timing == "waiting":
            lines.append(update)
        lines += ["    #1;", f'    $display("{label} done wake=%0d dt=%0d captured=%0d size=%0d",',
                  "             wakes, elapsed, captured.size(), cells.size());",
                  f'    foreach (cells[i]) $display("{label} live%0d=%b", i, cells[i]);',
                  f'    foreach (captured[i]) $display("{label} saved%0d=%b", i, captured[i]);',
                  "    disable fork;", "    #1;"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Wait resumes on typed container changes and ignores changes to an unrelated container",
        "9.4.3 9.3.2 7.5.1 7.5.2 7.5.3 7.10.1 7.10.2.1 7.10.2.3 "
        "7.10.2.4 7.10.2.6 6.11.2 11.4.5 11.4.7",
        "The wait predicate observes size, the first element with case equality, or "
        "both. It is initially false except in ready rows, which perform the matching "
        "change before starting the child. After a join_none yields, an unrelated "
        "container changes at +1; the +2 report must show no premature wake. The "
        "watched container changes at +3 and is reported at +4. Each waiter records "
        "elapsed time and a value copy of the container. Dynamic arrays are replaced "
        "using a prepared initializer; queues grow/shrink with one push_front or "
        "pop_front, clear with delete, or are assigned as a whole. Element reads "
        "are restricted to rows whose containers stay nonempty. Known controls and "
        "X/Z markers distinguish exact comparison from logical equality and bit "
        "conversion. Fork children are cancelled after the bounded report so a missed "
        "notification produces an output difference rather than a timeout. The test "
        "observes resumption, not the number of internal predicate evaluations.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

"""Looped assignment dependencies, NBA ordering and instance-local storage."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_loop_nba"
VERSION = 1
CHAPTER = 10

MODEL = Model(
    "loop_assignment_order",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("loop", ("for", "while", "repeat")), ("count", ("2", "3", "5")),
     ("storage", ("scalar", "same", "rotate")), ("update", ("blocking", "nba")),
     ("home", ("module", "interface"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("loop", "count", "storage"),
            ("count", "storage", "update"), ("home", "storage", "update"),
            ("loop", "count", "update")),
    anchors=(("1", "bit", "known", "for", "2", "scalar", "nba", "module"),
             ("129", "logic", "z", "repeat", "5", "rotate", "nba", "interface"),
             ("65", "logic", "x", "while", "3", "same", "blocking", "interface"),
             ("33", "bit", "x", "for", "5", "rotate", "blocking", "module"),
             ("32", "logic", "known", "while", "2", "same", "nba", "interface"),
             ("64", "logic", "known", "repeat", "3", "scalar", "blocking", "module")),
    constraints=("全行は合法。NBAの左辺は静的なスカラまたは固定配列要素だけとし、"
                 "automaticタスクは右辺の一時値と添字を計算する。"
                 "固定配列は[2:4]、sameは添字2、rotateは2+(i%3)。"
                 "同じプロセスからA/B/A順に呼び、競合する別の書込み元を置かない。"
                 "Activeでの観測後に1 tick進めてNBA完了後を観測する。"
                 "未対応による除外なし。遅延付きNBA、動的配列、並行書込み、modportは対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_loop_nba_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, int, bool]]:
    result = [(f"k{i}", i, False) for i in range(3)]
    if row[2] != "known":
        result += [(f"u{i}", i, True) for i in range(3)]
    return result


def patterns(width: int) -> tuple[str, ...]:
    return "0" * width, "1" * width, ("10" * width)[:width]


def initial(row: Row, phase: int, owner: int) -> tuple[list[str], str]:
    p = patterns(int(row[0]))
    bias = int(owner == 5)
    count = 1 if row[5] == "scalar" else 3
    return [p[(phase + bias + i) % 3] for i in range(count)], p[(phase + bias + 2) % 3]


def raw_mask(row: Row, phase: int, unknown: bool, owner: int, call: int, i: int) -> str:
    if unknown and (i + call) % 2 == 0:
        return row[2] * int(row[0])
    zero, one, alternate = patterns(int(row[0]))
    return (one, alternate, zero)[(i + phase + int(owner == 5) + call) % 3]


def stored(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits


def xor(a: str, b: str) -> str:
    return "".join(str(int(x) ^ int(y)) if x in "01" and y in "01" else "x"
                   for x, y in zip(a, b))


def snapshot(label: str, stage: str, owner: int, words: list[str], guard: str,
             calls: int, count: int) -> list[str]:
    return [f"{label} {stage} owner={owner} calls={calls} issued={calls * count} guard={guard}",
            *[f"{label} {stage} owner={owner} word{i}={v}" for i, v in enumerate(words)]]


def reference(row: Row) -> str:
    """NBA writes retain only the last value per location; blocking uses feedback."""
    output = []
    count, storage, update = int(row[4]), row[5], row[6]
    for stamp, (label, phase, unknown) in enumerate(phases(row)):
        data = {o: initial(row, phase, o) for o in (2, 5)}
        active = {o: list(data[o][0]) for o in data}
        latest, calls = {}, {2: 0, 5: 0}
        for call, owner in enumerate((2, 5, 2)):
            calls[owner] += 1
            for i in range(count):
                slot = i % 3 if storage == "rotate" else 0
                index = 0 if storage == "scalar" else 2 + slot
                raw = raw_mask(row, phase, unknown, owner, call, i)
                mask = stored(row, raw)
                old = active[owner][slot]
                output.append(f"phase={stamp} owner={owner} call={calls[owner]} step={i} "
                              f"index={index} old={old} raw={raw} mask={mask}")
                result = stored(row, xor(old, mask))
                if update == "blocking":
                    active[owner][slot] = result
                else:
                    latest[owner, slot] = result
        for o in data:
            output += snapshot(label, "active", o, active[o], data[o][1], calls[o], count)
        final = {o: list(active[o]) for o in data}
        for (owner, slot), value in latest.items():
            final[owner][slot] = value
        for o in data:
            output += snapshot(label, "settled", o, final[o], data[o][1], calls[o], count)
    return "\n".join(output) + "\n"


def make_case(row: Row) -> Case:
    width, state, value, loop, count, storage, update, home = row
    w, n, name = int(width), int(count), case_name(row)
    target = "target" if storage == "scalar" else "target[index]"
    lines = ["`timescale 1ns/1ns", f"{home} loop_worker #(parameter int OWNER = 2);",
             f"  typedef {state} [{w-1}:0] word_t;", "  word_t guard;",
             "  word_t target;" if storage == "scalar" else "  word_t target[2:4];",
             f"  logic [{w-1}:0] raw0, raw1, raw2, raw3, raw4;", "  int calls, issued;",
             "  task automatic issue(input int stamp);", "    int i, index;",
             f"    logic [{w-1}:0] raw;", "    word_t captured;", "    calls++; i = 0;"]
    lines += [{"for": f"    for (i = 0; i < {n}; i++) begin",
               "while": f"    while (i < {n}) begin", "repeat": f"    repeat ({n}) begin"}[loop],
              "      index = " + ("2 + (i % 3);" if storage == "rotate" else
                                   "2;" if storage == "same" else "0;"),
              "      case (i)"]
    lines += [f"        {i}: raw = raw{i};" for i in range(5)]
    lines += ["      endcase", "      captured = raw;", "      issued++;",
              '      $write("phase=%0d owner=%0d call=%0d step=%0d index=%0d",',
              "             stamp, OWNER, calls, i, index);",
              f'      $display(" old=%b raw=%b mask=%b", {target}, raw, captured);',
              f"      {target} {'<=' if update == 'nba' else '='} {target} ^ captured;"]
    if loop != "for":
        lines.append("      i++;")
    lines += ["    end", "  endtask", f"end{home}", f"module {name};",
              "  loop_worker #(.OWNER(2)) a();", "  loop_worker #(.OWNER(5)) b();", "  initial begin"]
    for stamp, (label, phase, unknown) in enumerate(phases(row)):
        for handle, owner in (("a", 2), ("b", 5)):
            words, guard = initial(row, phase, owner)
            lines += [f"    {handle}.calls = 0; {handle}.issued = 0;",
                      f"    {handle}.guard = {literal(guard)};"]
            for slot, word in enumerate(words):
                destination = f"{handle}.target" + ("" if storage == "scalar" else f"[{slot+2}]")
                lines.append(f"    {destination} = {literal(word)};")
        for call, (handle, owner) in enumerate((("a", 2), ("b", 5), ("a", 2))):
            for i in range(5):
                lines.append(f"    {handle}.raw{i} = {literal(raw_mask(row, phase, unknown, owner, call, i))};")
            lines += [f"    {handle}.issue({stamp});"]
            lines += [f"    {handle}.raw{i} = '0;" for i in range(5)]
        for stage in ("active", "settled"):
            if stage == "settled":
                lines.append("    #1;")
            for handle, owner in (("a", 2), ("b", 5)):
                lines += [f'    $display("{label} {stage} owner={owner} calls=%0d issued=%0d guard=%b",',
                          f"             {handle}.calls, {handle}.issued, {handle}.guard);"]
                for slot in range(1 if storage == "scalar" else 3):
                    source = f"{handle}.target" + ("" if storage == "scalar" else f"[{slot+2}]")
                    lines.append(f'    $display("{label} {stage} owner={owner} word{slot}=%b", {source});')
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Looped blocking and nonblocking updates preserve feedback, write order and instance identity",
        "10.4.1 10.4.2 12.7.1 12.7.2 12.7.4 25.3 4.4.2.2 4.4.2.4 6.11.2 7.4.1 13.5.1",
        "Two module or interface instances own static scalar or fixed-array targets. "
        "One process invokes their automatic issue tasks in A/B/A order. Each loop "
        "iteration assigns target XOR a typed mask back to the selected location. "
        "Blocking assignments feed earlier results into subsequent iterations; NBA "
        "right-hand sides read the old target and the last queued write to each "
        "location wins. Traces record the iteration, captured index, old target and "
        "raw/typed mask. The mask fields are overwritten after every task return. "
        "Active and next-tick snapshots observe all target elements, counters and "
        "untouched guards of both instances. No NBA target has automatic lifetime. "
        "Known phases accompany X/Z inputs, whose bit conversion occurs before XOR. "
        "Array indices are always valid. There are no delayed NBAs, dynamic arrays, "
        "concurrent writers or modports in this model.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

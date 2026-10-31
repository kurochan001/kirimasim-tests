"""Early function return across loop forms and lexical state ownership."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_return"
VERSION = 1
CHAPTER = 13

MODEL = Model(
    "function_loop_return",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("loop", ("for", "while", "repeat")),
     ("stop", ("head", "middle", "tail", "none")), ("scope", ("local", "package"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("loop", "stop", "scope"),
            ("state", "value", "stop"), ("loop", "value", "stop")),
    anchors=(("1", "bit", "known", "for", "head", "local"),
             ("129", "logic", "z", "repeat", "none", "package"),
             ("65", "logic", "x", "while", "middle", "local"),
             ("33", "bit", "x", "repeat", "tail", "package"),
             ("32", "logic", "known", "while", "none", "package"),
             ("64", "logic", "known", "for", "middle", "local")),
    constraints=("同じ幅・状態型のinputと戻り値を用い、0から幅未満までLSBから走査する。"
                 "幅1のhead/middle/tailは同じ位置になる合法な境界条件として保持。"
                 "!==0でX/Zも停止対象とし、bitへの変換による走査継続を区別。"
                 "2インスタンスをA/B/A順に呼び、localの個別状態とpackageの共有状態を観測。"
                 "未対応による除外なし。再帰・break/continue・並行呼出し・時間制御は対象外",),
)

COUNTERS = ("calls", "scanned", "weight", "tails", "dead", "last")


def case_name(row: Row) -> str:
    return "test_gen_cross_return_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, int, bool]]:
    result = [(f"k{i}", i, False) for i in range(3)]
    if row[2] != "known":
        result += [(f"u{i}", i, True) for i in range(3)]
    return result


def stimulus(row: Row, phase: int, unknown: bool, owner: int) -> tuple[str, str]:
    width, _, value, _, stop, _ = row
    w = int(width)
    position = {"head": 0, "middle": w // 2, "tail": w - 1, "none": None}[stop]
    if position is not None and owner == 5:
        position = w - 1 - position
    bits = ["0"] * w  # Indexed from the least significant bit.
    if position is not None:
        bits[position] = value if unknown else "1"
        for i in range(position + 1, w):
            bits[i] = "0" if phase == 0 else "1" if phase == 1 else str((i + owner) % 2)
    backup = value * w if unknown else (
        "1" * w if phase == 0 else "".join(str((i + owner + phase) % 2) for i in range(w)))
    return "".join(reversed(bits)), backup


def stored(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits


def initial(row: Row, owner: int) -> dict:
    shadow = row[5] == "package" and owner != 0
    values = [100 + owner, 200 + owner, 300 + owner, 400 + owner, 500 + owner, -600 - owner]
    result = dict(zip(COUNTERS, values if shadow else [0, 0, 0, 0, 0, -9]))
    result["guard"] = "".join(str((i + owner) % 2) for i in range(int(row[0])))
    result["runs"] = 0
    return result


def snapshot(label: str, name: str, state: dict) -> str:
    return f"{label} {name} " + " ".join(f"{k}={state[k]}" for k in COUNTERS) + (
        f" runs={state['runs']} guard={state['guard']}")


def reference(row: Row) -> str:
    """Find the first nonzero character, then derive counts algebraically."""
    output = []
    for label, phase, unknown in phases(row):
        states = {o: initial(row, o) for o in (2, 5, 0)}
        for index, owner in enumerate((2, 5, 2)):
            raw, backup = stimulus(row, phase, unknown, owner)
            data, backup = stored(row, raw), stored(row, backup)
            candidates = [i for i, bit in enumerate(reversed(data)) if bit != "0"]
            hit = min(candidates) if candidates else -1
            count = hit + 1 if hit >= 0 else len(data)
            target = states[0 if row[5] == "package" else owner]
            target["calls"] += 1
            target["scanned"] += count
            target["weight"] += count * (count + 1) // 2
            target["tails"] += int(hit < 0)
            target["last"] = hit
            states[owner]["runs"] += 1
            answer = data if hit >= 0 else backup
            output.append(f"{label} call={index} owner={owner} input={data} answer={answer}")
            output += [snapshot(label, name, states[o]) for name, o in (("a", 2), ("b", 5), ("pkg", 0))]
    return "\n".join(output) + "\n"


def function(row: Row) -> list[str]:
    w, loop = int(row[0]), row[3]
    lines = ["  function automatic word_t pick(input word_t data, input word_t backup);",
             "    int i;", "    calls++; last = -2;", "    i = 0;"]
    lines += [{"for": f"    for (i = 0; i < {w}; i++) begin",
               "while": f"    while (i < {w}) begin", "repeat": f"    repeat ({w}) begin"}[loop],
              "      scanned++; weight += i + 1;", "      if (data[i] !== 1'b0) begin",
              "        last = i;", "        return data;", "        dead++;", "      end"]
    if loop != "for":
        lines.append("      i++;")
    lines += ["    end", "    tails++; last = -1;", "    return backup;", "    dead += 1000;", "  endfunction"]
    return lines


def make_case(row: Row) -> Case:
    width, state, value, loop, stop, scope = row
    w, name = int(width), case_name(row)
    fields = ["  int calls, scanned, weight, tails, dead, last;", "  int runs;", "  word_t guard;"]
    lines = ["package return_pkg;", f"  typedef {state} [{w-1}:0] word_t;"] + fields
    if scope == "package":
        lines += function(row)
    lines += ["endpackage", "module return_worker;", "  import return_pkg::word_t;"] + fields
    lines += ["  word_t observed_data, answer;"]
    if scope == "local":
        lines += function(row)
    lines += ["  task automatic invoke(input word_t data, input word_t backup);", "    runs++;",
              "    observed_data = data;",
              f"    answer = {'return_pkg::' if scope == 'package' else ''}pick(data, backup);",
              "  endtask", "endmodule", f"module {name};", "  import return_pkg::*;",
              "  return_worker a(), b();",
              "  initial begin"]
    for label, phase, unknown in phases(row):
        for target, owner in (("a", 2), ("b", 5), ("return_pkg::", 0)):
            prefix = "" if owner == 0 else target + "."
            values = initial(row, owner)
            lines += [f"    {prefix}{key} = {values[key]};" for key in (*COUNTERS, "runs")]
            lines.append(f"    {prefix}guard = {literal(values['guard'])};")
        for index, (target, owner) in enumerate((("a", 2), ("b", 5), ("a", 2))):
            data, backup = stimulus(row, phase, unknown, owner)
            lines += [f"    {target}.invoke({literal(data)}, {literal(backup)});",
                      f'    $display("{label} call={index} owner={owner} input=%b answer=%b",',
                      f"             {target}.observed_data, {target}.answer);"]
            for display, prefix in (("a", "a."), ("b", "b."), ("pkg", "return_pkg::")):
                lines += [f'    $write("{label} {display} calls=%0d scanned=%0d weight=%0d tails=%0d",',
                          f"           {prefix}calls, {prefix}scanned, {prefix}weight, {prefix}tails);",
                          '    $display(" dead=%0d last=%0d runs=%0d guard=%b",',
                          f"             {prefix}dead, {prefix}last, {prefix}runs, {prefix}guard);"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Early function return stops loop effects and preserves local or package-owned state",
        "13.4.1 12.8 12.7.1 12.7.2 12.7.4 26.3 6.11.2 11.4.5",
        "A function scans a typed word from its LSB with for, while or repeat. Case "
        "inequality against zero treats X/Z as a hit in logic, while bit input "
        "conversion can continue scanning or fall through. Each visited index "
        "updates both a count and an index weight. An early return records the "
        "index and returns the input; full traversal records a tail and returns "
        "a backup. Statements following either return must never execute. Two "
        "worker instances invoke the function in A/B/A order. Local functions "
        "update separate instance counters; a package function updates shared "
        "package counters and must ignore same-named caller variables seeded "
        "with sentinels. Every call reports the typed input, answer, all counters "
        "and untouched guards. Known phases accompany every X/Z row. No "
        "recursion, break/continue, concurrent calls or time controls are used.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

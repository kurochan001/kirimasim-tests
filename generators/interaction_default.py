"""Default argument evaluation, named/empty arguments and declaring-instance scope."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_default"
VERSION = 1
CHAPTER = 13

MODEL = Model(
    "default_argument_scope",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("home", ("module", "interface")), ("expression", ("variable", "function")),
     ("passing", ("omitted", "empty_data", "named_data", "explicit_zero", "named_both"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("home", "expression", "passing"),
            ("state", "value", "passing"), ("home", "passing", "value"),
            ("expression", "state", "value")),
    anchors=(("1", "bit", "known", "module", "variable", "omitted"),
             ("129", "logic", "z", "interface", "function", "empty_data"),
             ("65", "logic", "x", "module", "function", "named_data"),
             ("33", "bit", "x", "interface", "variable", "named_both"),
             ("32", "logic", "known", "interface", "function", "explicit_zero"),
             ("64", "logic", "known", "module", "function", "omitted")),
    constraints=("全720行は合法。同じ型のinputと戻り値を用い、ANSI形式の2引数に既定値を定義する。"
                 "呼出し元と2インスタンスに同名の変数・関数を用意する。A/B/A順に呼び、"
                 "既定値の元を各呼出し前に更新する。2個の既定値関数は別々のカウンタだけを増やし、"
                 "引数評価順序に依存する刺激・観測を作らない。未対応による除外なし。"
                 "class・virtual interface・output/inout/ref・時間制御・再帰は対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_default_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, int, bool]]:
    result = [(f"k{i}", i, False) for i in range(3)]
    if row[2] != "known":
        result += [(f"u{i}", i, True) for i in range(3)]
    return result


def stimulus(row: Row, phase: int, unknown: bool, owner: str, call: int) -> tuple[str, str]:
    w = int(row[0])
    p = ("0" * w, "1" * w, ("10" * w)[:w])
    offset = (phase + int(owner == "b") + call) % 3
    data, mask = list(p[offset]), list(p[(offset+1) % 3])
    if unknown:
        for i in {0, w // 2, w - 1}:
            data[i] = row[2]
        mask[(w-1) // 3] = row[2]
    return "".join(data), "".join(mask)


def stored(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits


def poison(bits: str) -> str:
    return "".join("0" if bit == "1" else "1" for bit in bits)


def defaults(passing: str) -> tuple[bool, bool]:
    return passing in ("omitted", "empty_data"), passing in ("omitted", "named_data")


def xor(data: str, mask: str) -> str:
    return "".join(str(int(x) ^ int(y)) if x in "01" and y in "01" else "x"
                   for x, y in zip(data, mask))


def reference(row: Row) -> str:
    output = []
    w, expression, passing = int(row[0]), row[4], row[5]
    use_data, use_mask = defaults(passing)
    for label, phase, unknown in phases(row):
        states = {o: dict(calls=0, data_reads=0, mask_reads=0, source="0"*w, mask_source="0"*w)
                  for o in ("a", "b")}
        for call, owner in enumerate(("a", "b", "a")):
            s = states[owner]
            raw_data, raw_mask = stimulus(row, phase, unknown, owner, call)
            s["source"], s["mask_source"] = stored(row, raw_data), stored(row, raw_mask)
            caller_data, caller_mask = poison(s["source"]), poison(s["mask_source"])
            data = s["source"] if use_data else "0"*w if passing == "explicit_zero" else caller_data
            mask = s["mask_source"] if use_mask else "0"*w if passing == "explicit_zero" else caller_mask
            s["calls"] += 1
            s["data_reads"] += int(expression == "function" and use_data)
            s["mask_reads"] += int(expression == "function" and use_mask)
            answer = stored(row, xor(data, mask))
            output.append(f"{label} call={call} owner={owner} return={answer} data={data} mask={mask}")
            for o, state in states.items():
                output.append(f"{label} {o} calls={state['calls']} data_reads={state['data_reads']} "
                              f"mask_reads={state['mask_reads']} source={state['source']} "
                              f"mask_source={state['mask_source']}")
            output.append(f"{label} caller data_reads=0 mask_reads=0 source={caller_data} mask_source={caller_mask}")
    return "\n".join(output) + "\n"


def call_expression(passing: str, owner: str) -> str:
    args = {"omitted": "", "empty_data": ", mask_source", "named_data": ".data_arg(source)",
            "explicit_zero": "'0, '0", "named_both": ".mask_arg(mask_source), .data_arg(source)"}[passing]
    return f"{owner}.pick({args})"


def getters(indent: str = "  ") -> list[str]:
    return [f"{indent}function automatic word_t read_data();", f"{indent}  data_reads++;",
            f"{indent}  return source;", f"{indent}endfunction",
            f"{indent}function automatic word_t read_mask();", f"{indent}  mask_reads++;",
            f"{indent}  return mask_source;", f"{indent}endfunction"]


def make_case(row: Row) -> Case:
    width, state, value, home, expression, passing = row
    w, name = int(width), case_name(row)
    data_default = "source" if expression == "variable" else "read_data()"
    mask_default = "mask_source" if expression == "variable" else "read_mask()"
    lines = [f"typedef {state} [{w-1}:0] word_t;", f"{home} default_worker;",
             "  word_t source = '0, mask_source = '0;", "  word_t seen_data = '0, seen_mask = '0;",
             "  int calls = 0, data_reads = 0, mask_reads = 0;", *getters(),
             f"  function automatic word_t pick(input word_t data_arg = {data_default},",
             f"                                 input word_t mask_arg = {mask_default});",
             "    calls++; seen_data = data_arg; seen_mask = mask_arg;",
             "    return data_arg ^ mask_arg;", "  endfunction", f"end{home}",
             f"module {name};", "  default_worker a(), b();", "  word_t source, mask_source, result;",
             "  int data_reads = 0, mask_reads = 0;", *getters(), "  initial begin"]
    for label, phase, unknown in phases(row):
        lines += ["    data_reads = 0; mask_reads = 0;"]
        for owner in ("a", "b"):
            lines += [f"    {owner}.calls = 0; {owner}.data_reads = 0; {owner}.mask_reads = 0;",
                      f"    {owner}.source = '0; {owner}.mask_source = '0;"]
        for call, owner in enumerate(("a", "b", "a")):
            data, mask = stimulus(row, phase, unknown, owner, call)
            lines += [f"    {owner}.source = {literal(data)};", f"    {owner}.mask_source = {literal(mask)};",
                      f"    source = {literal(poison(stored(row, data)))};",
                      f"    mask_source = {literal(poison(stored(row, mask)))};",
                      f"    result = {call_expression(passing, owner)};",
                      f'    $display("{label} call={call} owner={owner} return=%b data=%b mask=%b",',
                      f"             result, {owner}.seen_data, {owner}.seen_mask);"]
            for target in ("a", "b"):
                lines += [f'    $write("{label} {target} calls=%0d data_reads=%0d mask_reads=%0d",',
                          f"           {target}.calls, {target}.data_reads, {target}.mask_reads);",
                          f'    $display(" source=%b mask_source=%b", {target}.source, {target}.mask_source);']
            lines += [f'    $write("{label} caller data_reads=%0d mask_reads=%0d", data_reads, mask_reads);',
                      '    $display(" source=%b mask_source=%b", source, mask_source);']
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Default arguments use current declaring-instance values only when omitted or empty",
        "13.5.3 13.5.4 13.5.1 13.4.1 23.6 25.3 6.11.2",
        "One process calls two module or interface functions in A/B/A order. Before "
        "each call, it changes that instance's default source fields and sets "
        "same-named caller fields to different known values. Defaults read the "
        "declaring instance, not the caller, at each call. Function defaults "
        "increment independent data/mask read counters; caller functions with "
        "the same names must never run. Empty positional and omitted named "
        "arguments select defaults; explicit zero and explicit named actuals "
        "suppress them. The function saves both formals as well as returning "
        "their XOR, so two wrong defaults cannot cancel unnoticed. Both "
        "instances' sources and counters are observed after every call. Default "
        "getters do not change each other's inputs or counters, avoiding any "
        "dependence on argument evaluation order. Known controls accompany X/Z "
        "inputs; bit conversion occurs when source fields are assigned. No class, "
        "virtual interface, reference/output arguments, time control or recursion is used.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

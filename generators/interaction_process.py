"""Implicit process sensitivity, latch retention and interface-local functions."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_process"
VERSION = 1
CHAPTER = 9


def legal(row: Row) -> bool:
    return (row[3] == "latch") == (row[7] == "hold")


MODEL = Model(
    "implicit_process_visibility",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("process", ("comb", "latch")), ("access", ("direct", "function")),
     ("home", ("module", "interface")), ("gate", ("zero", "one", "x", "z")),
     ("idle", ("zero", "one", "hold"))),
    legal,
    groups=(("width", "state", "value"), ("home", "access", "process"),
            ("process", "gate", "idle"), ("state", "value", "gate"),
            ("access", "gate", "process")),
    anchors=(("1", "bit", "known", "comb", "direct", "module", "zero", "zero"),
             ("129", "logic", "z", "latch", "function", "interface", "x", "hold"),
             ("65", "logic", "x", "comb", "function", "interface", "z", "one"),
             ("33", "bit", "x", "latch", "direct", "module", "one", "hold"),
             ("32", "logic", "known", "latch", "function", "module", "zero", "hold"),
             ("64", "logic", "known", "comb", "direct", "interface", "one", "one")),
    constraints=("combは無効時の出力をzero/oneへ代入し、latchだけがholdを選ぶ。"
                 "入力の宣言時初期化を終えてから時刻0の自動実行を観測。"
                 "各刺激で変えるのは1インスタンスの1変数だけで、1 tick後に両方を観測する。"
                 "評価回数は単一プロセス内でだけ更新し、誤った自己再実行でも512回で止まる。"
                 "functionは引数なしで同じインスタンスのdata/maskを読む。未対応による除外なし。"
                 "並行ドライバ・遅延関数・動的添字・フィードバックを持つデータパスは対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_process_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, int, bool]]:
    result = [(f"k{i}", i, False) for i in range(3)]
    if row[2] != "known":
        result += [(f"u{i}", i, True) for i in range(3)]
    return result


def steps(row: Row, phase: int, unknown: bool) -> list[tuple[str, str, str]]:
    w = int(row[0])
    p = ("0" * w, "1" * w, ("10" * w)[:w])
    raw = row[2] * w
    gate = {"zero": "0", "one": "1", "x": "x", "z": "z"}[row[6]]
    other = {"0": "1", "1": "0", "x": "z", "z": "x"}[gate]
    return [("a", "en", "1"), ("b", "en", "1"),
            ("a", "data", p[phase]), ("b", "data", p[(phase+1) % 3]),
            ("a", "mask", raw if unknown else p[(phase+2) % 3]),
            ("b", "mask", raw if unknown else p[phase]),
            ("a", "en", gate), ("b", "en", other),
            ("a", "data", raw if unknown else p[(phase+1) % 3]),
            ("b", "data", raw if unknown else p[(phase+2) % 3]),
            ("a", "mask", p[(phase+1) % 3]), ("b", "mask", p[(phase+2) % 3]),
            ("a", "noise", "flip"), ("b", "noise", "flip"),
            ("a", "en", "1"), ("b", "en", "1")]


def stored(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits


def computed(data: str, mask: str) -> str:
    return "".join(str(int(x) ^ int(y)) if x in "01" and y in "01" else "x"
                   for x, y in zip(data, mask))


def snapshot(label: str, owner: str, state: dict) -> str:
    return f"{label} {owner} " + " ".join(f"{k}={state[k]}" for k in ("en", "data", "mask", "q", "noise", "events"))


def reference(row: Row) -> str:
    w = int(row[0])
    states = {o: dict(en="1", data="0" * w, mask="1" * w, q="1" * w,
                      noise="0" * w, events=1) for o in ("a", "b")}
    output = [snapshot("start", o, s) for o, s in states.items()]
    for label, phase, unknown in phases(row):
        for index, (owner, field, raw) in enumerate(steps(row, phase, unknown)):
            s = states[owner]
            value = (s[field].translate(str.maketrans("01", "10")) if raw == "flip" else
                     raw if field == "en" else stored(row, raw))
            changed = value != s[field]
            s[field] = value
            if changed and field in ("en", "data", "mask"):
                s["events"] += 1
                if s["en"] == "1":
                    s["q"] = stored(row, computed(s["data"], s["mask"]))
                elif row[3] == "comb":
                    s["q"] = ("0" if row[7] == "zero" else "1") * w
            output += [snapshot(f"{label}_{index}", o, state) for o, state in states.items()]
    return "\n".join(output) + "\n"


def make_case(row: Row) -> Case:
    width, state, value, process, access, home, gate, idle = row
    w, name = int(width), case_name(row)
    lines = ["`timescale 1ns/1ns", f"{home} process_worker;", f"  typedef {state} [{w-1}:0] word_t;",
             "  word_t data = '0, mask = '1, noise = '0;", "  word_t q;", "  logic en = 1'b1;",
             "  int events = 0;"]
    if access == "function":
        lines += ["  function automatic word_t compute();", "    return data ^ mask;", "  endfunction"]
    expr = "compute()" if access == "function" else "data ^ mask"
    operator = "<=" if process == "latch" else "="
    lines += [f"  always_{process} begin", "    if (events < 512) events++;",
              f"    if (en) q {operator} {expr};"]
    if process == "comb":
        lines.append(f"    else q = '{'0' if idle == 'zero' else '1'};")
    lines += ["  end", f"end{home}", f"module {name};", "  process_worker a(), b();", "  initial begin", "    #1;"]

    def observe(label):
        result = []
        for owner in ("a", "b"):
            result += [f'    $write("{label} {owner} en=%b data=%b mask=%b",',
                       f"           {owner}.en, {owner}.data, {owner}.mask);",
                       f'    $display(" q=%b noise=%b events=%0d", {owner}.q, {owner}.noise, {owner}.events);']
        return result

    lines += observe("start")
    for label, phase, unknown in phases(row):
        for index, (owner, field, raw) in enumerate(steps(row, phase, unknown)):
            operand = f"~{owner}.{field}" if raw == "flip" else literal(raw)
            lines += [f"    {owner}.{field} = {operand};", "    #1;"] + observe(f"{label}_{index}")
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Implicit combinational and latch sensitivity includes function reads and preserves instance-local state",
        "9.2.2.2 9.2.2.2.1 9.2.2.3 25.3 13.4.1 12.4 6.11.2",
        "Both instances start with declaration-initialized enable/data/mask and "
        "must execute once at time zero. Each later step changes one field of one "
        "instance and observes both after one tick. An argument-free automatic "
        "function, when selected, reads that instance's data and mask; these reads "
        "must enter the implicit sensitivity list even while enable is false. A "
        "bounded execution counter is written only by the implicit process and "
        "must not trigger itself. Noise is unreferenced and cannot wake it. A "
        "comb process assigns zero or one when enable is 0/X/Z; a latch retains "
        "its previous result and uses NBA when open. Each phase reopens both "
        "instances. Raw X/Z inputs convert to zero for bit storage before XOR. "
        "There are no parallel drivers, delayed functions or data-path feedback.",
        "\n".join(lines), reference(row), fourstate=value != "known" or gate in ("x", "z"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

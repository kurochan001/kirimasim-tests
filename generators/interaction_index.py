"""Cross variable bit indices with range origin/direction and state type.

11.5.1 evaluates the index in a self-determined context. Invalid reads
return X for logic and zero for bit; invalid writes leave every bit intact.
A signed negative index differs from the same unsigned 16-bit encoding.
"""

from common import Case
from interaction_bits import pattern, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_index"
VERSION = 1
CHAPTER = 11

MODEL = Model(
    "variable_bit_index",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("origin", ("zero", "offset", "negative")),
     ("direction", ("ascending", "descending")), ("state", ("bit", "logic")),
     ("index_sign", ("unsigned", "signed")),
     ("index", ("low", "high", "middle", "before", "after", "x", "z")),
     ("value", ("known", "x", "z"))),
    lambda r: r[0] != "1" or r[5] not in ("high", "middle"),
    groups=(("width", "state", "value"), ("origin", "index_sign", "index"),
            ("direction", "index", "state")),
    anchors=(("129", "negative", "descending", "logic", "unsigned", "high", "z"),
             ("65", "offset", "ascending", "logic", "signed", "middle", "x"),
             ("33", "negative", "ascending", "logic", "signed", "low", "known"),
             ("1", "zero", "descending", "bit", "signed", "z", "known")),
    constraints=("範囲は0始点・5始点・全添字が負の3種。インデックスは16ビットのlogic。"
                 "幅1のhigh/middleはlowと同じなので除外。全ケースで読み取りと書き込みを確認",),
)


def case_name(row: Row) -> str:
    w, origin, direction, state, sign, index, value = row
    return f"test_gen_cross_index_w{w}_{origin[0]}_{direction[0]}_{state[0]}_{sign[0]}_{index}_{value}"


def bounds(row: Row) -> tuple[int, int]:
    w, origin = int(row[0]), row[1]
    low = {"zero": 0, "offset": 5, "negative": -w}[origin]
    return low, low + w - 1


def index_bits(row: Row) -> str:
    low, high = bounds(row)
    kind = row[5]
    if kind in ("x", "z"):
        return kind * 16
    n = {"low": low, "high": high, "middle": low + int(row[0]) // 2,
         "before": low - 1, "after": high + 1}[kind]
    return f"{n & 65535:016b}"


def position(row: Row) -> int | None:
    bits = index_bits(row)
    if any(c in "xz" for c in bits):
        return None
    n = int(bits, 2)
    if row[4] == "signed" and bits[0] == "1":
        n -= 65536
    low, high = bounds(row)
    if not low <= n <= high:
        return None
    return n - low if row[2] == "ascending" else high - n


def reference(row: Row) -> tuple[str, str, str, str, str]:
    initial = pattern(int(row[0]), "known")
    p = position(row)
    default = "0" if row[3] == "bit" else "x"
    before = initial[p] if p is not None else default
    incoming = (str(1 - int(initial[p])) if p is not None else "0") \
        if row[-1] == "known" else row[-1]
    stored = two_state(incoming) if row[3] == "bit" else incoming
    result = initial if p is None else initial[:p] + stored + initial[p + 1:]
    after = result[p] if p is not None else default
    return initial, before, incoming, result, after


def make_case(row: Row) -> Case:
    w, _, direction, state, sign, kind, value = row
    low, high = bounds(row)
    left, right = (low, high) if direction == "ascending" else (high, low)
    initial, before, incoming, result, after = reference(row)
    bits = index_bits(row)
    name = case_name(row)
    lines = [f"module {name};", f"  {state} [{left}:{right}] word;",
             f"  logic {sign} [15:0] index;", "  logic incoming, before_value, after_value;",
             "  bit sample;", "  initial begin", f"    word = {literal(initial)};",
             f"    index = {literal(bits)};", f"    incoming = 1'b{incoming};",
             "    before_value = word[index];",
             '    $display("index=%b input=%b", index, incoming);',
             '    $display("before=%b read=%b", word, before_value);',
             "    word[index] = incoming;", "    after_value = word[index];",
             "    sample = word[index];",
             '    $display("after=%b read=%b sample=%b", word, after_value, sample);',
             "    $finish;", "  end", "endmodule"]
    return Case(
        name, "Variable bit-selects respect signed indices, declared bounds and invalid access defaults",
        "11.5.1 7.4.5 6.11.2",
        "The index is a run-time 16-bit four-state variable, independent of the word width. "
        "Zero-based, offset and negative ranges are tested in both directions. The same "
        "negative encoding is valid only when its signed value is within the range. "
        "Invalid reads return X for logic or zero for bit, and invalid writes preserve "
        "the entire word. A valid known write flips the selected bit; X/Z are converted "
        "only when stored in bit. Before/after words and reads expose index mapping and "
        "unselected-bit preservation; a bit sample separately observes conversion.",
        "\n".join(lines), f"index={bits} input={incoming}\nbefore={initial} read={before}\n"
        f"after={result} read={after} sample={two_state(after)}\n",
        fourstate=value != "known" or kind in ("x", "z") or (position(row) is None and state == "logic"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

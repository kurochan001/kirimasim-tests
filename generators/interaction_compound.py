"""Cross compound shifts with stored types and once-only LHS selection.

11.4.1 gives blocking-assignment semantics but evaluates a left index once.
11.4.10 keeps the signed count self-determined/unsigned for the shift; the
count width cannot widen the data. Part-selects are unsigned (11.8.1).
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_compound"
VERSION = 1
CHAPTER = 11
OPS = {"shl": "<<=", "shr": ">>=", "ashr": ">>>="}

MODEL = Model(
    "compound_shift_target",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("sign", ("unsigned", "signed")),
     ("target", ("scalar", "element", "part")),
     ("operator", tuple(OPS)),
     ("count", ("zero", "last", "width", "ones", "x", "z")),
     ("count_width", ("8", "65")), ("value", ("known", "x", "z"))),
    lambda r: r[0] != "1" or r[5] != "last",
    groups=(("operator", "count", "sign"), ("width", "state", "value"),
            ("sign", "operator", "target")),
    anchors=(("65", "logic", "signed", "element", "ashr", "width", "65", "z"),
             ("33", "logic", "signed", "part", "ashr", "last", "8", "known"),
             ("129", "bit", "signed", "element", "shl", "x", "65", "z"),
             ("1", "logic", "signed", "part", "shr", "ones", "8", "x")),
    constraints=("幅1でlastがzeroと同値になる行だけを除く。左辺は同型のスカラ・固定配列要素・"
                 "幅wのpacked部分選択。部分選択は親の符号にかかわらずunsigned。countは"
                 "signedな8/65ビット変数で、onesは全1（宣言上は-1）だがシフト量はunsigned。"
                 "左辺と右辺の副作用競合、無効な添字、NBA、複合左辺の重複は対象外",),
)


def case_name(row: Row) -> str:
    w, state, sign, target, op, count, cw, value = row
    return (f"test_gen_cross_compound_shift_w{w}_{state[0]}_{sign[0]}_{target}_"
            f"{op}_{count}_c{cw}_{value}")


def source_bits(row: Row, phase: int) -> str:
    bits = pattern(int(row[0]), row[7])
    return bits if phase == 0 else bits.translate(str.maketrans("01", "10"))


def count_bits(row: Row) -> str:
    w, cw = int(row[0]), int(row[6])
    count = row[5]
    if count in ("x", "z"):
        return count * cw
    value = {"zero": 0, "last": w - 1, "width": w, "ones": (1 << cw) - 1}[count]
    return f"{value:0{cw}b}"


def reference(row: Row, phase: int) -> tuple[str, str, str]:
    """Return stored input, assigned result and widened readback as bit strings."""
    w, state, sign, target, op, _, _, _ = row
    w = int(w)
    source = source_bits(row, phase)
    stored = two_state(source) if state == "bit" else source
    count = count_bits(row)
    signed = sign == "signed" and target != "part"
    if any(c in "xz" for c in count):
        result = "x" * w
    else:
        amount = int(count, 2)  # No signed reinterpretation of the count.
        # Position mapping also handles huge 65-bit counts without allocating them.
        def at(position):
            origin = position + amount if op == "shl" else position - amount
            if 0 <= origin < w:
                return stored[origin]
            return stored[0] if op == "ashr" and signed else "0"
        result = "".join(at(i) for i in range(w))
    result = two_state(result) if state == "bit" else result
    return stored, result, resize(result, w + 1, signed)


def make_case(row: Row) -> Case:
    w, state, sign, target, op, count, cw, value = row
    w = int(w)
    name = case_name(row)
    lhs = {"scalar": "scalar", "element": "words[next_index()]",
           "part": "parent[next_index() +: W]"}[target]
    readback = {"scalar": "scalar", "element": "words[1]", "part": "parent[1 +: W]"}[target]
    lines = [f"module {name};", f"  localparam int W = {w};",
             f"  typedef {state} {sign} [W-1:0] word_t;",
             "  word_t scalar, words[0:2];", f"  {state} {sign} [W+1:0] parent;",
             f"  logic signed [{int(cw)-1}:0] amount;", "  logic [W:0] expanded;",
             "  int choice, calls;", "  function automatic int next_index();",
             "    calls++;", "    next_index = choice;", "    choice++;", "  endfunction",
             "  initial begin"]
    expected = []
    for phase in (0, 1):
        source, result, extended = reference(row, phase)
        low, high = str(phase), str(1 - phase)
        before_parent = high + source + low
        after_parent = high + (result if target == "part" else source) + low
        scalar = result if target == "scalar" else source
        element = result if target == "element" else source
        selected = target != "scalar"
        lines += [f"    scalar = {literal(source_bits(row, phase))};",
                  f"    words[0] = {literal('0' * w)};", "    words[1] = scalar;",
                  f"    words[2] = {literal('1' * w)};",
                  f"    parent = {{{literal(high)}, scalar, {literal(low)}}};",
                  f"    amount = {literal(count_bits(row))};", "    choice = 1; calls = 0;",
                  f'    $display("p{phase} input=%b amount=%b", scalar, amount);',
                  f"    {lhs} {OPS[op]} amount;", f"    expanded = {readback};",
                  f'    $display("p{phase} scalar=%b a0=%b a1=%b a2=%b",',
                  "             scalar, words[0], words[1], words[2]);",
                  f'    $display("p{phase} parent=%b extended=%b choice=%0d calls=%0d",',
                  "             parent, expanded, choice, calls);"]
        expected += [f"p{phase} input={source} amount={count_bits(row)}",
                     f"p{phase} scalar={scalar} a0={'0' * w} a1={element} a2={'1' * w}",
                     f"p{phase} parent={after_parent} extended={extended} "
                     f"choice={2 if selected else 1} calls={1 if selected else 0}"]
        assert before_parent[0] == after_parent[0] and before_parent[-1] == after_parent[-1]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Compound shifts preserve LHS identity, data width, signedness and storage conversion",
        "11.4.1 11.4.10 11.6.1 11.8.1 11.8.2 6.11.2 7.4.1 11.5.1",
        "The selected operation executes immediately with no competing writes. A side-effecting "
        "index function changes its next result, so an incorrect second LHS evaluation changes "
        "the call count, selected element or neighboring bits. An unpacked element retains its "
        "word type; a packed part-select is unsigned even when its parent is signed. A signed "
        "8/65-bit count is self-determined and interpreted as unsigned, including all-one counts. "
        "Input X/Z converts when stored in bit before the shift; unknown counts produce X before "
        "the final storage conversion. Two complementary known backgrounds and widened reads "
        "check both sign bits, full containers and unselected storage. NBA, invalid indices, "
        "shared RHS side effects and arithmetic-left compound shifts are outside this model.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=value != "known" or count in ("x", "z"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

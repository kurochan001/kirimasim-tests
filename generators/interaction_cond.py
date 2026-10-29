"""Cross conditional X/Z merging with context extension and 2-state storage.

For ambiguous conditions the oracle uses Table 11-20: only equal 0/1 pairs
survive, including when both inputs contain Z in the same bit. Source bit
strings are extended for the context before selection/merge, then truncated
and converted on assignment. No simulator supplies the expected output.
"""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_cond"
VERSION = 1
CHAPTER = 11

MODEL = Model(
    "conditional_merge",
    (("width", ("1", "33", "65", "129")),
     ("sign_a", ("unsigned", "signed")), ("sign_b", ("unsigned", "signed")),
     ("condition", ("0", "1", "x", "z")),
     ("pattern", ("equal", "opposite", "same_xz", "mixed_xz")),
     ("result_width", ("narrow", "same", "wide")), ("state", ("bit", "logic"))),
    lambda r: r[0] != "1" or r[5] != "narrow",
    groups=(("width", "condition", "state"), ("condition", "pattern", "state"),
            ("sign_a", "sign_b", "result_width")),
    anchors=(("129", "signed", "signed", "x", "same_xz", "wide", "logic"),
             ("65", "signed", "unsigned", "1", "mixed_xz", "wide", "logic"),
             ("33", "signed", "signed", "0", "mixed_xz", "narrow", "bit")),
    constraints=("幅1のnarrowは幅0になるため除外。両分岐の元の幅は同じで、"
                 "代入先の幅だけを1ビット増減。条件は1ビット",),
)


def case_name(row: Row) -> str:
    w, sa, sb, condition, pattern, relation, state = row
    return f"test_gen_cross_cond_w{w}_{sa[0]}{sb[0]}_{condition}_{pattern}_{relation[0]}_{state[0]}"


def operands(width: int, pattern: str) -> tuple[str, str]:
    known = ("10" * ((width + 1) // 2))[:width]
    if pattern == "equal":
        return known, known
    if pattern == "opposite":
        return known, "".join("0" if c == "1" else "1" for c in known)
    a = ("zx10" * ((width + 3) // 4))[:width]
    return a, a if pattern == "same_xz" else ("10zx" * ((width + 3) // 4))[:width]


def reference(row: Row) -> tuple[str, str, str]:
    w, sa, sb, condition, pattern, relation, state = row
    w = int(w)
    wr = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    a, b = operands(w, pattern)
    n = max(w, wr)
    signed = sa == sb == "signed"
    ea = (a[0] if signed else "0") * (n - w) + a
    eb = (b[0] if signed else "0") * (n - w) + b
    if condition in "01":
        value = ea if condition == "1" else eb
    else:
        value = "".join(x if x == y and x in "01" else "x" for x, y in zip(ea, eb))
    value = value[-wr:]
    if state == "bit":
        value = value.replace("x", "0").replace("z", "0")
    return a, b, value


def literal(bits: str) -> str:
    # Hex keeps known wide literals within the source line limit.
    if all(c in "01" for c in bits):
        return f"{len(bits)}'h{int(bits, 2):x}"
    # Break into small binary pieces without changing the exact X/Z bits.
    parts = [bits[i:i + 32] for i in range(0, len(bits), 32)]
    return "{\n" + ",\n".join(f"      {len(p)}'b{p}" for p in parts) + "\n    }"


def make_case(row: Row) -> Case:
    w, sa, sb, condition, pattern, relation, state = row
    w = int(w)
    wr = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    a, b, value = reference(row)
    name = case_name(row)
    lines = [f"module {name};", f"  logic {sa} [{w - 1}:0] a;",
             f"  logic {sb} [{w - 1}:0] b;", "  logic condition;",
             f"  {state} [{wr - 1}:0] result;", "  initial begin",
             f"    a = {literal(a)};", f"    b = {literal(b)};",
             f"    condition = 1'b{condition};", "    result = condition ? a : b;",
             '    $display("a=%b b=%b", a, b);', '    $display("result=%b", result);',
             "    $finish;", "  end", "endmodule"]
    note = (" Icarus Verilog 13.0 preserves Z for identical X/Z branches in this case, "
            "rather than merging Z/Z to X. Its output is a known difference; the "
            "expectation follows Table 11-20."
            if condition in "xz" and pattern == "same_xz" and state == "logic" else "")
    return Case(
        name, "Conditional selection and X/Z merge respect context signs and destination state",
        "11.4.11 11.6.1 11.8.1 11.8.2 6.11.2",
        "Known conditions select one branch; X/Z conditions merge the extended branches "
        "with Table 11-20. Equal 0/1 bits survive while every other pair, including Z/Z, "
        "becomes X. Only two signed branches sign-extend. The result is then truncated "
        "and any X/Z becomes zero in a bit destination. Source and result outputs expose "
        "both the stimulus and the interacting conversion rules." + note,
        "\n".join(lines), f"a={a} b={b}\nresult={value}\n",
        fourstate=condition in "xz" or pattern in ("same_xz", "mixed_xz"),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

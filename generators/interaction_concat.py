"""Cross concatenated LHS sizing, partitioning, state conversion and updates.

11.4.12 treats the LHS concatenation as one packed vector. 10.7 resizes
the RHS according to the source sign before partitioning; each destination
then applies its own 2/4-state conversion. Member reads retain their signs,
while the concatenation is unsigned. Targets are distinct static variables.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_concat"
VERSION = 1
CHAPTER = 11
STATES = {"bb": ("bit", "bit"), "bl": ("bit", "logic"),
          "lb": ("logic", "bit"), "ll": ("logic", "logic")}

MODEL = Model(
    "concatenated_assignment",
    (("width", ("2", "32", "33", "64", "65", "129")),
     ("split", ("head_bit", "halves", "tail_bit")),
     ("rhs_width", ("narrow", "same", "wide")),
     ("rhs_sign", ("unsigned", "signed")), ("state", tuple(STATES)),
     ("member_sign", ("unsigned", "signed")),
     ("update", ("blocking", "nba")), ("value", ("known", "x", "z"))),
    lambda r: r[0] != "2" or r[1] == "head_bit",
    groups=(("width", "state", "value"), ("split", "rhs_width", "rhs_sign"),
            ("state", "update", "value"), ("rhs_sign", "member_sign", "rhs_width")),
    anchors=(("129", "head_bit", "narrow", "signed", "bl", "signed", "nba", "z"),
             ("65", "halves", "wide", "unsigned", "bb", "unsigned", "blocking", "x"),
             ("33", "tail_bit", "same", "signed", "ll", "signed", "nba", "known"),
             ("32", "halves", "narrow", "unsigned", "lb", "signed", "nba", "known"),
             ("2", "head_bit", "narrow", "signed", "bl", "signed", "nba", "known")),
    constraints=("widthは連結全体の幅で最小2、各項は正幅。幅2では同じ分割をhead_bitに統一。"
                 "別々のstatic変数2個を連結し、両項の符号は共通。"
                 "stateは左／右のbit/logic。既知2組と必要ならX/Zの2組を観測。"
                 "重複した代入先、部分選択、多次元配列は対象外",),
)


def geometry(row: Row) -> tuple[int, int, int]:
    """Left, right and source widths; independent of any SV expression."""
    width, split, relation, *_ = row
    total = int(width)
    left = {"head_bit": 1, "halves": total // 2, "tail_bit": total - 1}[split]
    source = total + {"narrow": -1, "same": 0, "wide": 1}[relation]
    return left, total - left, source


def case_name(row: Row) -> str:
    w, split, relation, sign, state, member, update, value = row
    return (f"test_gen_cross_concat_w{w}_{split}_{relation[0]}_{sign[0]}_"
            f"{state}_m{member[0]}_{update[0]}_{value[0]}")


def source_bits(row: Row, phase: int, *, baseline: bool = False) -> str:
    _, _, width = geometry(row)
    bits = pattern(width, "known")
    if phase:
        bits = "".join("0" if b == "1" else "1" for b in bits)
    if not baseline and row[-1] != "known":
        positions = {0, width - 1, width // 2}
        bits = "".join(row[-1] if i in positions else b for i, b in enumerate(bits))
    return bits


def reference(row: Row, phase: int, *, baseline: bool = False) -> tuple[str, ...]:
    """Source, expanded/truncated RHS, stored items, and before/source-after bits."""
    left, right, _ = geometry(row)
    source = source_bits(row, phase, baseline=baseline)
    fitted = resize(source, left + right, row[3] == "signed")
    a, b = fitted[:left], fitted[left:]
    if STATES[row[4]][0] == "bit":
        a = two_state(a)
    if STATES[row[4]][1] == "bit":
        b = two_state(b)
    invert = lambda bits: "".join("0" if c == "1" else "1" for c in bits)
    return source, fitted, a, b, invert(a), invert(b), invert(source)


def make_case(row: Row) -> Case:
    width, _, _, sign, state, member, update, value = row
    left, right, source_width = geometry(row)
    total = int(width)
    ls, rs = STATES[state]
    operator = "<=" if update == "nba" else "="
    name = case_name(row)
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  {ls} {member} [{left - 1}:0] left;",
             f"  {rs} {member} [{right - 1}:0] right;",
             f"  logic {sign} [{source_width - 1}:0] source;",
             f"  logic [{left}:0] left_wide;", f"  logic [{right}:0] right_wide;",
             f"  logic [{total}:0] concat_wide;", "  initial begin"]
    expected = []
    stimuli = (("p", False),) if value == "known" else (("k", True), ("p", False))
    for prefix, baseline in stimuli:
        for phase in (0, 1):
            source, _, a, b, before_a, before_b, changed = reference(row, phase, baseline=baseline)
            label = f"{prefix}{phase}"
            scheduled = (before_a, before_b) if update == "nba" else (a, b)
            lines += [f"    left = {literal(before_a)};", f"    right = {literal(before_b)};",
                      f"    source = {literal(source)};",
                      f'    $display("{label}_input=%b", source);',
                      f"    {{left, right}} {operator} source;",
                      f'    $display("{label}_scheduled=%b %b", left, right);',
                      f"    source = {literal(changed)};",
                      f'    $display("{label}_changed=%b", source);', "    #1;",
                      "    left_wide = left;", "    right_wide = right;",
                      "    concat_wide = {left, right};",
                      f'    $display("{label}_final=%b %b", left, right);',
                      f'    $display("{label}_wide=%b %b concat=%b",',
                      "             left_wide, right_wide, concat_wide);"]
            expected += [f"{label}_input={source}",
                         f"{label}_scheduled={scheduled[0]} {scheduled[1]}",
                         f"{label}_changed={changed}", f"{label}_final={a} {b}",
                         f"{label}_wide={resize(a, left + 1, member == 'signed')} "
                         f"{resize(b, right + 1, member == 'signed')} concat=0{a}{b}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Concatenated LHS assignments resize once before partition and per-item state conversion",
        f"11.4.12 10.7 {'10.4.2' if update == 'nba' else '10.4.1'} 6.11.2 11.8.1 11.8.2",
        "The RHS is a single signed or unsigned logic variable. Assignment first fits "
        "it to the entire concatenation width, then splits the high and low fields and "
        "converts each field to its own bit or logic storage. Member signedness does "
        "not change the RHS sign. Widened member reads use their declared sign; a "
        "widened concatenation always zero-extends. Every case has two known inputs; "
        "X/Z rows add two perturbed inputs. Source mutation after scheduling exposes "
        "NBA capture, with immediate and next-tick observations. Targets are distinct "
        "static whole variables; overlapping targets and slices are not modeled.",
        "\n".join(lines), "\n".join(expected) + "\n", fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

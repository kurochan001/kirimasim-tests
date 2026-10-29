"""Cross dynamic-array construction with resizing, value copies and defaults.

7.5.1 truncates an oversized initializer and pads an undersized initializer
with element-type defaults. Self-resizing evaluates the old array before
replacing it; construction without an initializer preserves no old data.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_resize"
VERSION = 1
CHAPTER = 7

MODEL = Model(
    "dynamic_array_resize",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("sign", ("unsigned", "signed")),
     ("value", ("known", "x", "z")), ("old_size", ("0", "2", "3")),
     ("new_size", ("0", "1", "2", "4")), ("operation", ("copy", "self", "reset"))),
    lambda r: r[4] != "0" or r[3] == "known",
    groups=(("width", "state", "value"), ("old_size", "new_size", "operation"),
            ("state", "new_size", "operation")),
    anchors=(("129", "logic", "signed", "z", "3", "4", "self"),
             ("65", "bit", "unsigned", "x", "3", "1", "copy"),
             ("33", "logic", "signed", "known", "2", "2", "reset"),
             ("1", "bit", "signed", "known", "0", "4", "self"),
             ("65", "logic", "unsigned", "x", "2", "0", "self")),
    constraints=("初期サイズ0では値因子をknownに固定し、値を持たない重複を除く。"
                 "同じtypedefの動的配列に対する別配列コピー・自己リサイズ・初期化式なしの"
                 "再生成を比較。サイズは実行時変数。要素参照の有効期間・多次元配列は対象外",),
)


def case_name(row: Row) -> str:
    w, state, sign, value, old, new, operation = row
    return f"test_gen_cross_resize_w{w}_{state[0]}_{sign[0]}_{value}_n{old}_{new}_{operation}"


def initial_values(row: Row, phase: int) -> list[str]:
    w, state, _, value, old, _, _ = row
    w, old = int(w), int(old)
    first = pattern(w, value)
    stored = two_state(first) if state == "bit" else first
    other = changed(stored)
    values = ([first, other] if old == 2 else [first, "0" * w, "1" * w])[:old]
    return values[1:] + values[:1] if phase else values


def changed(bits: str) -> str:
    """Produce a known value different from every 0/1/X/Z input word."""
    return "".join("0" if c == "1" else "1" for c in bits)


def reference(row: Row, phase: int) -> tuple[list[str], list[str], list[str], list[str]]:
    w, state, _, _, _, new, operation = row
    w, new = int(w), int(new)
    initial = [two_state(v) if state == "bit" else v for v in initial_values(row, phase)]
    default = ("0" if state == "bit" else "x") * w
    result = [] if operation == "reset" else initial[:new]
    result += [default] * (new - len(result))
    peer = list(initial)
    if peer:
        peer[0] = changed(peer[0])
    modified = list(result)
    if modified:
        modified[0] = changed(modified[0])
    return initial, result, peer, modified


def make_case(row: Row) -> Case:
    w, state, sign, value, old, new, operation = row
    w, old, new = int(w), int(old), int(new)
    name = case_name(row)
    result_name, peer_name = ("target", "source") if operation == "copy" else ("source", "target")
    operation_text = {"copy": "target = new[requested](source);",
                      "self": "source = new[requested](source);",
                      "reset": "source = new[requested];"}[operation]
    lines = [f"module {name};", f"  typedef {state} {sign} [{w - 1}:0] word_t;",
             "  word_t source[], target[];", f"  logic [{w}:0] expanded;",
             "  int original_size, requested;", "  initial begin",
             '    $display("uncreated=%0d %0d", source.size(), target.size());']
    expected = ["uncreated=0 0"]
    for phase in (0, 1):
        initial, result, peer, modified = reference(row, phase)
        lines += [f"    original_size = {old};", f"    requested = {new};",
                  "    source = new[original_size];"]
        for i, bits in enumerate(initial_values(row, phase)):
            lines.append(f"    source[{i}] = {literal(bits)};")
        lines += [f'    $display("p{phase}_input_size=%0d", source.size());',
                  f'    foreach (source[i]) $display("p{phase}_input%0d=%b", i, source[i]);',
                  "    target = new[original_size](source);", "    " + operation_text,
                  f'    $display("p{phase}_result_size=%0d", {result_name}.size());',
                  f"    foreach ({result_name}[i]) begin",
                  f"      expanded = {result_name}[i];",
                  f'      $display("p{phase}_result%0d=%b extended=%b", i, {result_name}[i], expanded);',
                  "    end"]
        expected += [f"p{phase}_input_size={old}"]
        expected += [f"p{phase}_input{i}={bits}" for i, bits in enumerate(initial)]
        expected += [f"p{phase}_result_size={new}"]
        expected += [f"p{phase}_result{i}={bits} extended={resize(bits, w + 1, sign == 'signed')}"
                     for i, bits in enumerate(result)]
        if initial:
            lines.append(f"    {peer_name}[0] = {literal(peer[0])};")
        lines.append(f'    foreach ({result_name}[i]) $display("p{phase}_after_peer%0d=%b",'
                     f' i, {result_name}[i]);')
        expected += [f"p{phase}_after_peer{i}={bits}" for i, bits in enumerate(result)]
        if result:
            lines.append(f"    {result_name}[0] = {literal(modified[0])};")
        lines += [f'    foreach ({result_name}[i]) $display("p{phase}_modified%0d=%b",'
                  f' i, {result_name}[i]);',
                  f'    $display("p{phase}_peer_size=%0d", {peer_name}.size());',
                  f'    foreach ({peer_name}[i]) $display("p{phase}_peer%0d=%b", i, {peer_name}[i]);']
        expected += [f"p{phase}_modified{i}={bits}" for i, bits in enumerate(modified)]
        expected += [f"p{phase}_peer_size={old}"]
        expected += [f"p{phase}_peer{i}={bits}" for i, bits in enumerate(peer)]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Dynamic-array resizing preserves prefixes, type defaults and independent copies",
        "7.5.1 7.5 7.5.2 6.8 6.11.2 11.8.2",
        "Runtime sizes cross empty, shortened, same-size and extended dynamic arrays. Both "
        "arrays share one element typedef. Copy construction uses another array; self-resizing "
        "uses the old value of the same array; construction without an initializer discards "
        "old contents. Truncation keeps the first elements and padding uses zero for bit or "
        "X for logic. Two rotated inputs distinguish element order at one-bit width. Mutating "
        "a retained peer and then the result checks independence in both directions. Every "
        "element and size is observed, and widened reads check element signedness. Element "
        "reference lifetime and multidimensional arrays are outside this model.",
        "\n".join(lines), "\n".join(expected) + "\n",
        fourstate=value != "known" or (state == "logic" and new > 0
                                     and (operation == "reset" or new > old)),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

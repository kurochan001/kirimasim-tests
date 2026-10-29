"""Cross streaming direction, partial slices, source lists and pack/unpack.

11.4.14.2 reverses blocks counted from the right, without reversing bits
inside each block; a partial left block has no padding. Unpack applies the
inverse index permutation, which is not generally the same permutation.
Source and target lengths are equal to avoid padding/truncation ambiguity.
"""

from common import Case
from interaction_bits import two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_stream"
VERSION = 1
CHAPTER = 11

MODEL = Model(
    "streaming_permutation",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("direction", ("left", "right")), ("slice", ("1", "4", "8", "16")),
     ("form", ("plain", "tagged")), ("operation", ("pack", "unpack")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("direction", "slice", "operation"),
            ("form", "slice", "operation")),
    anchors=(("129", "left", "8", "tagged", "unpack", "logic", "z"),
             ("65", "left", "16", "plain", "pack", "logic", "x"),
             ("33", "left", "4", "plain", "unpack", "bit", "known"),
             ("32", "right", "8", "tagged", "pack", "logic", "z")),
    constraints=("スライス幅は正の定数。taggedは先頭に101を追加。入出力のビット数を同一にし、"
                 "パックベクタだけを使う。動的配列、with範囲、サイズ不一致は対象外",),
)


def case_name(row: Row) -> str:
    w, direction, size, form, operation, state, value = row
    return f"test_gen_cross_stream_w{w}_{direction[0]}_s{size}_{form[0]}_{operation}_{state[0]}_{value[0]}"


def reorder(bits: str, direction: str, size: int, unpack: bool = False) -> str:
    if size <= 0:
        raise ValueError("stream slice size must be positive")
    if direction == "right":
        return bits
    order = [i for end in range(len(bits), 0, -size)
             for i in range(max(0, end - size), end)]
    if not unpack:
        return "".join(bits[i] for i in order)
    result = [""] * len(bits)
    for incoming, original in enumerate(order):
        result[original] = bits[incoming]
    return "".join(result)


def reference(row: Row) -> tuple[str, str, str]:
    w, direction, size, form, operation, state, value = row
    w = int(w)
    # The interior bit is deliberately off-center to avoid palindromes.
    source = list(f"{(1 << (w - 1)) | (1 << (w // 3)) | 1:0{w}b}")
    if value != "known":
        source[0] = source[-1] = value
    source = "".join(source)
    incoming = ("101" if form == "tagged" else "") + source
    result = reorder(incoming, direction, int(size), operation == "unpack")
    return source, incoming, two_state(result) if state == "bit" else result


def make_case(row: Row) -> Case:
    w, direction, size, form, operation, state, value = row
    w = int(w)
    source, incoming, result = reference(row)
    name = case_name(row)
    symbol = "<<" if direction == "left" else ">>"
    operands = "3'b101, source" if form == "tagged" else "source"
    assignment = (f"result = {{{symbol}{size}{{{operands}}}}};" if operation == "pack" else
                  f"{{{symbol}{size}{{result}}}} = incoming;")
    n = len(incoming)
    lines = [f"module {name};", f"  logic [{w - 1}:0] source;",
             f"  logic [{n - 1}:0] incoming;", f"  {state} [{n - 1}:0] result;",
             "  initial begin", f"    source = {literal(source)};",
             f"    incoming = {{{operands}}};", "    " + assignment,
             '    $display("source=%b incoming=%b", source, incoming);',
             '    $display("result=%b", result);', "    $finish;", "  end", "endmodule"]
    note = " Icarus Verilog 13.0 does not support streaming concatenations."
    if name == "test_gen_cross_stream_w33_l_s4_p_unpack_b_k":
        note += (" The 5.052 reference run gives the pack permutation rather than the inverse "
                 "permutation for this partial-block unpack; the oracle follows 11.4.14.3.")
    return Case(
        name, "Streaming pack/unpack preserves partial slices and applies inverse permutations",
        "11.4.14 11.4.14.1 11.4.14.2 11.4.14.3 6.11.2",
        "A right stream keeps bit order regardless of slice size. A left stream reverses "
        "blocks taken from the right, preserving order within each block and the partial "
        "left block. Pack uses that permutation; unpack uses its inverse. Plain and "
        "three-bit-tagged forms expose non-byte-aligned boundaries. Target width exactly "
        "matches the stream, and bit targets convert X/Z after reordering." + note,
        "\n".join(lines), f"source={source} incoming={incoming}\nresult={result}\n",
        fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]

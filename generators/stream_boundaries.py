# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Streaming assignments across partial blocks, target sizes and aggregates.

Reuse the clause-based block permutation from interaction_stream. New cases
compose it with right padding, MSB consumption, nested streams, typed slices,
and explicitly ordered aggregate fields/elements. No simulator is an oracle
for the reference calculation.
"""
from common import Case
from bitvector_queries import assign_literal, unknowns
from interaction_stream import reorder

NAME = "stream_boundaries"
VERSION = 1
CHAPTER = 11
WIDTHS = (63, 64, 65, 127, 128, 129)
DIRECTIONS = ("left", "right")
FORMS = ("pad_known", "pad_logic", "unpack_split", "unpack_drop", "typed",
         "nested", "record", "array")
DESCRIPTIONS = {
    "pad_known": "Wider streaming targets add right zeros rather than signed left padding",
    "pad_logic": "Wider four-state streaming targets preserve unknowns before right padding",
    "unpack_split": "Streaming unpack distributes a partial-block permutation across target fields",
    "unpack_drop": "Narrower streaming targets consume the most significant source bits",
    "typed": "Typed and numeric stream slice sizes agree and omitted slices are single bits",
    "nested": "Nested streaming expressions reorder the inner stream before the outer stream",
    "record": "Streaming packed records preserves field order and four-state member values",
    "array": "Streaming fixed arrays visits elements in declared order across word boundaries",
}


def pattern(width, salt=0):
    bits = ["1" if (i * i + 13 * i + 7 * salt + 3) % 31 < 14 else "0"
            for i in range(width)]
    bits[0], bits[-1] = "1", "0"
    return "".join(bits)


def stream(direction, size, operands):
    operator = "<<" if direction == "left" else ">>"
    return "{" + operator + (" " + str(size) if size is not None else "") + "{" + operands + "}}"


def observe(lines, expected, label, expression, bits):
    lines.append(f'    $display("{label}=%b", {expression});')
    expected.append(label + "=" + bits)


def make_case(width, direction, form):
    name = f"test_gen_stream_boundary_{form}_{direction}_w{width}"
    declarations, lines = [], []
    expected = [f"width={width} direction={direction} form={form}"]
    source = pattern(width)
    clauses = "11.4.14 11.4.14.1 11.4.14.2 11.4.14.3 6.11.2 6.24.3"
    if form.startswith("pad_"):
        state = "logic" if form == "pad_logic" else "bit"
        declarations = [f"  {state} signed [W-1:0] source;",
                        f"  {state} [W+8:0] padded, ordinary;"]
        samples = [source, unknowns(source)] if state == "logic" else [source]
        for phase, bits in enumerate(samples):
            assign_literal(lines, "source", bits)
            lines += [f"    padded = {stream(direction, 5, 'source')};",
                      "    ordinary = source;"]
            observe(lines, expected, f"p{phase}_source", "source", bits)
            observe(lines, expected, f"p{phase}_padded", "padded",
                    reorder(bits, direction, 5) + "0" * 9)
            observe(lines, expected, f"p{phase}_ordinary", "ordinary", bits[0] * 9 + bits)
        note = ("A wider streaming destination left-aligns the reordered stream and adds "
                "nine zero bits on the right. The ordinary assignment of the same signed "
                "source is a separate sign-extension control. A four-state case starts "
                "with known data before introducing unequal X/Z populations.")
    elif form == "unpack_split":
        declarations = ["  bit [W+7:0] incoming, encoded;", "  bit [2:0] head;",
                        "  bit [W-1:0] payload;", "  bit [4:0] tail;"]
        incoming = pattern(width + 8, 1)
        assign_literal(lines, "incoming", incoming)
        target = "head, payload, tail"
        lines += [f"    {stream(direction, 5, target)} = incoming;",
                  f"    encoded = {stream(direction, 5, target)};"]
        unpacked = reorder(incoming, direction, 5, unpack=True)
        observe(lines, expected, "incoming", "incoming", incoming)
        observe(lines, expected, "head", "head", unpacked[:3])
        observe(lines, expected, "payload", "payload", unpacked[3:3 + width])
        observe(lines, expected, "tail", "tail", unpacked[3 + width:])
        observe(lines, expected, "encoded", "encoded", incoming)
        note = ("A three-bit head, a wide payload and a five-bit tail split one equal-size "
                "unpack stream. Unpack inverts the five-bit pack permutation, including "
                "a short leftmost block. Every target and a subsequent re-pack are observed.")
    elif form == "unpack_drop":
        declarations = ["  bit signed [W+8:0] incoming;", "  bit [W-1:0] target, encoded;"]
        incoming = pattern(width + 9, 2)
        assign_literal(lines, "incoming", incoming)
        lines += [f"    {stream(direction, 7, 'target')} = incoming;",
                  f"    encoded = {stream(direction, 7, 'target')};"]
        consumed = incoming[:width]
        observe(lines, expected, "incoming", "incoming", incoming)
        observe(lines, expected, "target", "target", reorder(consumed, direction, 7, unpack=True))
        observe(lines, expected, "encoded", "encoded", consumed)
        observe(lines, expected, "unused_low", "incoming[8:0]", incoming[-9:])
        note = ("A smaller unpack target consumes the leftmost W bits of the wider source, "
                "discarding nine rightmost bits before the inverse permutation. Re-packing "
                "the destination recovers the consumed prefix, not the ordinary low-bit truncation.")
    elif form == "typed":
        declarations = ["  typedef bit [4:0] chunk_t;", "  bit [W-1:0] source;",
                        "  bit [W-1:0] numeric_result, typed_result, default_result;"]
        assign_literal(lines, "source", source)
        lines += [f"    numeric_result = {stream(direction, 5, 'source')};",
                  f"    typed_result = {stream(direction, 'chunk_t', 'source')};",
                  f"    default_result = {stream(direction, None, 'source')};"]
        observe(lines, expected, "source", "source", source)
        observe(lines, expected, "numeric", "numeric_result", reorder(source, direction, 5))
        observe(lines, expected, "typed", "typed_result", reorder(source, direction, 5))
        observe(lines, expected, "default", "default_result", reorder(source, direction, 1))
        clauses += " 6.18"
        note = ("A five-bit typedef supplies the same slice size as literal 5, regardless of "
                "whether the source length is divisible by five. An omitted slice size is "
                "one. Right streaming ignores either slice size and preserves source order.")
    elif form == "nested":
        declarations = ["  bit [W-1:0] source, inner_control;",
                        "  bit [W+7:0] nested_result, stored_control;"]
        assign_literal(lines, "source", source)
        inner = stream("left", 3, "source")
        nested = stream(direction, 7, "5'b10110, " + inner + ", 3'b011")
        lines += [f"    inner_control = {inner};", f"    nested_result = {nested};",
                  f"    stored_control = {stream(direction, 7, "5'b10110, inner_control, 3'b011")};"]
        inner_bits = reorder(source, "left", 3)
        result = reorder("10110" + inner_bits + "011", direction, 7)
        observe(lines, expected, "source", "source", source)
        observe(lines, expected, "inner", "inner_control", inner_bits)
        observe(lines, expected, "nested", "nested_result", result)
        observe(lines, expected, "stored_control", "stored_control", result)
        note = ("A three-bit inner left stream is a legal expression of a seven-bit outer "
                "stream between non-byte-sized tags. Storing the inner result first is "
                "an independent source-path control; raw source and both final streams are observed.")
    elif form == "record":
        declarations = ["  typedef struct packed {", "    logic [4:0] head;",
                        "    logic signed [W-1:0] payload;", "    logic [2:0] tail;",
                        "  } record_t;", "  record_t record_value;",
                        "  logic [W+7:0] result, list_control;"]
        for phase, bits in enumerate((source, unknowns(source))):
            head, tail = ("10110", "011") if phase == 0 else ("10xz1", "z10")
            assign_literal(lines, "record_value.head", head)
            assign_literal(lines, "record_value.payload", bits)
            assign_literal(lines, "record_value.tail", tail)
            lines += [f"    result = {stream(direction, 9, 'record_value')};",
                      f"    list_control = {stream(direction, 9, 'record_value.head, record_value.payload, record_value.tail')};"]
            value = head + bits + tail
            observe(lines, expected, f"p{phase}_record", "record_value", value)
            observe(lines, expected, f"p{phase}_result", "result", reorder(value, direction, 9))
            observe(lines, expected, f"p{phase}_list", "list_control", reorder(value, direction, 9))
        clauses += " 7.2.1"
        note = ("A packed record contributes declaration-order fields without gaps or "
                "per-member sign extension. Nine-bit blocks cross the payload and tags. "
                "Known values precede X/Z data; the whole-record and explicit-member paths "
                "must produce the same four-state stream.")
    else:
        assert form == "array"
        declarations = ["  typedef bit signed [W-1:0] word_t;", "  word_t words[3:1];",
                        "  bit [3*W-1:0] result, list_control;"]
        values = (source, "".join("0" if c == "1" else "1" for c in source), pattern(width, 4))
        for index, bits in zip((3, 2, 1), values):
            assign_literal(lines, f"words[{index}]", bits)
            observe(lines, expected, f"word{index}", f"words[{index}]", bits)
        lines += [f"    result = {stream(direction, 5, 'words')};",
                  f"    list_control = {stream(direction, 5, 'words[3], words[2], words[1]')};"]
        result = reorder("".join(values), direction, 5)
        observe(lines, expected, "array", "result", result)
        observe(lines, expected, "list_control", "list_control", result)
        clauses += " 7.4.2 12.7.3"
        note = ("The fixed unpacked range is 3:1, so array streaming visits elements 3,2,1. "
                "The signed element values contribute raw W-bit words without extension. "
                "Five-bit blocks cross word boundaries; an explicit element-list stream "
                "and all original words independently expose array order and bit preservation.")
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form], clauses, note, "\n".join(body),
                "\n".join(expected) + "\n", fourstate=form in ("pad_logic", "record"))


def cases():
    return [make_case(w, d, f) for w in WIDTHS for d in DIRECTIONS for f in FORMS]

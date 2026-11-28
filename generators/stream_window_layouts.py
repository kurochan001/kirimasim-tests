# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Streaming with selections across array layouts and unequal block sizes."""

from itertools import product

from common import Case
from interaction_stream import reorder
from stream_boundaries import stream

NAME = "stream_window_layouts"
VERSION = 1
CHAPTER = 11

LAYOUTS = {
    "fixed_up": ("[-2:2]", (-2, -1, 0, 1, 2)),
    "fixed_down": ("[7:3]", (7, 6, 5, 4, 3)),
    "dynamic": ("[]", tuple(range(5))),
    "queue": ("[$]", tuple(range(5))),
}
FORMS = ("single", "colon", "plus", "minus", "explicit_one", "explicit_three")


def make_case(width, layout, form):
    declaration, indices = LAYOUTS[layout]
    chosen = indices[1:2] if form in ("single", "explicit_one") else indices[1:4]
    left, right = chosen[0], chosen[-1]
    explicit = form.startswith("explicit_")
    if explicit:
        start = left
        subscripts = ["position" if i == left else f"position{(i - left):+d}" for i in chosen]
        input_items = ", ".join(f"original[{item}]" for item in subscripts)
        output_items = ", ".join(f"target[{item}]" for item in subscripts)
    else:
        range_text, start = {
            "single": ("position", left),
            "colon": ("position:stop", left),
            "plus": (f"position+:{len(chosen)}", min(chosen)),
            "minus": (f"position-:{len(chosen)}", max(chosen)),
        }[form]
        input_items = f"original with [{range_text}]"
        output_items = f"target with [{range_text}]"
    name = f"test_gen_stream_window_{width}_{layout}_{form}"
    mask = (1 << width) - 1
    width_mask = f"0{width}b"
    words = tuple(v & mask for v in (0x12DB943E1, 0x1F037832D, 0x143A8667B, 0x1C7354DB2, 0x18EB0A956))
    guards = [v ^ mask for v in words]
    payload = "".join(format(words[indices.index(i)], width_mask) for i in chosen)
    raw = "10110" + payload + "011"
    block = width + 3
    packed = reorder(raw, "left", block)
    result = [words[n] if i in chosen else guards[n] for n, i in enumerate(indices)]
    width_text = len(raw)
    expected = [f"raw={raw}", f"ordered={packed}", "fields=10110/011"]
    expected += ["words=" + "/".join(format(v, width_mask) for v in result)]

    lines = []
    if layout == "dynamic":
        lines += ["    original = new[5];", "    target = new[5];"]
    for array, values in (("original", words), ("target", guards)):
        if layout == "queue":
            items = ", ".join(f"{width}'h{value:x}" for value in values)
            lines += [f"    {array} = {{{items}}};"]
        else:
            lines += [f"    {array}[{i}] = {width}'h{v:x};" for i, v in zip(indices, values)]
    lines += [f"    position = {start};"]
    if form == "colon":
        lines += [f"    stop = {right};"]
    separator = ",\n                " if form == "explicit_three" else ", "
    operands = separator.join(("5'b10110", input_items, "3'b011"))
    receiver = f"head, {output_items}, tail"
    lines += [f"    raw = {stream('right', None, operands)};",
              f"    ordered = {stream('left', block, operands)};"]
    stimulus = f"{width_text}'h{int(packed, 2):x}"
    lines += [f"    incoming = {stimulus};",
              f"    {stream('left', block, receiver)} = incoming;",
              '    $display("raw=%b", raw);', '    $display("ordered=%b", ordered);',
              '    $display("fields=%b/%b", head, tail);',
              '    $display("words=%b/%b/%b/%b/%b",']
    lines += ["             " + ", ".join(f"target[{i}]" for i in indices) + ");"]
    variables = "int position, stop;" if form == "colon" else "int position;"
    body = "\n".join([f"module {name};", f"  typedef bit [{width - 1}:0] word_t;",
                      f"  word_t original{declaration}, target{declaration};",
                      f"  bit [{width_text - 1}:0] raw, ordered, incoming;",
                      "  bit [4:0] head;", "  bit [2:0] tail;", f"  {variables}",
                      "  initial begin", *lines, "  end", "endmodule"])
    clauses = "11.4.14.2 11.4.14.3" if explicit else "11.4.14.4 11.4.14.2 11.4.14.3"
    note = ("List the selected elements explicitly and keep guards outside the destination."
            if explicit else
            "Use valid nonconstant windows and keep guards outside the destination range.")
    observation = ""
    if (width, layout, form) == (33, "fixed_up", "explicit_one"):
        observation = " Packing matches on Verilator 5.054. Unpack gives tags 00000 and 111."
    return Case(name, "Stream windows preserve array order across block boundaries", clauses,
                note + " "
                "Check left-to-right packing and block reversal across the head, selected "
                "words and tail. Unpack a separately constructed stream to check the inverse."
                + observation,
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product((7, 8, 9, 33), LAYOUTS, FORMS)]

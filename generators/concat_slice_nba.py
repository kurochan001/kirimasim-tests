# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Concatenation NBAs to indexed slices of packed words and unpacked elements.

Each slice keeps its full RHS field even when some coordinates are outside
the word. The model places bits in declared coordinates and schedules one
update before the SV process changes the array index, bases, and RHS.
"""

from itertools import product

from common import Case

NAME = "concat_slice_nba"
VERSION = 1
CHAPTER = 10

GEOMETRIES = {
    "descending_first": ((7, -4), (1, 12), (4, 4)),
    "ascending_first": ((-4, 7), (12, 1), (5, 3)),
    "wide_words": ((63, -2), (-3, 62), (5, 5)),
}
LAYOUTS = {"packed": (False, False), "left_array": (True, False),
           "right_array": (False, True), "both_arrays": (True, True)}
WINDOWS = ("inside", "low_clip", "high_clip", "left_out")


def write_slice(word, bounds, low, width, value):
    """Place one RHS field by declaration order and ignore excluded indices."""
    msb, lsb = bounds
    coordinates = range(low, low + width)
    if msb > lsb:
        coordinates = reversed(coordinates)
    for bit, index in enumerate(coordinates):
        if min(bounds) <= index <= max(bounds):
            offset = abs(index - lsb)
            value_bit = (value >> (width - bit - 1)) & 1
            word = (word & ~(1 << offset)) | (value_bit << offset)
    return word


def make_case(geometry, layout, window):
    left, right, (left_width, right_width) = GEOMETRIES[geometry]
    left_array, right_array = LAYOUTS[layout]
    left_low = min(left) + 2
    right_low = max(right) - right_width - 1
    if window == "low_clip":
        left_low = min(left) - 2
    if window == "high_clip":
        right_low = max(right) - 1
    if window == "left_out":
        left_low = min(left) - left_width
    right_high = right_low + right_width - 1

    widths = [abs(bounds[0] - bounds[1]) + 1 for bounds in (left, right)]
    initial = [value & ((1 << width) - 1) for value, width in
               zip((0x2A56BA978C4E1AA54, 0x19CE5F321BA2888E6), widths)]
    guards = [value ^ ((1 << width) - 1) for value, width in zip(initial, widths)]
    payload_width = left_width + right_width
    payload = 0x2D6 & ((1 << payload_width) - 1)
    final = [write_slice(initial[0], left, left_low, left_width, payload >> right_width),
             write_slice(initial[1], right, right_low, right_width,
                         payload & ((1 << right_width) - 1))]

    name = f"test_gen_concat_slice_nba_{geometry}_{layout}_{window}"
    lines = ["`timescale 1ns/1ns", f"module {name};", "  int row, first, last;",
             f"  logic [{payload_width - 1}:0] payload;"]
    names = ("a", "b")
    arrays = (left_array, right_array)
    for target, bounds, array in zip(names, (left, right), arrays):
        lines += [f"  logic [{bounds[0]}:{bounds[1]}] {target}{'[2]' if array else ''};"]
    lines += ["  initial begin"]
    for index, (target, width, array) in enumerate(zip(names, widths, arrays)):
        selected = f"{target}[{index}]" if array else target
        lines += [f"    {selected} = {width}'h{initial[index]:x};"]
        if array:
            lines += [f"    {target}[{1 - index}] = {width}'h{guards[index]:x};"]
    a, b = ("a[row]" if left_array else "a", "b[!row]" if right_array else "b")
    left_observed = "a[0]" if left_array else "a"
    right_observed = "b[1]" if right_array else "b"
    lines += ["    row = 0;", f"    first = {left_low}; last = {right_high};",
              f"    payload = {payload_width}'h{payload:x};",
              f"    {{{a}[first+:{left_width}], {b}[last-:{right_width}]}} <= payload;",
              f'    $display("pending=%h/%h", {left_observed}, {right_observed});',
              "    row = 1; first = 0; last = 0; payload = '0;", "    #1;",
              f'    $display("committed=%h/%h", {left_observed}, {right_observed});']

    def printed(words):
        return "/".join(f"{word:0{(width + 3) // 4}x}" for word, width in zip(words, widths))

    expected = [f"pending={printed(initial)}", f"committed={printed(final)}"]
    for index, (target, width, array) in enumerate(zip(names, widths, arrays)):
        if array:
            lines += [f'    $display("guard {target}=%h", {target}[{1 - index}]);']
            expected += [f"guard {target}={guards[index]:0{(width + 3) // 4}x}"]
    lines += ["    $finish(0);", "  end", "endmodule"]
    return Case(name, "Concatenation NBA preserves RHS fields and captured slice coordinates",
                "10.4.2 11.5.1 11.4.12",
                "The two part-selects may target standalone vectors or selected elements of "
                "different unpacked arrays. Observe the old values before NBA, then mutate "
                "the source and indices. A write outside a vector discards those bits "
                "without shifting the opposite RHS field. Untargeted array elements are guards.",
                "\n".join(lines), "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(GEOMETRIES, LAYOUTS, WINDOWS)]

# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Coordinate-based references for nested packed lanes and clipped writes.

The model stores individual declared (row, column) labels. Observations flatten
them only in declaration order, keeping lane bounds distinct from the bounds
of the complete packed value. No simulator output supplies expected values.
"""
from common import Case
from bitvector_queries import assign_literal

NAME = "packed_lanes"
VERSION = 1
CHAPTER = 7
WIDTHS = (32, 33, 64, 65, 128, 129)
DIRECTIONS = ("up", "down")
FORMS = ("bits", "window", "signatures", "boundary")
DESCRIPTIONS = {
    "bits": "Nested packed bit writes preserve neighboring lanes and declared index labels",
    "window": "Packed lane windows copy overlapping sources before updating their destinations",
    "signatures": "Packed lane and part selections are unsigned while whole packed arrays retain signing",
    "boundary": "Clipped packed lane writes preserve neighbors and invalid indices perform no write",
}


def pattern(width, salt):
    return "".join("1" if (11 * i + salt * i * i + 19 * salt) % 37 < 18 else "0"
                   for i in range(width))


def labels(left, right):
    return list(range(left, right + (1 if left <= right else -1), 1 if left <= right else -1))


class Bank:
    def __init__(self, width, outer, inner, state, origin=-5):
        self.width, self.state = width, state
        self.rows = labels(-1, 1) if outer == "up" else labels(1, -1)
        self.columns = (labels(origin, origin + width - 1) if inner == "up"
                        else labels(origin + width - 1, origin))
        self.cells = {}
        for ordinal, row in enumerate(self.rows):
            bits = pattern(width, ordinal * 3 + 1)
            bits = ("0" if ordinal == 1 else "1") + bits[1:]
            self.cells.update({(row, column): bit for column, bit in zip(self.columns, bits)})

    def bit(self, row, column):
        return self.cells.get((row, column), "x" if self.state == "logic" else "0")

    def word(self, row):
        return "".join(self.bit(row, column) for column in self.columns)

    def whole(self):
        return "".join(self.word(row) for row in self.rows)

    def selected_labels(self, base, span, operation):
        if base is None:
            return [None] * span
        low = base if operation == "+:" else base - span + 1
        result = list(range(low, low + span))
        return result if self.columns[0] < self.columns[-1] else result[::-1]

    def window(self, row, base, span, operation):
        return "".join(self.cells.get((row, c), "x")
                       for c in self.selected_labels(base, span, operation))

    def write_bit(self, row, column, bit):
        if (row, column) in self.cells:
            self.cells[row, column] = bit

    def write_word(self, row, bits):
        for column, bit in zip(self.columns, bits):
            self.write_bit(row, column, bit)

    def write_window(self, row, base, span, operation, data):
        for column, bit in zip(self.selected_labels(base, span, operation), data):
            self.write_bit(row, column, bit)


def observe(lines, expected, label, expression, bits):
    lines.append(f'    $display("{label}=%b", {expression});')
    expected.append(label + "=" + bits)


def make_case(width, outer, inner, form, origin=-5):
    suffix = "_zero" if origin == 0 else ""
    name = f"test_gen_packed_lane_{form}_{outer}_{inner}{suffix}_w{width}"
    state = "logic" if form == "boundary" else "bit"
    b = Bank(width, outer, inner, state, origin)
    low, high = origin, origin + width - 1
    left, right = b.rows[0], b.rows[-1]
    col_left, col_right = b.columns[0], b.columns[-1]
    inner_range = ("-5:W-6" if inner == "up" else "W-6:-5") if origin == -5 else (
        "0:W-1" if inner == "up" else "W-1:0")
    declarations = [f"  {state} signed [{left}:{right}][{inner_range}] bank;",
                    "  integer row, col, base, src_base;"]
    lines, expected = [], [f"width={width} outer={outer} inner={inner} form={form}"]
    assign_literal(lines, "bank", b.whole())
    observe(lines, expected, "initial", "bank", b.whole())
    clauses = "7.4.1 7.4.5 11.5.1 6.11.2 10.4.1"
    if form == "bits":
        operations = [(left, col_left), (right, col_right), (0, low + width // 2),
                      (left, low + width // 2)]
        for phase, (row, column) in enumerate(operations):
            lines += [f"    row = {row};", f"    col = {column};"]
            observe(lines, expected, f"p{phase}_before", "bank[row][col]", b.bit(row, column))
            lines.append("    bank[row][col] = ~bank[row][col];")
            b.write_bit(row, column, "0" if b.bit(row, column) == "1" else "1")
            observe(lines, expected, f"p{phase}_whole", "bank", b.whole())
            observe(lines, expected, f"p{phase}_lane", "bank[row]", b.word(row))
            observe(lines, expected, f"p{phase}_after", "bank[row][col]", b.bit(row, column))
        note = ("Both packed dimensions use declared nonzero labels. Runtime signed row "
                "and column variables select one bit, including negative labels and bits "
                "on different storage words. Each toggle is followed by the full bank, "
                "the selected lane and the selected bit, exposing unintended neighboring writes.")
    elif form == "window":
        declarations += ["  localparam int SPAN = 17;", "  bit [SPAN-1:0] patch;"]
        patch = "10110100011001101"
        assign_literal(lines, "patch", patch)
        first = low + width // 3
        destination = low + 17 + width // 5
        operations = [
            (left, first, "+:", None, None, None),
            (0, destination, "-:", left, first, "+:"),
            (left, first + 3, "+:", left, first, "+:"),
            (right, high, "-:", 0, destination, "-:"),
        ]
        for phase, (row, base, operation, peer, peer_base, peer_operation) in enumerate(operations):
            lines += [f"    row = {row};", f"    base = {base};"]
            if peer is None:
                rhs, bits = "patch", patch
            else:
                lines.append(f"    src_base = {peer_base};")
                rhs = f"bank[{peer}][src_base {peer_operation} SPAN]"
                bits = b.window(peer, peer_base, 17, peer_operation)
            observe(lines, expected, f"p{phase}_source", rhs, bits)
            # Literal outer write coordinates also exercise the supported fixed-lane path.
            lines.append(f"    bank[{row}][base {operation} SPAN] = {rhs};")
            b.write_window(row, base, 17, operation, bits)
            observe(lines, expected, f"p{phase}_whole", "bank", b.whole())
            observe(lines, expected, f"p{phase}_window", f"bank[row][base {operation} SPAN]", bits)
        note = ("Seventeen-bit windows use both indexed directions. A patch is copied to "
                "another lane, an overlapping source is copied within the original lane, "
                "and a third lane receives a later copy. The complete right-hand value is "
                "taken before a blocking write. All windows are in range; snapshots retain "
                "every unselected bit and neighboring lane.")
    elif form == "signatures":
        declarations += ["  bit [W+4:0] extended, signed_extended, named_extended, part_extended;",
                         "  bit signed [W-1:0] named;",
                         "  bit [3*W+4:0] whole_signed, whole_unsigned;"]
        initial = b.whole()
        lines += ["    whole_signed = bank;", "    whole_unsigned = $unsigned(bank);"]
        observe(lines, expected, "whole_signed", "whole_signed", initial[0] * 5 + initial)
        observe(lines, expected, "whole_unsigned", "whole_unsigned", "0" * 5 + initial)
        for phase, row in enumerate(b.rows):
            base = low + width // 3
            lines += [f"    row = {row};", f"    base = {base};", f"    col = {col_left};",
                      "    extended = bank[row];", "    signed_extended = $signed(bank[row]);",
                      "    named = bank[row];", "    named_extended = named;",
                      "    part_extended = bank[row][base +: 17];"]
            bits = b.word(row)
            observe(lines, expected, f"p{phase}_lane", "bank[row]", bits)
            observe(lines, expected, f"p{phase}_unsigned", "extended", "0" * 5 + bits)
            observe(lines, expected, f"p{phase}_signed", "signed_extended", bits[0] * 5 + bits)
            observe(lines, expected, f"p{phase}_named", "named_extended", bits[0] * 5 + bits)
            selected = b.window(row, base, 17, "+:")
            observe(lines, expected, f"p{phase}_part", "part_extended", "0" * (width + 5 - 17) + selected)
            lines += [f'    $display("p{phase}_bits=%0d,%0d",',
                      "             $bits(bank[row]), $bits(bank[row][col]));"]
            expected.append(f"p{phase}_bits={width},1")
        clauses += " 11.7 11.8.1 11.8.2 20.5 20.6.2"
        note = ("A directly declared multidimensional packed array is signed as a whole, "
                "but its selected lanes and bit part-selects are unsigned. Signed casts "
                "and assignment to a named signed vector provide separate extension "
                "controls. Negative and nonnegative lane values are observed through full "
                "binary data and fixed widths, without host-sized integer conversion.")
    else:
        assert form == "boundary"
        declarations += ["  localparam int SPAN = 9;", "  logic [SPAN-1:0] patch;",
                         "  logic [W-1:0] word_data;"]
        for phase, (row, base, operation, patch) in enumerate([
            (0, high - 3, "+:", "10xz10110"),
            (right, low + 3, "-:", "z01x11001"),
        ]):
            lines += [f"    row = {row};", f"    base = {base};"]
            assign_literal(lines, "patch", patch)
            expr = f"bank[row][base {operation} SPAN]"
            observe(lines, expected, f"p{phase}_before", expr, b.window(row, base, 9, operation))
            lines.append(f"    bank[{row}][base {operation} SPAN] = patch;")
            b.write_window(row, base, 9, operation, patch)
            observe(lines, expected, f"p{phase}_whole", "bank", b.whole())
            observe(lines, expected, f"p{phase}_after", expr, b.window(row, base, 9, operation))
        assign_literal(lines, "word_data", pattern(width, 9))
        for label, literal, row in [("outside", "3", 3), ("unknown", "'x", None)]:
            lines += [f"    row = {literal};", f"    col = {col_left};"]
            observe(lines, expected, label + "_lane", "bank[row]", b.word(row))
            observe(lines, expected, label + "_bit", "bank[row][col]", b.bit(row, col_left))
            lines.append("    bank[row] = word_data;")
            observe(lines, expected, label + "_whole", "bank", b.whole())
        lines += ["    row = 0;", "    base = 'x;"]
        observe(lines, expected, "unknown_part", "bank[row][base +: SPAN]", "x" * 9)
        lines.append("    bank[0][base +: SPAN] = patch;")
        observe(lines, expected, "unknown_part_whole", "bank", b.whole())
        lines += ["    row = 0;", "    bank[row] = word_data;"]
        b.write_word(0, pattern(width, 9))
        observe(lines, expected, "recovered_whole", "bank", b.whole())
        observe(lines, expected, "recovered_lane", "bank[row]", b.word(0))
        note = ("Runtime windows extend beyond each end of one packed lane. Only valid "
                "lane bits are written, even though adjacent bits exist in the complete "
                "bank. Invalid and unknown outer indices read X and ignore whole-lane "
                "writes. An unknown inner base ignores its partial write. A later valid "
                "whole-lane write provides a recovery control; all bank bits remain observed.")
    if origin == 0:
        note = note.replace("Both packed dimensions use declared nonzero labels.",
                            "The outer packed range has negative labels; the inner range starts at zero.")
        note += " This is the zero-origin control for the corresponding offset-inner-range case."
        expected[0] += " origin=0"
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form], clauses, note, "\n".join(body),
                "\n".join(expected) + "\n", fourstate=form == "boundary")


def cases():
    return [make_case(w, o, i, f, origin) for origin in (-5, 0)
            for w in WIDTHS for o in DIRECTIONS for i in DIRECTIONS for f in FORMS]

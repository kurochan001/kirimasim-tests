# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Overlapping fixed array slices and the coordinates captured by an NBA."""

from itertools import product

from common import Case

NAME = "unpacked_slice_updates"
VERSION = 1
CHAPTER = 10


def make_case(width, descending, rank, timing, shift):
    indices = (8, 7, 6, 5, 4, 3) if descending else (-3, -2, -1, 0, 1, 2)
    source, destination = (1, 2) if shift == "right" else (2, 1)
    source_indices = indices[source:source + 3]
    destination_indices = indices[destination:destination + 3]
    source_only, = set(source_indices) - set(destination_indices)
    guard_slot = indices.index(source_only)
    mask = (1 << width) - 1
    digits = (width + 3) // 4
    values = [tuple(((0xA31C5D916D604B2C + row * 0x39B52D7413A2E731
                      + col * 0x54AF9CCB0E7D396D) & mask)
                    for col in range(rank)) for row in range(6)]
    guard_write = (0x1891BE1FA15CCB7D3 & mask, *values[guard_slot][1:])
    copied = list(values)
    copied[destination:destination + 3] = values[source:source + 3]
    pending = list(values)
    pending[guard_slot] = guard_write
    copied[guard_slot] = guard_write

    def observe(label, rows):
        return label + "=" + "/".join(
            ":".join(f"{word:0{digits}x}" for word in row) for row in rows)

    operation = {"blocking": "=", "nba": "<=", "delayed": "<= #2"}[timing]
    order = "down" if descending else "up"
    name = f"test_gen_unpacked_slice_{width}_{order}_r{rank}_{timing}_{shift}"

    def internal(i, c):
        return f"words[{i}]" if rank == 1 else f"words[{i}][{c - 2}]"

    declarations = [f"  typedef logic [{width - 1}:0] word_t;"]
    if rank == 2:
        declarations += ["  typedef word_t row_t[-2:-1];"]
    container_type = "word_t" if rank == 1 else "row_t"
    declarations += [f"  {container_type} words[{indices[0]}:{indices[-1]}];",
                     "  int src, dst;"]
    show = ["  task automatic observe(input string label);", '    $write("%s=", label);']
    for slot, i in enumerate(indices):
        separator = "/" if slot else ""
        if rank == 1:
            show += [f'    $write("{separator}%h", {internal(i, 0)});']
        else:
            show += [f'    $write("{separator}%h:%h", {internal(i, 0)}, {internal(i, 1)});']
    show += ['    $display("");', "  endtask"]
    lines = [f"    {internal(i, c)} = {width}'h{values[row][c]:x};"
             for row, i in enumerate(indices) for c in range(rank)]
    lines += [f"    src = {min(source_indices)};",
              f"    dst = {min(destination_indices)};",
              '    observe("before");', f"    words[dst+:3] {operation} words[src+:3];"]
    expected = [observe("before", values)]
    if timing != "blocking":
        lines += ['    observe("scheduled");', f"    src = {min(indices[0:3])};",
                  f"    dst = {min(indices[3:6])};"]
        expected += [observe("scheduled", values)]
    lines += [f"    {internal(source_only, 0)} = {width}'h{guard_write[0]:x};"]
    if timing == "delayed":
        lines += ["    #1;", '    observe("early");', "    #2;"]
        expected += [observe("early", pending)]
    elif timing == "nba":
        lines += ["    #1;"]
    lines += ['    observe("after");']
    expected += [observe("after", copied)]
    assignment = "10.4.1" if timing == "blocking" else "10.4.2"
    clauses = f"{assignment} 7.6 7.4.6"
    body = "\n".join(["`timescale 1ns/1ns", f"module {name};", *declarations, *show,
                      "  initial begin", *lines, "  end", "endmodule"])
    return Case(name, "Overlapping unpacked slices copy values in declaration order",
                clauses,
                "Copy three overlapping entries or rows by indexed slices. For an NBA, "
                "change both indices and modify a source-only word after scheduling. "
                "Observe every word and check the pre-update state for a delayed assignment.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product((8, 33, 65), (False, True), (1, 2),
                                              ("blocking", "nba", "delayed"), ("left", "right"))]

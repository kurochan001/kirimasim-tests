# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Foreach traversals of changing ragged rows and mixed packed dimensions."""

from itertools import product

from common import Case

NAME = "foreach_ragged_arrays"
VERSION = 1
CHAPTER = 12

LAYOUTS = {
    "fixed_up": ("[-2:0]", (-2, -1, 0)),
    "fixed_down": ("[4:2]", (4, 3, 2)),
    "dynamic": ("[]", (0, 1, 2)),
}
PROFILES = {"holes": (0, 3, 1), "empty": (0, 0, 0), "dense": (2, 1, 3), "middle": (0, 2, 0)}
LOOPS = {
    "outer": ("i", '"row %0d size=%0d", i, rows[i].size()'),
    "cells": ("i,j", '"cell %0d/%0d word=%h", i, j, rows[i][j]'),
    "all": ("i,j,k,l", '"bit %0d/%0d/%0d/%0d=%b", i, j, k, l, rows[i][j][k][l]'),
    "skip_packed": ("i,j,,l", '"bit %0d/%0d/%0d=%b", i, j, l, rows[i][j][1][l]'),
}


def make_case(layout, profile, loop):
    declaration, indices = LAYOUTS[layout]
    lengths = PROFILES[profile]
    loop_vars, display = LOOPS[loop]
    name = f"test_gen_foreach_ragged_{layout}_{profile}_{loop}"
    expected = []
    phases = []
    for phase, sizes in enumerate((lengths, (lengths[2], lengths[0] + 1, lengths[1]))):
        if layout == "dynamic" and phase == 1:
            sizes = sizes[1:]
        expected.append(f"phase={phase}")
        if layout == "dynamic":
            phases.append(f"    rows = new[{len(sizes)}];")
        for slot, (i, size) in enumerate(zip(indices, sizes)):
            phases.append(f"    rows[{i}] = new[{size}];")
            if loop == "outer":
                expected.append(f"row {i} size={size}")
            for j in range(size):
                word = (0x15 + phase * 11 + slot * 13 + j * 7) & 0x3F
                phases.append(f"    rows[{i}][{j}] = 6'h{word:02x};")
                if loop == "cells":
                    expected.append(f"cell {i}/{j} word={word:02x}")
                if loop in ("all", "skip_packed"):
                    packed_rows = (2, 1) if loop == "all" else (1,)
                    for k, l in product(packed_rows, (-1, 0, 1)):
                        bit = (word >> ((k - 1) * 3 + 1 - l)) & 1
                        label = f"{i}/{j}/{k}/{l}" if loop == "all" else f"{i}/{j}/{l}"
                        expected.append(f"bit {label}={bit}")
        phases += [f'    $display("phase={phase}");', "    trace_rows();"]

    steps = "\n".join(phases)
    body = f"""module {name};
  typedef logic [2:1][-1:1] lane_t;
  typedef lane_t row_t[];
  row_t rows{declaration};

  task automatic trace_rows;
    foreach (rows[{loop_vars}])
      $display({display});
  endtask

  initial begin
{steps}
  end
endmodule"""
    return Case(name, "Foreach follows current ragged sizes and declared packed directions",
                "12.7.3 20.7",
                "Observe outer indices, existing cells or selected packed coordinates. "
                "For a skipped dimension, use an explicit packed index in the body. "
                "Replace row storage between traversals and include rows of length zero.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(LAYOUTS, PROFILES, LOOPS)]

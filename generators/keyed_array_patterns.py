# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Keyed, typed and replicated patterns for fixed arrays of named rows."""

from itertools import product

from common import Case

NAME = "keyed_array_patterns"
VERSION = 1
CHAPTER = 10

OUTER = {"up": (-2, -1, 0), "down": (4, 3, 2)}
INNER = {"up": (-3, -2, -1, 0), "down": (6, 5, 4, 3)}
FORMS = ("replicate", "keyed", "leaf_type", "row_type")


def make_case(width, outer_order, inner_order, form):
    rows, columns = OUTER[outer_order], INNER[inner_order]
    row_index, column_index = rows[1], columns[2]
    name = f"test_gen_keyed_pattern_{width}_{outer_order}_{inner_order}_{form}"
    override = f"'{{{column_index}: alternate, default: inside_row}}"
    expressions = {
        "replicate": "'{3{'{4{base}}}}",
        "keyed": f"'{{{row_index}: {override}, default: '{{default: base}}}}",
        "leaf_type": f"'{{word_t: base, {row_index}: {override}}}",
        "row_type": f"'{{row_t: row_t'{{default: base}}, {row_index}: {override}}}",
    }
    pattern = expressions[form]
    bits = (1 << width) - 1
    places = (width + 3) // 4
    values = [tuple(v & bits for v in row) for row in
              ((0x194C25AF36712D8E7, 0x049E306591CA744A1, 0x1715C8323C8C1A235),
               (0x01F813653CA4762D8, 0x1AFB77A5D15CE2182, 0x03B4E217525E0A460))]
    steps, expected = [], []
    for phase, (base, inside_row, alternate) in enumerate(values):
        steps += [f"    base = {width}'h{base:x};"]
        if form != "replicate":
            steps += [f"    inside_row = {width}'h{inside_row:x};",
                      f"    alternate = {width}'h{alternate:x};"]
        steps += [f"    grid = {pattern};", f'    $display("p{phase}");', "    show_grid();"]
        expected.append(f"p{phase}")
        for row in rows:
            data = [base] * len(columns)
            if form != "replicate" and row == row_index:
                data = [inside_row] * len(columns)
                data[columns.index(column_index)] = alternate
            expected.append(f"row {row}:" + "".join(f" {v:0{places}x}" for v in data))
    content = "\n".join(steps)
    variables = "base" if form == "replicate" else "base, inside_row, alternate"
    outer_step = "row++" if outer_order == "up" else "row--"
    outer_limit = "<=" if outer_order == "up" else ">="
    inner_step = "col++" if inner_order == "up" else "col--"
    inner_limit = "<=" if inner_order == "up" else ">="
    body = f"""module {name};
  typedef bit [{width - 1}:0] word_t;
  typedef word_t row_t[{columns[0]}:{columns[-1]}];
  row_t grid[{rows[0]}:{rows[-1]}];
  word_t {variables};

  task automatic show_grid;
    for (int row = {rows[0]}; row {outer_limit} {rows[-1]}; {outer_step}) begin
      $write("row %0d:", row);
      for (int col = {columns[0]}; col {inner_limit} {columns[-1]}; {inner_step})
        $write(" %h", grid[row][col]);
      $display("");
    end
  endtask

  initial begin
{content}
  end
endmodule"""
    return Case(name, "Array patterns apply keys and replication in declared dimensions",
                "10.9.1",
                "Check every element in nonzero ascending or descending dimensions. "
                "Use dimension-sized replication, explicit index overrides, a default, "
                "or a type key that matches a row or descends to its elements. "
                "Repeat after changing the source values.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product((8, 33, 64, 65), OUTER, INNER, FORMS)]

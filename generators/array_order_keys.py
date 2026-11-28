# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Order packed records by typed and compound keys in unpacked containers."""

from itertools import product

from common import Case

NAME = "array_order_keys"
VERSION = 1
CHAPTER = 7

LAYOUTS = {
    "fixed_up": ("[-2:2]", tuple(range(-2, 3))),
    "fixed_down": ("[6:2]", tuple(range(6, 1, -1))),
    "dynamic": ("[]", tuple(range(5))),
    "queue": ("[$]", tuple(range(5))),
}
KEYS = {
    "signed": "entry.key",
    "unsigned": "$unsigned(entry.key)",
    "concat": "{entry.key[KEY_MSB -: 2], entry.rank}",
    "signed_concat": "$signed({entry.key[KEY_MSB -: 2], entry.rank})",
}
OBSERVATIONS = {
    (33, "fixed_up", "signed"): " The signed key sorts as unsigned on Verilator 5.054.",
    (33, "fixed_down", "unsigned"): " Sorting follows increasing indices on Verilator 5.054.",
}


def signed(value, width):
    sign = 1 << (width - 1)
    return (value ^ sign) - sign


def make_case(width, layout, key_mode):
    declaration, indices = LAYOUTS[layout]
    sign = 1 << (width - 1)
    rows = [(sign + 3, 0xA, 0x19), (2, 3, 0x2E), (sign - 1, 0xC, 0x3D),
            (sign + 1, 5, 0x40), (5, 8, 0x58)]

    def key(row):
        word, rank, _ = row
        if key_mode == "signed":
            return signed(word, width)
        if key_mode == "unsigned":
            return word
        compound = (word >> (width - 2)) * 16 + rank
        return signed(compound, 6) if key_mode == "signed_concat" else compound

    ascending = sorted(rows, key=key)
    assert len({key(row) for row in rows}) == len(rows)
    places = (width + 3) // 4

    def line(label, values):
        payload = " ".join(f"{word:0{places}x}/{rank:x}/{ident:02x}"
                           for word, rank, ident in values)
        return f"{label}: {payload}"

    name = f"test_gen_array_order_key_{width}_{layout}_{key_mode}"
    expected = [line("before", rows), line("sort", ascending),
                line("rsort", ascending[::-1]), line("reverse", ascending), line("saved", rows)]
    allocation = "    records = new[5];\n" if layout == "dynamic" else ""
    entries = [f"{{{width}'h{word:x}, 4'h{rank:x}, 8'h{ident:x}}}"
               for word, rank, ident in rows]
    if layout == "queue":
        initialization = ["    records = {" + ",\n               ".join(entries) + "};"]
    else:
        initialization = [f"    records[{i}] = {value};" for i, value in zip(indices, entries)]
    initialization = "\n".join(initialization)
    # Access through declared coordinates so the output does not depend on foreach.
    stride = indices[1] - indices[0]
    index = f"{indices[0]} + position" if stride > 0 else f"{indices[0]} - position"
    key_expr = KEYS[key_mode]
    body = f"""module {name};
  localparam int KEY_MSB = {width - 1};
  typedef struct packed {{
    logic signed [KEY_MSB:0] key;
    logic [3:0] rank;
    logic [7:0] payload;
  }} entry_t;
  entry_t records{declaration}, saved{declaration};

  task automatic show(input string label, input bit use_saved);
    entry_t value;
    $write("%s:", label);
    for (int position = 0; position < 5; position++) begin
      value = use_saved ? saved[{index}] : records[{index}];
      $write(" %h/%h/%h", value.key, value.rank, value.payload);
    end
    $display("");
  endtask

  initial begin
{allocation}{initialization}
    saved = records;
    show("before", 0);
    records.sort(entry) with ({key_expr});
    show("sort", 0);
    records.rsort(entry) with ({key_expr});
    show("rsort", 0);
    records.reverse();
    show("reverse", 0);
    show("saved", 1);
  end
endmodule"""
    return Case(name, "Array ordering uses the width and sign of its key expression",
                "7.12.2 7.12 7.6 11.8.1",
                "Use full-width field keys and concatenated subkeys. Two records share a "
                "leading subkey; the low subkey breaks that tie. Observe every field in "
                "declaration order after each operation and in an independent value copy."
                + OBSERVATIONS.get((width, layout, key_mode), ""),
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product((8, 33, 64, 65), LAYOUTS, KEYS)]

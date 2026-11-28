# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Runtime queue slices used in assignments and unpacked concatenations."""

from itertools import product

from common import Case

NAME = "queue_slice_composition"
VERSION = 1
CHAPTER = 7

VALUES = (31, -42, 53, -64, 75, -86, 97, -108)
WINDOWS = {
    "tail": ("lo", "$", lambda n: (1, n - 1)),
    "relative": ("$-distance", "$-1", lambda n: (n - 1 - 3, n - 2)),
    "clipped": ("lo-distance", "$+distance", lambda n: (-2, n - 1 + 3)),
    "past_end": ("$+1", "$+1", lambda n: (n, n)),
    "reverse": ("$+1", "$", lambda n: (n, n - 1)),
    "unknown": ("lo", "bad", lambda n: (1, None)),
}
OBSERVATIONS = {
    (1, "copy", "tail"): " Verilator 5.054 returns the single element for source[1:0].",
    (1, "self", "tail"): " Verilator 5.054 adds the single element between the sentinels.",
    (1, "copy", "unknown"): " Icarus Verilog 13.0 aborts in vvp with a thread-context assertion.",
}


def queue_line(label, values):
    cells = "".join(f" {value}" for value in values)
    return f"{label} size={len(values)}:{cells}"


def make_case(length, context, window):
    low_expr, high_expr, bounds = WINDOWS[window]
    low, high = bounds(length)
    original = list(VALUES[:length])
    selected = [] if high is None or max(0, low) > min(high, length - 1) else (
        original[max(0, low):min(high, length - 1) + 1])
    source = ", ".join(map(str, original))
    selection = f"source[{low_expr}:{high_expr}]"
    name = f"test_gen_queue_slice_{length}_{context}_{window}"
    result = selected if context == "copy" else [101, *selected, -202]
    observed_queue = "result" if context == "copy" else "source"
    assignment = (f"result = {selection};" if context == "copy" else
                  f"source = {{head, {selection}, tail}};")
    expected = [queue_line("saved", original), queue_line("selected", result),
                queue_line("grown", [*result, 303]), queue_line("saved_again", original)]
    if context == "copy":
        expected.append(queue_line("original", original))
    bad_decl = "  logic [3:0] bad;\n" if window == "unknown" else ""
    bad_init = "    bad = 4'b0z10;\n" if window == "unknown" else ""
    original_observation = '\n    show("original", source);' if context == "copy" else ""

    body = f"""module {name};
  typedef int queue_t[$];
  queue_t source = {{{source}}};
  queue_t saved, result;
  int lo, distance, head, tail;
{bad_decl}
  task automatic show(input string label, input queue_t values);
    $write("%s size=%0d:", label, values.size());
    foreach (values[i]) $write(" %0d", values[i]);
    $display("");
  endtask

  initial begin
    lo = 1;
    distance = 3;
    head = 101;
    tail = -202;
{bad_init}    saved = source;
    show("saved", saved);
    {assignment}
    show("selected", {observed_queue});
    {observed_queue}.push_back(303);
    show("grown", {observed_queue});
    show("saved_again", saved);{original_observation}
  end
endmodule"""
    return Case(name, "Runtime queue slice composes with assignment and preserves its source",
                "7.10.1 10.10",
                "Exercise bounds relative to the last index, clipping, empty results and "
                "an unknown endpoint. Compare a value copy and an overlapping self-assignment "
                "that concatenates two scalar sentinels around the slice."
                + OBSERVATIONS.get((length, context, window), ""),
                body, "\n".join(expected) + "\n", fourstate=window == "unknown")


def cases():
    return [make_case(*row) for row in product((1, 3, 5, 8), ("copy", "self"), WINDOWS)]

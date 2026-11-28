# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Input and output connectivity through non-ANSI composite ports."""

from itertools import product

from common import Case
from stream_boundaries import pattern

NAME = "nonansi_port_slices"
VERSION = 1
CHAPTER = 23

FORMS = ("named", "swapped", "bit_mix", "ordered", "single")


def make_case(width, ascending, direction, form):
    start, stop, step = (-3, width - 4, 1) if ascending else (width - 4, -3, -1)
    coordinates = list(range(start, stop + step, step))
    if form == "single":
        groups = (coordinates[width//2-2:width//2+4],)
    elif form == "bit_mix":
        groups = (coordinates[1:2], coordinates[width//2-2:width//2+4], coordinates[-3:-2])
    else:
        groups = (coordinates[1:6], coordinates[-8:-2])
        if form == "swapped":
            groups = groups[::-1]
    paths = [f"lane[{g[0]}:{g[-1]}]" if len(g) > 1 else f"lane[{g[0]}]" for g in groups]
    port = paths[0] if form == "single" else "{" + ", ".join(paths) + "}"
    if form != "ordered":
        port = f".transfer({port})"
    indices = [bit for group in groups for bit in group]
    port_width = len(indices)
    geometry = "up" if ascending else "down"
    name = f"test_gen_nonansi_slices_{width}_{geometry}_{direction}_{form}"

    if direction == "input":
        boundary = "output wire"
        second_port = "monitor"
        connection = "stimulus, observed" if form == "ordered" else ".transfer(stimulus), .monitor(observed)"
        stimulus_width, observed_width = port_width, width
        assign = "monitor = lane"
    else:
        boundary = "input wire"
        second_port = "provided"
        connection = "observed, stimulus" if form == "ordered" else ".transfer(observed), .provided(stimulus)"
        stimulus_width, observed_width = width, port_width
        assign = "lane = provided"
    first = pattern(stimulus_width, 3)
    second = first.translate(str.maketrans("01", "10"))
    expected, steps = [], []
    for phase, stimulus in enumerate((first, second)):
        if direction == "input":
            signals = dict(zip(indices, stimulus))
            seen = "".join(signals.get(i, "z") for i in coordinates)
        else:
            signals = dict(zip(coordinates, stimulus))
            seen = "".join(signals[i] for i in indices)
        expected.append(f"p{phase} stimulus={stimulus} observed={seen}")
        steps += [f"    stimulus = {stimulus_width}'b{stimulus};", "    #1;",
                  f'    $display("p{phase} stimulus=%b observed=%b", stimulus, observed);']
    run = "\n".join(steps)
    body = f"""`timescale 1ns/1ns
module selected_port ({port}, {second_port});
  {direction} wire [{start}:{stop}] lane;
  {boundary} [{start}:{stop}] {second_port};
  assign {assign};
endmodule

module {name};
  logic [{stimulus_width - 1}:0] stimulus;
  wire [{observed_width - 1}:0] observed;
  selected_port u ({connection});
  initial begin
{run}
  end
endmodule"""
    description = ("Non-ANSI sliced ports route bits by expression position" if form == "single"
                   else "Non-ANSI composite ports route bits by expression position")
    comment = ("Connect a single slice of a nonzero-based net as a control for the "
               "composite port expression. Drive two values and observe the routing."
               if form == "single" else
               "Connect disjoint slices of a nonzero-based net through a port expression. "
               "Vary part order, mix bit selects with a slice, or connect by position. "
               "Drive two values, and check the internal net or the gathered output. "
               "For input ports, unconnected internal bits have no driver.")
    return Case(name, description,
                "23.2.2.1 23.3.2 23.3.3",
                comment, body, "\n".join(expected) + "\n", fourstate=direction == "input",
                extra={"top_module": name})


def cases():
    return [make_case(*row) for row in product((32, 33, 64, 65), (False, True),
                                              ("input", "output"), FORMS)]

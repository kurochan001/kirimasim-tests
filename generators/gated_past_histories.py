# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent histories for procedural gated sampled-value functions."""

from itertools import product

from common import Case

NAME = "gated_past_histories"
VERSION = 1
CHAPTER = 16

INITIAL = "11010011"
GATES = {
    "alternating": ("101010101010", "011001101010"),
    "sparse": ("101001010101", "110001001110"),
    "bursts": ("111110000010", "001011110011"),
    "overlap": ("011010111001", "010111011010"),
}
VALUES = (0x31, 0xA6, 0xB0, 0x0D, 0xE5, 0x47, 0x8C, 0x5B, 0xF2, 0x69, 0xD7, 0x14)


def make_case(depth, profile, clock, known):
    first, second = GATES[profile]
    state = "known" if known else "xz"
    name = f"test_gen_gated_past_{depth}_{profile}_{clock}_{state}"
    expected, steps = [], []
    ungated, a_values, b_values = [], [], []

    def previous(history):
        return history[-depth] if len(history) >= depth else INITIAL

    for tick, (value, a, b) in enumerate(zip(VALUES, first, second), 1):
        bits = f"{value:08b}"
        if not known and tick % 3:
            i = tick % len(bits)
            bits = bits[:i] + ("x" if tick % 3 == 1 else "z") + bits[i+1:]
        expected += [f"tick={tick:02} raw={previous(ungated)} "
                     f"a={previous(a_values)} b={previous(b_values)}"]
        steps += [f"    #1 data = 8'b{bits}; gate_a = 1'b{a}; gate_b = 1'b{b};",
                  "    #1 clk = 1;", "    #1 clk = 0;"]
        ungated.append(bits)
        if a == "1":
            a_values.append(bits)
        if b == "1":
            b_values.append(bits)
    clock_arg = ", @(posedge clk)" if clock == "explicit" else ""
    omitted_gate = ", " if clock_arg else ""
    plain = f"$past(data, {depth}{omitted_gate}{clock_arg})"
    first_call = f"$past(data, {depth}, gate_a{clock_arg})"
    second_call = f"$past(data, {depth}, gate_b{clock_arg})"
    stimulus = "\n".join(steps)
    data_type = "bit" if known else "logic"
    body = f"""`timescale 1ns/1ns
module {name};
  bit clk = 0;
  bit gate_a = 0, gate_b = 0;
  {data_type} [7:0] data = 8'b{INITIAL};
  int tick = 0;
  always @(posedge clk) begin
    tick++;
    $display("tick=%02d raw=%b a=%b b=%b", tick,
             {plain},
             {first_call},
             {second_call});
  end
  initial begin
{stimulus}
    $finish(0);
  end
endmodule"""
    return Case(name, "Gated past histories skip disabled clock ticks independently",
                "16.9.3 16.5.1 16.14.6",
                "Observe an ungated history and two independently gated histories over "
                "stable input intervals. Vary depth and qualify early history with the "
                "declared default. The four-state cases carry X and Z in data, with known gates.",
                body, "\n".join(expected) + "\n", fourstate=not known)


def cases():
    return [make_case(*row) for row in product((1, 2, 3, 5), GATES,
                                              ("inferred", "explicit"), (True, False))]

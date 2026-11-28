# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Exactly representable integral-to-real values with scattered unknown bits."""

from itertools import product
import struct

from common import Case

NAME = "integral_real_contexts"
VERSION = 1
CHAPTER = 6

WIDTHS = (16, 33, 64, 65, 129)
PROFILES = ("known", "x_data", "z_data", "xz_sign")


def source_bits(width, profile, phase):
    offsets = ((0, 2, 5, 12), (0, 3, 7, 10))[phase]
    bits = ["1" if i in offsets else "0" for i in range(width)]
    if profile == "x_data":
        bits[offsets[1]] = "x"
        bits[-2] = "x"
    elif profile == "z_data":
        bits[offsets[2]] = "z"
        bits[1] = "z"
    elif profile == "xz_sign":
        bits[0] = "xz"[phase]
        bits[offsets[1]] = "zx"[phase]
    return "".join(bits)


def double_encoding(bits, signed):
    value = int(bits, 2)
    if signed and bits[0] == "1":
        value -= 1 << len(bits)
    rounded = float(value)
    assert int(rounded) == value
    return struct.pack(">d", rounded).hex()


def make_case(width, signed, profile, context):
    name = f"test_gen_integral_real_{width}_{'signed' if signed else 'unsigned'}_{profile}_{context}"
    decl = [f"  logic {'signed ' if signed else ''}[{width - 1}:0] source, clean;",
            "  logic [63:0] observed, control;"]
    if context == "assign":
        decl += ["  real sink;"]
        conversion = ["    sink = source;", "    observed = $realtobits(sink);"]
    else:
        decl += ["  function automatic logic [63:0] encode(input real value);",
                 "    return $realtobits(value);", "  endfunction"]
        conversion = ["    observed = encode(source);"]
    lines, expected = [], []
    for phase in range(2):
        bits = source_bits(width, profile, phase)
        clean = bits.replace("x", "0").replace("z", "0")
        encoded = double_encoding(clean, signed)
        for destination, value in (("source", bits), ("clean", clean)):
            # Concatenating the literal pieces preserves the spelling of wide X/Z patterns.
            if width > 64:
                lines += [f"    {destination} = {{{len(value[:64])}'b{value[:64]},",
                          f"               {len(value[64:])}'b{value[64:]}}};"]
            else:
                lines += [f"    {destination} = {width}'b{value};"]
        lines += conversion + ["    control = $realtobits(real'(clean));",
                               f'    $display("p{phase} source=%b", source);',
                               '    $display("real=%h control=%h", observed, control);']
        expected += [f"p{phase} source={bits}", f"real={encoded} control={encoded}"]
    body = "\n".join([f"module {name};", *decl, "  initial begin", *lines, "  end", "endmodule"])
    clauses = "6.12.1 6.12 20.5" + (" 10.8 13.5.1" if context == "formal" else "")
    observation = ""
    if (width, signed, profile, context) == (129, True, "x_data", "assign"):
        observation = " Icarus Verilog 13.0 produces negative zero in the first conversion."
    return Case(name, "Integral conversion to real respects sign and clears unknown bits",
                clauses,
                "Choose sparse integers whose signed or unsigned value is exactly representable "
                "as binary64. Vary X and Z positions, including the sign bit, and compare "
                "the result to a separately assigned zero-substitution control." + observation,
                body, "\n".join(expected) + "\n", fourstate=profile != "known")


def cases():
    return [make_case(*row) for row in product(WIDTHS, (False, True), PROFILES, ("assign", "formal"))]

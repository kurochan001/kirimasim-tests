# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Exact quarter-step binary64 rounding across integral conversion contexts."""

from fractions import Fraction
from itertools import product
import struct

from common import Case

NAME = "real_rounding_contexts"
VERSION = 1
CHAPTER = 6

CENTERS = {"zero": 0, "small": 17, "int16": (1 << 15) - 1, "int32": (1 << 31) - 1,
           "above32": (1 << 32) + 1, "large": (1 << 51) - 1}
QUARTERS = ("25", "50", "75")
FORMS = ("constant", "assign", "argument", "nba")


def make_case(center, negative, form):
    base = CENTERS[center]
    sign = -1 if negative else 1
    name = f"test_gen_real_round_{center}_{'neg' if negative else 'pos'}_{form}"
    declarations = ["  typedef logic signed [64:0] extended_t;"]
    lines, expected = [], []
    fits_int = base <= 0x7FFFFFFF
    if form != "constant":
        declarations += ["  real sample;", "  logic [63:0] raw;",
                         "  longint narrow;", "  extended_t wide;"]
        if fits_int:
            declarations += ["  int truncated;"]
    if form == "argument":
        declarations += ["  function automatic longint receive_narrow(input longint value);",
                         "    return value;", "  endfunction",
                         "  function automatic extended_t receive_wide(input extended_t value);",
                         "    return value;", "  endfunction"]
    for phase, decimal in enumerate(QUARTERS, 1):
        value = Fraction(sign * (base * 4 + phase), 4)
        encoded = float(value)
        assert Fraction(encoded) == value
        bits = struct.pack(">d", encoded).hex()
        rounded = sign * (base + (phase >= 2))
        wide_bits = f"{rounded & ((1 << 65) - 1):017x}"
        if form == "constant":
            spelling = f"{'-' if negative else ''}{base}.{decimal}"
            declarations += [
                f"  localparam real R{phase} = {spelling};",
                f"  localparam longint N{phase} = longint'(R{phase});",
                f"  localparam extended_t W{phase} = extended_t'(R{phase});",
                f"  localparam logic [63:0] B{phase} = $realtobits(R{phase});",
            ]
            raw, narrow, wide = f"B{phase}", f"N{phase}", f"W{phase}"
            if fits_int:
                declarations += [f"  localparam int T{phase} = $rtoi(R{phase});"]
        else:
            lines += [f"    sample = $bitstoreal(64'h{bits});",
                      "    raw = $realtobits(sample);"]
            if fits_int:
                lines += ["    truncated = $rtoi(sample);"]
            raw, narrow, wide = "raw", "narrow", "wide"
            if form == "argument":
                lines += ["    narrow = receive_narrow(sample);",
                          "    wide = receive_wide(sample);"]
            elif form == "nba":
                lines += ["    narrow = 17;", "    wide = 23;",
                          "    narrow <= sample;", "    wide <= sample;",
                          "    sample = 0.0;",
                          '    $display("pending=%0d/%0d", narrow, wide);', "    #1;"]
                expected += ["pending=17/23"]
            else:
                lines += ["    narrow = sample;", "    wide = extended_t'(sample);"]
        truncated_arg = f"T{phase}" if form == "constant" else "truncated"
        if fits_int:
            lines += [f'    $display("p{phase} bits=%h n=%0d w=%h trunc=%0d",',
                      f"             {raw}, {narrow}, {wide}, {truncated_arg});"]
        else:
            lines += [f'    $display("p{phase} bits=%h n=%0d w=%h", {raw}, {narrow}, {wide});']
        trunc_text = f" trunc={sign * base}" if fits_int else ""
        expected += [f"p{phase} bits={bits} n={rounded} w={wide_bits}{trunc_text}"]
    body = "\n".join(["`timescale 1ns/1ns", f"module {name};", *declarations,
                      "  initial begin", *lines, "  end", "endmodule"])
    clauses = "6.12.1 20.5 6.24.1"
    if form == "argument":
        clauses += " 13.5.1"
    if form == "nba":
        clauses += " 10.4.2"
    observation = ""
    if (center, negative, form) == ("zero", True, "assign"):
        observation = " The cast of negative one quarter sets bit 64 in Icarus Verilog 13.0."
    return Case(name, "Real conversion rounds exact halfway values away from zero",
                clauses,
                "Check exact binary64 quarter-step inputs around both signs of a tie. "
                "Observe a signed longint and a wider signed packed value. Compare "
                "truncation when the source fits the result range of the truncation function."
                + observation,
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(CENTERS, (False, True), FORMS)]

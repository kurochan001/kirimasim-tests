# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Runtime wide division/remainder at native-word and power-of-two edges.

The reference divides mathematical signed/unsigned integers, truncates toward
zero, derives the dividend-signed remainder, and retains the declared W bits.
Runtime plusargs supply operand dependencies; no simulator computes the oracle.
"""
from common import Case
from bitvector_queries import assign_literal

NAME = "division_boundaries"
VERSION = 1
CHAPTER = 11
WIDTHS = (63, 64, 65, 127, 128, 129, 255, 256, 257)
FORMS = ("small", "power", "extreme", "compound")
DESCRIPTIONS = {
    "small": "Runtime wide division and remainder preserve signs with small nonzero divisors",
    "power": "Runtime wide division and remainder cross power-of-two word boundaries",
    "extreme": "Runtime wide division and remainder handle extrema and fixed-width overflow",
    "compound": "Compound wide division and remainder evaluate an array index exactly once",
}


def binary(value, width):
    return format(value & ((1 << width) - 1), f"0{width}b")


def quotient_remainder(numerator, denominator):
    assert denominator != 0
    quotient = abs(numerator) // abs(denominator)
    if (numerator < 0) != (denominator < 0):
        quotient = -quotient
    remainder = numerator - quotient * denominator
    assert abs(remainder) < abs(denominator)
    assert remainder == 0 or (remainder < 0) == (numerator < 0)
    return quotient, remainder


def samples(width, signed, form):
    mask, top = (1 << width) - 1, 1 << (width - 1)
    maximum = top - 1 if signed else mask
    minimum = -top if signed else 0
    interior = (1 << (width - 2)) | (1 << (width // 2)) | 0x35
    if form in ("small", "compound"):
        if signed:
            return [(0, 3), (1, -3), (maximum, 3), (maximum - 1, -17),
                    (-1, 5), (minimum, 3), (minimum + 1, -5), (-interior, 257)]
        return [(0, 3), (1, 5), (mask, 3), (mask - 1, 17),
                (top, 5), (top + 1, 17), (interior, 257), (mask - interior, 257)]
    if form == "power":
        limit = width - 2 if signed else width - 1
        exponents = sorted({p for p in (0, 1, 31, 32, 63, 64, 127, 128, 255,
                                        width // 2, limit) if p <= limit})
        rows = []
        for phase, exponent in enumerate(exponents):
            divisor = 1 << exponent
            if signed and phase % 2:
                divisor = -divisor
            numerator = minimum + 37 if signed and phase % 2 else maximum - 19
            rows.append((numerator, divisor))
        return rows
    assert form == "extreme"
    if signed:
        return [(minimum, -1), (minimum, 1), (minimum, minimum), (maximum, -1),
                (maximum, minimum), (-1, minimum), (minimum + 1, -1), (1, minimum)]
    return [(mask, 1), (mask, mask), (0, mask), (top, mask),
            (top, top), (mask, top + 1), (1, mask), (mask - 1, mask - 2)]


def make_case(width, signed, form):
    signing = "signed" if signed else "unsigned"
    name = f"test_gen_division_boundary_{form}_{signing}_w{width}"
    declarations = [f"  typedef bit {signing} [W-1:0] word_t;",
                    "  word_t numerator, denominator, quotient, remainder;",
                    "  integer nonce, found;"]
    if form == "compound":
        declarations += ["  word_t data[0:1];", "  word_t guard;", "  int index_calls;",
                         "  function automatic int selected();",
                         "    index_calls = index_calls + 1;", "    return 1;", "  endfunction"]
    lines = ["    nonce = 0;", '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);']
    expected = [f"width={width} sign={signing} form={form}", "nonce=1 found=1"]
    guard_bits = binary((1 << (width - 2)) | (1 << 17) | 0x69, width)
    if form == "compound":
        assign_literal(lines, "guard", guard_bits)
    for phase, (numerator, denominator) in enumerate(samples(width, signed, form)):
        # The metadata supplies +nonce=1. Its observed runtime value affects
        # both operands, without a guard that would constrain the optimizer.
        assign_literal(lines, "numerator", binary((numerator & ((1 << width) - 1)) ^ 1, width))
        assign_literal(lines, "denominator", binary(denominator - 1, width))
        lines += ["    numerator = numerator ^ word_t'(nonce);",
                  "    denominator = denominator + word_t'(nonce);",
                  "    quotient = numerator / denominator;", "    remainder = numerator % denominator;",
                  f'    $display("p{phase}_n=%b d=%b", numerator, denominator);']
        expected.append(f"p{phase}_n={binary(numerator, width)} d={binary(denominator, width)}")
        quotient, remainder = quotient_remainder(numerator, denominator)
        qbits, rbits = binary(quotient, width), binary(remainder, width)
        if form == "compound":
            lines += ["    data[0] = guard;", "    data[1] = numerator;", "    index_calls = 0;",
                      "    data[selected()] /= denominator;",
                      f'    $display("p{phase}_q=%b guard=%b calls=%0d direct=%b",',
                      "             data[1], data[0], index_calls, quotient);",
                      "    data[0] = guard;", "    data[1] = numerator;", "    index_calls = 0;",
                      "    data[selected()] %= denominator;",
                      f'    $display("p{phase}_r=%b guard=%b calls=%0d direct=%b",',
                      "             data[1], data[0], index_calls, remainder);"]
            expected += [f"p{phase}_q={qbits} guard={guard_bits} calls=1 direct={qbits}",
                         f"p{phase}_r={rbits} guard={guard_bits} calls=1 direct={rbits}"]
        else:
            lines.append(f'    $display("p{phase}_q=%b r=%b", quotient, remainder);')
            expected.append(f"p{phase}_q={qbits} r={rbits}")
    note = ("Both arithmetic operands have the same declared width and signing. A fixed "
            "runtime plusarg is read and observed as a nonzero Boolean result; it makes "
            "operand values depend on runtime input rather than only literal propagation. "
            "Division truncates toward zero and remainder has the numerator's sign. Full "
            "binary operands/results expose native-word boundaries and fixed-width overflow. "
            "Every divisor is nonzero under the recorded +nonce=1 invocation.")
    clauses = "11.4.3 11.6 11.6.1 11.8.1 6.24.1 21.6"
    if form == "compound":
        clauses += " 11.4.1 7.4.2 13.4.1"
        note += (" Compound /= and %= target an unpacked array element with a side-effecting "
                 "index function. Each index must be evaluated once; a neighboring word and "
                 "direct scalar results are separate controls. Only the index counter has a "
                 "side effect, so unspecified LHS/RHS evaluation order cannot alter the values.")
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form], clauses, note, "\n".join(body),
                "\n".join(expected) + "\n", extra={"args": "+nonce=1"})


def cases():
    return [make_case(width, signed, form) for width in WIDTHS
            for signed in (False, True) for form in FORMS]

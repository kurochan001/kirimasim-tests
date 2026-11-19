# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Runtime carry, borrow and full-product observations across word boundaries.

Mathematical integer operations precede explicit fixed-width retention. Wider
assignment, a captured narrow word, a type cast and a self-determined
concatenation are distinct evaluation contexts, each observed independently.
"""
from common import Case
from bitvector_queries import assign_literal

NAME = "arithmetic_context"
VERSION = 1
CHAPTER = 11
WIDTHS = (63, 64, 65, 127, 128, 129, 255, 256, 257)
FORMS = ("multiply", "carry", "borrow", "negate", "mixed")
DESCRIPTIONS = {
    "multiply": "Runtime wide products retain high words according to expression context",
    "carry": "Runtime wide additions distinguish carried results from captured narrow words",
    "borrow": "Runtime wide subtractions preserve borrow and signed extension contexts",
    "negate": "Runtime wide unary negation applies context width before arithmetic",
    "mixed": "Runtime wide mixed-sign products separate joint unsigned and explicit signed contexts",
}


def binary(value, width):
    return format(value & ((1 << width) - 1), f"0{width}b")


def integer(raw, width, signed):
    return raw - (1 << width) if signed and raw & (1 << (width - 1)) else raw


def operation(form, a, b):
    if form in ("multiply", "mixed"):
        return a * b
    if form == "carry":
        return a + b
    if form == "borrow":
        return a - b
    assert form == "negate"
    return -a


def operands(width, form):
    mask, top = (1 << width) - 1, 1 << (width - 1)
    interior = (1 << (width - 2)) | (1 << (width // 2)) | 0x39
    if form in ("multiply", "mixed"):
        return [(0, mask), (1, mask), (mask, mask), (top, top),
                (top - 1, top + 1), (interior, mask - interior),
                (top + 1, 257), (mask - 1, interior)]
    if form == "carry":
        return [(0, 0), (mask, 1), (top - 1, 1), (top, top),
                (mask, mask), (interior, mask - interior), (1, top), (mask - 1, 257)]
    if form == "borrow":
        return [(0, 1), (top, 1), (top - 1, mask), (mask, top),
                (1, mask), (interior, top), (mask, mask), (0, interior)]
    assert form == "negate"
    return [(a, 0) for a in (0, 1, mask, top, top - 1, top + 1, interior, mask - 1)]


def make_case(width, signed, form):
    sign = "signed" if signed else "unsigned"
    peer_signed = not signed if form == "mixed" else signed
    peer_sign = "signed" if peer_signed else "unsigned"
    name = f"test_gen_arithmetic_context_{form}_{sign}_w{width}"
    declarations = [f"  typedef bit {sign} [W-1:0] word_t;",
                    f"  typedef bit {peer_sign} [W-1:0] peer_t;",
                    "  word_t a, wrapped;", "  peer_t b;",
                    "  bit [2*W-1:0] full, captured, casted, concatenated;",
                    "  bit [2*W-1:0] signed_result, unsigned_result;",
                    "  integer nonce, found;"]
    operator = {"multiply": "*", "mixed": "*", "carry": "+", "borrow": "-"}.get(form)
    expression = "-a" if form == "negate" else f"a {operator} b"
    signed_expression = "-$signed(a)" if form == "negate" else (
        f"$signed(a) {operator} $signed(b)")
    unsigned_expression = "-$unsigned(a)" if form == "negate" else (
        f"$unsigned(a) {operator} $unsigned(b)")
    lines = ["    nonce = 0;", '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);']
    expected = [f"width={width} sign={sign} peer={peer_sign} form={form}", "nonce=1 found=1"]
    for phase, (a, b) in enumerate(operands(width, form)):
        assign_literal(lines, "a", binary(a ^ 1, width))
        assign_literal(lines, "b", binary(b ^ 1, width))
        lines += ["    a = a ^ word_t'(nonce);", "    b = b ^ peer_t'(nonce);",
                  f"    wrapped = {expression};", f"    full = {expression};",
                  "    captured = wrapped;", f"    casted = word_t'({expression});",
                  f"    concatenated = {{{expression}}};",
                  f"    signed_result = {signed_expression};",
                  f"    unsigned_result = {unsigned_expression};"]
        joint_signed = signed if form == "negate" else signed and peer_signed
        contextual = operation(form, integer(a, width, joint_signed), integer(b, width, joint_signed))
        wrapped = contextual & ((1 << width) - 1)
        carried = integer(wrapped, width, signed)
        values = [("a", a, width), ("b", b, width), ("wrapped", wrapped, width),
                  ("full", contextual, 2 * width), ("captured", carried, 2 * width),
                  ("casted", carried, 2 * width), ("concatenated", wrapped, 2 * width),
                  ("signed", operation(form, integer(a, width, True), integer(b, width, True)), 2 * width),
                  ("unsigned", operation(form, a, b), 2 * width)]
        for label, value, bits in values:
            variable = {"signed": "signed_result", "unsigned": "unsigned_result"}.get(label, label)
            lines.append(f'    $display("p{phase}_{label}=%b", {variable});')
            expected.append(f"p{phase}_{label}={binary(value, bits)}")
        lines += [f'    $display("p{phase}_bits=%0d,%0d,%0d",',
                  f"             $bits({expression}), $bits({{{expression}}}),",
                  f"             $bits(word_t'({expression})));"]
        expected.append(f"p{phase}_bits={width},{width},{width}")
    note = ("The recorded +nonce=1 affects both complete operands through runtime input. "
            "Narrow assignments retain W bits; a direct 2W-bit assignment propagates that "
            "width before arithmetic. A captured W-bit word and a W-bit typedef cast "
            "extend only after the narrow operation, according to the resulting word type. "
            "A one-item concatenation is self-determined W bits and unsigned. Explicit "
            "signed/unsigned operand casts separately control interpretation while preserving "
            "the operands' bit patterns. Every operand, intermediate, high word and context "
            "width is observed; expectations use mathematical integers and explicit masks.")
    if form == "mixed":
        note += (" The two operands have opposite signing. The uncast expression is unsigned, "
                 "so both operands zero-extend before a wider multiplication. Assigning its "
                 "wrapped result to word_t can subsequently restore the left operand's "
                 "signed interpretation; that later conversion cannot restore lost high bits.")
    if form == "negate":
        note += (" Unary minus has the left operand's signing. Context width reaches the "
                 "operand before negation. The printed b=0 is an initialized unused control.")
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form],
                "11.4.3 11.6 11.6.1 11.8.1 11.8.2 6.24.1 11.4.12 11.7 20.6.2 21.6",
                note, "\n".join(body), "\n".join(expected) + "\n",
                extra={"args": "+nonce=1"})


def cases():
    return [make_case(width, signed, form) for width in WIDTHS
            for signed in (False, True) for form in FORMS]

# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wide four-state operators with unknowns around machine-word boundaries.

Existing clause-derived character truth tables supply the arithmetic reference.
Each program observes its complete operands and both pre-operation and final
two-state conversions; no simulator output supplies expected values.
"""
from common import Case
from bitvector_queries import assign_literal
from interaction_bits import two_state
from xz_propagation import (
    band, bor, bxor, bnot, bitwise, truth, fold, equality, wildcard, merge, shift,
)

NAME = "fourstate_boundaries"
VERSION = 1
CHAPTER = 11
WIDTHS = (63, 64, 65, 127, 128, 129, 255, 256, 257)
FORMS = ("truth", "bitwise", "reduction", "compare", "merge", "shift")
DESCRIPTIONS = {
    "truth": "Wide vector truth uses all bits before logical results become two-state",
    "bitwise": "Wide bitwise controlling values preserve four-state word-boundary data",
    "reduction": "Wide reductions observe controlling and unknown bits in every storage word",
    "compare": "Wide equality distinguishes known mismatches and right-sided unknown wildcards",
    "merge": "Wide conditional selection and ambiguous merging preserve conversion order",
    "shift": "Wide four-state shifts preserve unknown data and inspect the complete shift amount",
}


def positions(width):
    return sorted({p for p in (0, 1, 30, 31, 32, 62, 63, 64, 126, 127, 128,
                               254, 255, 256, width - 1) if p < width})


def replace(bits, position, value):
    index = len(bits) - 1 - position
    return bits[:index] + value + bits[index + 1:]


def pattern(width):
    return "".join("1" if (i * 13 + 7) % 29 < 14 else "0" for i in range(width))


def observations(lines, expected, label, expression, value):
    lines.append(f'    $display("{label}=%b", {expression});')
    expected.append(label + "=" + value)


def packed_results(a, b, form):
    if form == "truth":
        ta, tb = truth(a), truth(b)
        return bnot(ta) + ta + band(ta, tb) + bor(ta, tb)
    if form == "reduction":
        anded, ored, xored = fold(band, a), fold(bor, a), fold(bxor, a)
        return anded + bnot(anded) + ored + bnot(ored) + xored + bnot(xored)
    assert form == "compare"
    equal = equality(a, b)
    case_equal = str(int(a == b))
    wild, reverse = wildcard(a, b), wildcard(b, a)
    return equal + bnot(equal) + case_equal + bnot(case_equal) + wild + bnot(wild) + reverse


def vectors(width, form):
    """Yield complete input pairs, retaining known-data and dominating-bit controls."""
    zero, one, known = "0" * width, "1" * width, pattern(width)
    yield zero, zero
    yield one, one
    for ordinal, position in enumerate(positions(width)):
        peer = (position + 17) % width
        unknown = "x" if ordinal % 2 == 0 else "z"
        if form in ("truth", "reduction"):
            ambiguous = replace(zero, position, unknown)
            yield ambiguous, zero
            yield replace(ambiguous, peer, "1"), one
            yield replace(one, position, unknown), ambiguous
        elif form == "compare":
            a = replace(known, position, unknown)
            yield a, known
            yield known, a
            yield a, a
            yield a, replace(a, peer, bnot(a[len(a) - 1 - peer]))
        else:
            a = replace(replace(known, position, unknown), peer, "z")
            yield a, zero
            yield a, one
            yield a, a
            yield a, replace(a, peer, "0")


def make_case(width, form):
    name = f"test_gen_fourstate_boundary_{form}_w{width}"
    result_width = {"truth": 4, "reduction": 6, "compare": 7}.get(form, width)
    declarations = ["  logic signed [W-1:0] a;", "  logic [W-1:0] b;",
                    "  bit signed [W-1:0] clean_a;", "  bit [W-1:0] clean_b;",
                    f"  logic [{result_width - 1}:0] raw;",
                    f"  bit [{result_width - 1}:0] before_conversion, after_conversion;"]
    lines, expected = [], [f"width={width} form={form}"]
    clauses = "11.6.1 11.8.1 6.11.2"
    if form in ("truth", "reduction", "compare"):
        expression = {
            "truth": "{!a, !(!a), a && b, a || b}",
            "reduction": "{&a, ~&a, |a, ~|a, ^a, ~^a}",
            "compare": "{a == b, a != b, a === b, a !== b, a ==? b, a !=? b, b ==? a}",
        }[form]
        clauses += {"truth": " 11.4.7", "reduction": " 11.4.9",
                    "compare": " 11.4.5 11.4.6"}[form]
        clean_expression = expression.replace("a", "clean_a").replace("b", "clean_b")
        if form == "compare":
            expression = expression.replace(", ", ",\n           ")
            clean_expression = clean_expression.replace(", ", ",\n                         ")
        for phase, (a, b) in enumerate(vectors(width, form)):
            assign_literal(lines, "a", a)
            assign_literal(lines, "b", b)
            lines += ["    clean_a = a;", "    clean_b = b;", f"    raw = {expression};",
                      f"    before_conversion = {clean_expression};", "    after_conversion = raw;"]
            observations(lines, expected, f"p{phase}_a", "a", a)
            observations(lines, expected, f"p{phase}_b", "b", b)
            value = packed_results(a, b, form)
            observations(lines, expected, f"p{phase}_raw", "raw", value)
            observations(lines, expected, f"p{phase}_before", "before_conversion",
                         packed_results(two_state(a), two_state(b), form))
            observations(lines, expected, f"p{phase}_after", "after_conversion", two_state(value))
    elif form == "bitwise":
        clauses += " 11.4.8"
        for phase, (a, b) in enumerate(vectors(width, form)):
            assign_literal(lines, "a", a)
            assign_literal(lines, "b", b)
            lines += ["    clean_a = a;", "    clean_b = b;"]
            observations(lines, expected, f"p{phase}_a", "a", a)
            observations(lines, expected, f"p{phase}_b", "b", b)
            operations = [("and", "a & b", bitwise(band, a, b)),
                          ("or", "a | b", bitwise(bor, a, b)),
                          ("xor", "a ^ b", bitwise(bxor, a, b)),
                          ("xnor", "a ~^ b", "".join(bnot(c) for c in bitwise(bxor, a, b))),
                          ("not", "~a", "".join(bnot(c) for c in a))]
            for label, expression, value in operations:
                lines.append(f"    raw = {expression};")
                observations(lines, expected, f"p{phase}_{label}", "raw", value)
            lines += ["    before_conversion = ~clean_a;", "    after_conversion = ~a;"]
            observations(lines, expected, f"p{phase}_before", "before_conversion",
                         "".join(bnot(c) for c in two_state(a)))
            observations(lines, expected, f"p{phase}_after", "after_conversion",
                         two_state("".join(bnot(c) for c in a)))
    elif form == "merge":
        clauses += " 11.4.11"
        declarations += ["  logic [W-1:0] condition;", "  bit [W-1:0] clean_condition;"]
        for phase, (a, b) in enumerate(vectors(width, form)):
            assign_literal(lines, "a", a)
            assign_literal(lines, "b", b)
            lines += ["    clean_a = a;", "    clean_b = b;"]
            observations(lines, expected, f"p{phase}_a", "a", a)
            observations(lines, expected, f"p{phase}_b", "b", b)
            position = positions(width)[phase % len(positions(width))]
            ambiguous = replace("0" * width, position, "x" if phase % 2 else "z")
            for label, condition in [("zero", "0" * width), ("unknown", ambiguous),
                                     ("one", replace(ambiguous, (position + 17) % width, "1"))]:
                assign_literal(lines, "condition", condition)
                lines += ["    clean_condition = condition;", "    raw = condition ? a : b;",
                          "    before_conversion = clean_condition ? clean_a : clean_b;",
                          "    after_conversion = raw;"]
                value = a if truth(condition) == "1" else b if truth(condition) == "0" else merge(a, b)
                observations(lines, expected, f"p{phase}_{label}_condition", "condition", condition)
                observations(lines, expected, f"p{phase}_{label}_raw", "raw", value)
                clean_value = two_state(a if truth(two_state(condition)) == "1" else b)
                observations(lines, expected, f"p{phase}_{label}_before", "before_conversion", clean_value)
                observations(lines, expected, f"p{phase}_{label}_after", "after_conversion", two_state(value))
    else:
        assert form == "shift"
        clauses += " 11.4.10"
        declarations += ["  logic [64:0] amount;", "  bit [64:0] clean_amount;"]
        shifts = sorted({0, 1, 31, 32, 63, 64, width - 1, width, width + 1, 1 << 32})
        amounts = [f"{n:065b}" for n in shifts]
        amounts += [replace("0" * 65, 64, "x"), replace("0" * 65, 32, "z")]
        for phase, amount in enumerate(amounts):
            a = pattern(width)
            for ordinal, position in enumerate(positions(width)):
                a = replace(a, position, "x" if (ordinal + phase) % 2 else "z")
            a = replace(a, width - 1, ("1", "x", "z")[phase % 3])
            assign_literal(lines, "a", a)
            assign_literal(lines, "amount", amount)
            lines += ["    clean_a = a;", "    clean_amount = amount;"]
            observations(lines, expected, f"p{phase}_a", "a", a)
            observations(lines, expected, f"p{phase}_amount", "amount", amount)
            for label, operator in [("left", "<<"), ("right", ">>"), ("arithmetic", ">>>")]:
                lines += [f"    raw = a {operator} amount;",
                          f"    before_conversion = clean_a {operator} clean_amount;",
                          "    after_conversion = raw;"]
                value = shift(operator, a, amount, True)
                observations(lines, expected, f"p{phase}_{label}", "raw", value)
                observations(lines, expected, f"p{phase}_{label}_before", "before_conversion",
                             shift(operator, two_state(a), two_state(amount), True))
                observations(lines, expected, f"p{phase}_{label}_after", "after_conversion", two_state(value))
    note = ("Unknown and high-impedance bits sit at or beside 32/64/128/256-bit boundaries. "
            "Known inputs and controlling bits are retained as controls. Complete operands "
            "and results are displayed. Separate bit variables convert the operands before "
            "the operation; a different bit variable converts the four-state result after "
            "the operation. The existing standard-derived character truth tables produce "
            "expectations, without simulator output.")
    if form == "merge":
        note += (" A vector condition with a known one is true even when another bit is X/Z. "
                 "An ambiguous condition uses Table 11-20: Z/Z pairs merge to X. Branches "
                 "have equal widths and mixed signing, so the conditional result is unsigned.")
    if form == "shift":
        note += (" The shift amount is 65 bits and self-determined. A known bit at position "
                 "32 requests an over-width shift; any X/Z anywhere in the amount makes "
                 "the complete result unknown. Arithmetic right shift uses the signed "
                 "left operand, including X/Z sign fill; no negative amount is used.")
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form], clauses, note, "\n".join(body),
                "\n".join(expected) + "\n", fourstate=True)


def cases():
    return [make_case(width, form) for width in WIDTHS for form in FORMS]

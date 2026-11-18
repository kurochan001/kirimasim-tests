# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Exercise bit-vector queries across storage-word and expression boundaries.

Expectations are character histograms and Boolean predicates over explicit
bit strings, derived from 20.9; no simulator output enters the model.
"""
from common import Case

NAME = "bitvector_queries"
VERSION = 1
CHAPTER = 20
WIDTHS = (32, 33, 64, 65, 128, 129)
FORMS = ("known", "xz", "mutation", "predicates", "function", "record",
         "controls", "constant")


def pattern(width):
    positions = {0, width // 3, width // 2, width - 1, 31, 32, 63, 64, 127, 128}
    return "".join("1" if i in positions else "0" for i in reversed(range(width)))


def unknowns(bits):
    value = list(bits)
    # Unequal X/Z populations detect swapped state planes, not just truncation.
    for index in (len(bits) - 1, len(bits) - 2):
        value[len(bits) - 1 - index] = "x"
    for index in (len(bits) // 2, 0, 1):
        value[len(bits) - 1 - index] = "z"
    return "".join(value)


def replace_bit(bits, index, value):
    at = len(bits) - 1 - index
    return bits[:at] + value + bits[at + 1:]


def literal(bits):
    return f"{len(bits)}'b{bits}"


def assign_literal(lines, target, bits):
    # Binary digits keep every X/Z and partial word visible in the stimulus.
    # Split long literals into concatenated chunks without changing their size.
    if len(bits) <= 65:
        lines.append(f"    {target} = {literal(bits)};")
    else:
        chunks = [bits[i:i + 32] for i in range(0, len(bits), 32)]
        lines.append(f"    {target} = {{")
        lines.extend("      " + literal(chunk) + ("," if i + 1 < len(chunks) else "")
                     for i, chunk in enumerate(chunks))
        lines.append("    };")


def histogram(lines, expected, label, expression, bits, known_only=False):
    if known_only:
        lines += [f'    $display("{label} ones=%0d zeros=%0d",',
                  f"             $countones({expression}), $countbits({expression}, 1'b0));"]
        expected.append(f"{label} ones={bits.count('1')} zeros={bits.count('0')}")
        return
    lines += [f'    $display("{label} ones=%0d zeros=%0d x=%0d z=%0d",',
              f"             $countones({expression}), $countbits({expression}, 1'b0),",
              f"             $countbits({expression}, 1'bx), $countbits({expression}, 1'bz));"]
    expected.append(f"{label} ones={bits.count('1')} zeros={bits.count('0')} "
                    f"x={bits.count('x')} z={bits.count('z')}")


def predicates(lines, expected, label, expression, bits):
    ones = bits.count("1")
    lines += [f'    $display("{label} ones=%0d onehot=%0d onehot0=%0d unknown=%0d",',
              f"             $countones({expression}), $onehot({expression}),",
              f"             $onehot0({expression}), $isunknown({expression}));"]
    expected.append(f"{label} ones={ones} onehot={int(ones == 1)} "
                    f"onehot0={int(ones <= 1)} unknown={int('x' in bits or 'z' in bits)}")


def make_case(width, form):
    name = f"test_gen_bitquery_{form}_w{width}"
    known = pattern(width)
    declarations = [f"  localparam int W = {width};", "  logic [W-1:0] value;"]
    body, expected = [], [f"width={width} form={form}"]
    note = ""
    clauses = "20.9 20.6.2"
    expression = "value"
    if form == "known":
        declarations = [f"  localparam int W = {width};", "  bit [0:W-1] value;"]
        assign_literal(body, "value", known)
        histogram(body, expected, "ascending", "value", known, known_only=True)
        predicates(body, expected, "ascending", "value", known)
        body += ['    $display("duplicate=%0d union=%0d",',
                 "             $countbits(value, 1'b1, 1'b1),",
                 "             $countbits(value, 1'b0, 1'b1, 1'b0));"]
        expected.append(f"duplicate={known.count('1')} union={width}")
        note = "An ascending two-state packed range contains set bits in every storage word."
    elif form == "xz":
        bits = unknowns(known)
        assign_literal(body, "value", bits)
        histogram(body, expected, "fourstate", "value", bits)
        predicates(body, expected, "fourstate", "value", bits)
        body += ['    $display("duplicate=%0d union=%0d",',
                 "             $countbits(value, 1'bx, 1'bx),",
                 "             $countbits(value, 1'bx, 1'bz, 1'bx));"]
        expected.append(f"duplicate={bits.count('x')} union={bits.count('x') + bits.count('z')}")
        note = "Two high X bits and three Z bits give distinct populations across storage words."
    elif form == "mutation":
        bits = known
        assign_literal(body, "value", bits)
        histogram(body, expected, "initial", "value", bits)
        for label, index, state in [("top_x", width - 1, "x"),
                                    ("middle_z", width // 2, "z"),
                                    ("low_clear", 0, "0"), ("top_one", width - 1, "1")]:
            body.append(f"    value[{index}] = 1'b{state};")
            bits = replace_bit(bits, index, state)
            histogram(body, expected, label, "value", bits)
        note = "Successive high-word, middle-word and low-bit writes must change fresh query results."
    elif form == "predicates":
        declarations.append("  bit [W-1:0] clean;")
        bits = "0" * width
        body.append("    value = '0;")
        predicates(body, expected, "zero", "value", bits)
        for label, index, state in [("only_x", width - 1, "x"),
                                    ("only_one", width - 1, "1"),
                                    ("two_ones", 0, "1"), ("with_z", width // 2, "z")]:
            body.append(f"    value[{index}] = 1'b{state};")
            bits = replace_bit(bits, index, state)
            predicates(body, expected, label, "value", bits)
        body.append("    clean = value;")
        predicates(body, expected, "two_state", "clean", bits.replace("z", "0"))
        clauses += " 6.11.2"
        note = ("Onehot predicates count known ones even when X/Z exists elsewhere. "
                "Assigning to bit removes the unknown state before the final queries.")
    elif form == "function":
        declarations = [f"  localparam int W = {width};", "  typedef bit signed [W-1:0] word_t;",
                        "  word_t value;", "  word_t captured;",
                        "  function automatic word_t invert(input word_t a);",
                        "    return ~a;", "  endfunction",
                        "  function automatic word_t top(input bit enable);",
                        "    word_t temporary;", "    temporary = '0;",
                        "    temporary[W-1] = enable;", "    return temporary;", "  endfunction"]
        assign_literal(body, "value", known)
        inverted = "".join("0" if c == "1" else "1" for c in known)
        body.append("    captured = invert(value);")
        histogram(body, expected, "captured", "captured", inverted, known_only=True)
        histogram(body, expected, "inverted", "invert(value)", inverted, known_only=True)
        predicates(body, expected, "top_one", "top(1'b1)", "1" + "0" * (width - 1))
        predicates(body, expected, "top_zero", "top(1'b0)", "0" * width)
        expression = "invert(value)"
        clauses += " 13.4.1"
        note = "A signed packed function result keeps its full width as a self-determined query argument."
    elif form == "record":
        declarations = [f"  localparam int W = {width};", "  typedef struct packed {",
                        "    logic [1:0] head;", "    logic [W-1:0] payload;",
                        "    logic [1:0] tail;", "  } record_t;", "  record_t record_value;"]
        bits = unknowns(known)
        assign_literal(body, "record_value.payload", bits)
        body += ["    record_value.head = 2'bxz;", "    record_value.tail = 2'b01;"]
        histogram(body, expected, "record_xz", "record_value", "xz" + bits + "01")
        body += ["    record_value.head = 2'b10;", "    record_value.tail = 2'b11;"]
        histogram(body, expected, "record_known_tags", "record_value", "10" + bits + "11")
        body.append('    $display("record_bits=%0d", $bits(record_value));')
        expected.append(f"record_bits={width + 4}")
        expression = "record_value"
        clauses += " 7.2.1"
        note = "The query argument includes both packed tag fields as well as every payload word."
    elif form == "controls":
        declarations += ["  logic [W-1:0] control;", "  logic [W-1:0] duplicate;"]
        bits = unknowns(known)
        assign_literal(body, "value", bits)
        for state in ("0", "1", "x", "z"):
            body += ["    control = '1;", "    duplicate = '0;",
                     f"    control[0] = 1'b{state};", f"    duplicate[0] = 1'b{state};",
                     f'    $display("control_{state}=%0d repeated=%0d",',
                     "             $countbits(value, control),",
                     "             $countbits(value, control, duplicate));"]
            expected.append(f"control_{state}={bits.count(state)} repeated={bits.count(state)}")
        note = ("Wide variable controls have deliberately opposite high bits. Only their LSBs "
                "select a state; duplicate states are counted once after conversion.")
    elif form == "constant":
        chunks = [known[i:i + 32] for i in range(0, width, 32)]
        declarations = [f"  localparam int W = {width};", "  localparam bit [W-1:0] VALUE = {"]
        declarations += ["    " + literal(c) + ("," if i + 1 < len(chunks) else "")
                         for i, c in enumerate(chunks)]
        declarations += ["  };", "  localparam int ONES = $countones(VALUE);",
                         "  localparam int ZEROS = $countbits(VALUE, 1'b0);",
                         "  localparam bit SINGLE = $onehot(VALUE);",
                         "  localparam bit EMPTY_OK = $onehot0({W{1'b0}});",
                         "  typedef bit [ONES-1:0] counted_t;", "  counted_t counted;"]
        body += ["    counted = '0;", '    $display("ones=%0d zeros=%0d single=%0d empty_ok=%0d",',
                 "             ONES, ZEROS, SINGLE, EMPTY_OK);",
                 '    $display("counted_bits=%0d", $bits(counted));']
        expected += [f"ones={known.count('1')} zeros={known.count('0')} single=0 empty_ok=1",
                     f"counted_bits={known.count('1')}"]
        expression = "VALUE"
        note = "Constant bit queries determine a separate packed type width during elaboration."
    else:
        raise ValueError(form)
    body += ['    $display("return_bits=%0d,%0d,%0d,%0d,%0d",',
             f"             $bits($countbits({expression}, 1'b1)), $bits($countones({expression})),",
             f"             $bits($onehot({expression})), $bits($onehot0({expression})),",
             f"             $bits($isunknown({expression})));", "    $finish;"]
    expected.append("return_bits=32,32,1,1,1")
    lines = [f"module {name};", *declarations, "  initial begin",
             f'    $display("width={width} form={form}");', *body, "  end", "endmodule"]
    return Case(name, f"Wide bit-vector queries preserve {form} argument and result semantics",
                clauses, "IEEE 1800-2023 20.9 counts each requested bit state over the entire "
                "bit-stream argument, ignores duplicate control states and returns int counts "
                "or bit predicates. The reference counts explicit characters rather than using "
                "SV query functions. 20.6.2 observes the fixed return widths. " + note,
                "\n".join(lines), "\n".join(expected) + "\n",
                fourstate=form in ("xz", "mutation", "predicates", "record", "controls"))


def cases():
    return [make_case(width, form) for width in WIDTHS for form in FORMS]

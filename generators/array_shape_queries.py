# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Query declared array geometry and the current shape of variable containers.

The reference is the declared bound pairs in slowest-to-fastest order, with
cardinalities multiplied for $bits. Dynamic stages use explicit element counts.
No simulator contributes to the expected output.
"""
from math import prod

from common import Case

NAME = "array_shape_queries"
VERSION = 1
CHAPTER = 20
WIDTHS = (32, 33, 64, 65, 128, 129)
FORMS = ("packed", "mixed", "typedef", "singleton", "constant", "invalid",
         "dynamic", "queue", "dynamic_bits", "queue_bits")
DESCRIPTIONS = {
    "packed": "Array queries preserve offset and negative packed bounds",
    "mixed": "Array queries number unpacked dimensions before packed dimensions",
    "typedef": "Array queries expand nested typedef dimensions before numbering",
    "singleton": "Array queries give singleton ranges a positive increment",
    "constant": "Constant array queries determine a new packed type width",
    "invalid": "Out-of-range array dimensions return full-width unknown integers",
    "dynamic": "Array queries track dynamic allocation, resizing and deletion",
    "queue": "Array queries track queue insertion, removal and deletion",
    "dynamic_bits": "Runtime bits queries measure the current dynamic array contents",
    "queue_bits": "Runtime bits queries measure the current queue contents",
}


def geometry(bounds):
    left, right = bounds
    return (left, right, min(left, right), max(left, right),
            1 if left >= right else -1, abs(left - right) + 1)


def query_line(lines, expression, dimension, label):
    lines += [f'    $display("{label} left=%0d right=%0d low=%0d high=%0d inc=%0d size=%0d",',
              f"             $left({expression}, {dimension}), $right({expression}, {dimension}),",
              f"             $low({expression}, {dimension}), $high({expression}, {dimension}),",
              f"             $increment({expression}, {dimension}), $size({expression}, {dimension}));"]


def expected_line(label, bounds):
    left, right, low, high, increment, size = geometry(bounds)
    return f"{label} left={left} right={right} low={low} high={high} inc={increment} size={size}"


def fixed_shape(width, form):
    if form == "packed":
        return (["  typedef bit [4:2][-3:W-4] shape_t;"],
                [(4, 2), (-3, width - 4)], 0)
    if form == "mixed":
        return (["  typedef bit [1:0][W+2:3] shape_t [-2:0][5:4];"],
                [(-2, 0), (5, 4), (1, 0), (width + 2, 3)], 2)
    if form == "typedef":
        return (["  typedef bit [-3:W-4] lane_t;", "  typedef lane_t [2:1] pair_t;",
                 "  typedef pair_t row_t [4:2];", "  typedef row_t shape_t [-1:0];"],
                [(-1, 0), (4, 2), (2, 1), (-3, width - 4)], 2)
    if form == "singleton":
        return (["  typedef bit [7:7][W-1:0] shape_t [-2:-2][3:3];"],
                [(-2, -2), (3, 3), (7, 7), (width - 1, 0)], 2)
    return (["  typedef bit [1:3][W-1:0] shape_t [2:1];"],
            [(2, 1), (1, 3), (width - 1, 0)], 1)


def fixed_case(width, form):
    declarations, bounds, unpacked = fixed_shape(width, form)
    declarations += ["  shape_t value;", "  integer d;"]
    lines, expected = [], [f"width={width} form={form}"]
    bits = prod(geometry(pair)[-1] for pair in bounds)
    lines += ['    $display("value dims=%0d unpacked=%0d bits=%0d",',
              "             $dimensions(value), $unpacked_dimensions(value), $bits(value));"]
    expected.append(f"value dims={len(bounds)} unpacked={unpacked} bits={bits}")
    # Literal type queries and run-time dimension queries must describe the same shape.
    if form in ("typedef", "constant"):
        lines += ['    $display("type dims=%0d unpacked=%0d bits=%0d",',
                  "             $dimensions(shape_t), $unpacked_dimensions(shape_t), $bits(shape_t));"]
        expected.append(f"type dims={len(bounds)} unpacked={unpacked} bits={bits}")
        for d, pair in enumerate(bounds, 1):
            query_line(lines, "shape_t", str(d), f"type_d{d}")
            expected.append(expected_line(f"type_d{d}", pair))
    lines.append(f"    for (d = 1; d <= {len(bounds)}; d = d + 1) begin")
    query_line(lines, "value", "d", "variable_d%0d")
    # The loop dimension is a separate display argument, before query results.
    lines[-3] = "             d, " + lines[-3].lstrip()
    lines.append("    end")
    expected += [expected_line(f"variable_d{d}", pair) for d, pair in enumerate(bounds, 1)]
    query_line(lines, "value", "1", "default_control")
    lines += ['    $display("omitted left=%0d right=%0d low=%0d high=%0d inc=%0d size=%0d",',
              "             $left(value), $right(value), $low(value), $high(value),",
              "             $increment(value), $size(value));"]
    expected += [expected_line(label, bounds[0]) for label in ("default_control", "omitted")]
    if form == "constant":
        declarations += ["  localparam integer ELEMENTS = $size(shape_t, 1) * $size(shape_t, 2);",
                         "  localparam integer LANE = $size(shape_t, 3);",
                         "  typedef bit [ELEMENTS*LANE-1:0] flattened_t;", "  flattened_t flat;"]
        lines += ['    $display("constant elements=%0d lane=%0d flat=%0d",',
                  "             ELEMENTS, LANE, $bits(flat));"]
        expected.append(f"constant elements=6 lane={width} flat={6 * width}")
    if form == "invalid":
        declarations.append("  integer bad;")
        for bad in (0, -1, len(bounds) + 1):
            lines.append(f"    bad = {bad};")
            lines += [f'    $display("invalid_{bad} left=%h right=%h low=%h high=%h inc=%h size=%h",',
                      "             $left(value, bad), $right(value, bad),",
                      "             $low(value, bad), $high(value, bad),",
                      "             $increment(value, bad), $size(value, bad));"]
            expected.append(f"invalid_{bad} " + " ".join(
                key + "=xxxxxxxx" for key in ("left", "right", "low", "high", "inc", "size")))
    lines += ['    $display("return_bits=%0d,%0d,%0d,%0d",',
              "             $bits($left(value)), $bits($size(value)),",
              "             $bits($dimensions(value)), $bits($unpacked_dimensions(value)));"]
    expected.append("return_bits=32,32,32,32")
    note = ("Unpacked dimensions precede packed dimensions, including after typedef expansion. "
            "A dimension's declared bounds determine its direction and cardinality; equal "
            "bounds have increment +1. Literal and runtime dimension arguments, and "
            "omitted versus explicit dimension 1 are observed. "
            "The return type is integer, not the operand's element width.")
    if form in ("typedef", "constant"):
        note += " Type-identifier queries are compared with variable queries."
    if form == "invalid":
        note += " Invalid dimensions 0, -1 and rank+1 return 32 X bits, with valid controls retained."
    if form == "constant":
        note += " Fixed-size type queries are constant expressions used to declare another type."
    return declarations, lines, expected, note


def variable_case(width, form):
    bits_only = form.endswith("_bits")
    container = form.removesuffix("_bits")
    declarations = ["  typedef bit [-3:W-4] word_t;",
                    "  word_t value[];" if container == "dynamic" else "  word_t value[$];",
                    "  word_t removed;"]
    lines, expected = [], [f"width={width} form={form}"]
    stages = [("empty", [], 0)]
    if container == "dynamic":
        stages += [("three", ["    value = new[3];", "    value[0] = '1;"], 3),
                   ("five", ["    value = new[5](value);"], 5),
                   ("one", ["    value = new[1](value);"], 1),
                   ("deleted", ["    value.delete();"], 0)]
    else:
        stages += [("one", ["    value.push_front('1);"], 1),
                   ("two", ["    value.push_front('0);"], 2),
                   ("popped", ["    removed = value.pop_front();"], 1),
                   ("deleted", ["    value.delete();"], 0)]
    for label, writes, size in stages:
        lines += writes
        if bits_only:
            lines += [f'    $display("{label} bits=%0d method=%0d", $bits(value), value.size());']
            expected.append(f"{label} bits={size * width} method={size}")
        else:
            lines += [f'    $display("{label} dims=%0d unpacked=%0d element_bits=%0d method=%0d",',
                      "             $dimensions(value), $unpacked_dimensions(value),",
                      "             $bits(word_t), value.size());"]
            expected.append(f"{label} dims=2 unpacked=1 element_bits={width} method={size}")
            query_line(lines, "value", "1", label + "_outer")
            # Dynamic direction is always ascending, including the empty [0:-1] state.
            expected.append(f"{label}_outer left=0 right={size - 1} low=0 "
                            f"high={size - 1} inc=-1 size={size}")
            query_line(lines, "value", "2", label + "_packed")
            expected.append(expected_line(label + "_packed", (-3, width - 4)))
        if size:
            # Read a fully initialized, live element as an independent data control.
            lines.append(f'    $display("{label}_first=%b", value[0]);')
            bit = "0" if container == "queue" and label == "two" else "1"
            expected.append(f"{label}_first={bit * width}")
    note = ("Runtime container cardinality changes but its packed element bounds do not. "
            "Empty dynamic/queue dimensions have left/low 0, right/high -1, increment -1 "
            "and size 0. Live-element controls check preserved data. "
            "No dynamically sized type identifier is passed to a query.")
    if bits_only:
        note = ("Bits equals the current element count times the packed element width, "
                "with no storage overhead; an empty dynamic container needs zero bits. "
                "This runtime size observation is isolated from array-geometry functions. "
                "Live-element controls check preserved data. Only $bits of the live "
                "variable is used, never of a dynamically sized type identifier.")
    return declarations, lines, expected, note


def make_case(width, form):
    name = f"test_gen_array_shape_{form}_w{width}"
    build = variable_case if form.startswith(("dynamic", "queue")) else fixed_case
    declarations, lines, expected, note = build(width, form)
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("width={width} form={form}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    clauses = "20.7 20.6.2 7.4.1 7.4.2 7.4.4 6.18"
    if form.endswith("_bits"):
        clauses = "20.6.2 6.24.3 20.7 7.4.1 7.4.2 7.4.4 6.18"
    if form.startswith("dynamic"):
        clauses += " 7.5 7.5.1 7.5.2 7.5.3"
    elif form.startswith("queue"):
        clauses += " 7.10 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.6"
    return Case(name, DESCRIPTIONS[form], clauses, note, "\n".join(body),
                "\n".join(expected) + "\n", fourstate=form == "invalid")


def cases():
    return [make_case(width, form) for width in WIDTHS for form in FORMS]

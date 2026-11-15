"""Selections of implicit function-result variables retain declared ranges.

13.4.1 requires the implicit result variable to have the function's return
type. The model indexes the declared bit labels, not a zero-based temporary.
It includes signed/unsigned returns and package calls/class-handle chains.
"""

from common import Case

NAME = "function_result_ranges"
VERSION = 1
CHAPTER = 13
RANGES = {"positive_down": (12, 5), "positive_up": (5, 12),
          "negative_down": (-2, -9), "negative_up": (-9, -2),
          "singleton": (7, 7), "wide_offset": (100, 36)}


def samples(width):
    mask = (1 << width)-1
    return (0, mask, 1 << (width-1), sum(1 << i for i in range(0, width, 2)))


def number(value, width, signed):
    return value-(1 << width) if signed and value & (1 << (width-1)) else value


def case(range_name, signed, form):
    left, right = RANGES[range_name]
    width = abs(left-right)+1
    label = "signed" if signed else "unsigned"
    name = f"test_gen_result_range_{range_name}_{label}_{form}"
    package = "result_types"
    lines = [f"package {package};",
             f"  typedef bit {label} [{left}:{right}] word_t;",
             "  function automatic word_t make(input word_t data);",
             "    return data;", "  endfunction", "endpackage", f"module {name};",
             "  import result_types::word_t;"]
    if form == "chain":
        lines += ["  class cell_t;", "    word_t data;",
                  "    function word_t get(); return data; endfunction", "  endclass",
                  "  cell_t live;",
                  "  function automatic cell_t first();",
                  "    return live;", "  endfunction"]
        expr = "first().get()"
    else:
        expr = "result_types::make(data)"
    lines += ["  word_t data;", "  bit first_bit, last_bit;", "  bit [2:0] indexed;",
              "  word_t whole;", "  int left_bound, right_bound, size;", "  initial begin"]
    if form == "chain":
        lines += ["    live = new();"]
    expected = []
    for phase, value in enumerate(samples(width)):
        bits = f"{value:0{width}b}"
        lines += [f"    data = {width}'b{bits};"]
        if form == "chain":
            lines += ["    live.data = data;"]
        lines += [f"    whole = {expr};", f"    first_bit = {expr}[{left}];",
                  f"    last_bit = {expr}[{right}];",
                  f"    left_bound = $left({expr});", f"    right_bound = $right({expr});",
                  f"    size = $bits({expr});"]
        # A fixed-width indexed slice begins at the declared right endpoint
        # and moves toward the left endpoint; pad singleton slices separately.
        if width >= 3:
            direction = "+:" if left > right else "-:"
            lines += [f"    indexed = {expr}[{right} {direction} 3];"]
            selected = value & 7
        else:
            lines += [f"    indexed = {{2'b00, {expr}[{right}]}};"]
            selected = value
        lines += [f'    $display("p{phase} range=%0d:%0d size=%0d ends=%b%b whole=%b value=%0d part=%b",',
                  "             left_bound, right_bound, size, first_bit, last_bit, whole,",
                  f"             {expr}, indexed);"]
        expected.append(f"p{phase} range={left}:{right} size={width} "
                        f"ends={bits[0]}{bits[-1]} whole={bits} "
                        f"value={number(value,width,signed)} part={selected:03b}")
    lines += ["  end", "endmodule"]
    return Case(name=name,
                description=f"`{label}` function-call results preserve the `{left}:{right}` range through `{form}` selections",
                lrm="13.4.1 7.4.1 11.5.1 20.6.2 20.7",
                comment="IEEE 1800-2023 13.4.1 gives an implicit function-call "
                        "result the declared return type, including its index "
                        "labels and signing. Selections operate directly on "
                        "the call result, before any assignment to a temporary. "
                        "The declared endpoint bits and a three-bit indexed "
                        "slice are observed for zero, all ones, the top bit "
                        "and alternating bits. Array queries report the result "
                        "range and size. Every called function is side-effect "
                        "free, so query evaluation is immaterial. "
                        "Whole-result printing and direct-call decimal values "
                        "separately check width/sign preservation. Class "
                        "chains use an explicitly allocated nonnull object.",
                body=("// Icarus Verilog 13.0 does not parse direct call-result selections.\n"
                      + "\n".join(lines)+"\n"),
                expected="\n".join(expected)+"\n")


def cases():
    assert {abs(l-r)+1 for l,r in RANGES.values()} == {1, 8, 65}
    return [case(r,s,f) for r in RANGES for s in (False,True) for f in ("package","chain")]

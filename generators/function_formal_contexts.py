"""Function formal dataflow and strictly constant literal/parameter calls.

Runtime wrappers use automatic local actuals. Constant controls pass only
literal or parameter actuals; no nested constant call consumes a local.
"""
from common import Case

NAME = "function_formal_contexts"
VERSION = 1
CHAPTER = 13
WIDTHS = (1, 8, 32, 33, 65)
DIRECTIONS = ("output", "inout", "ref")

def mask(width):
    return (1 << width)-1


def alternating(width):
    return sum(1 << i for i in range(0, width, 2))


def literal(width, value):
    return f"{width}'b{value:0{width}b}"


def decimal(value, width, signed):
    return value-(1 << width) if signed and value & (1 << (width-1)) else value


def edited(direction, width, seed):
    return alternating(width) if direction == "output" else seed ^ alternating(width)


def definitions(name, direction, width, signed, control=False):
    sign = "signed" if signed else "unsigned"
    lines = [f"module {name};", f"  typedef bit {sign} [{width-1}:0] word_t;",
             "  typedef struct packed {",
             "    word_t before_value, after_value, answer;", "  } result_t;"]
    functions = (("leaf", "wrapped", direction),)
    if control:
        functions += (("input_leaf", "input_wrapped", "input"),)
    for leaf, wrapper, formal in functions:
        assignment = (f"    arg = {literal(width, alternating(width))};" if direction == "output"
                      else f"    arg = arg ^ {literal(width, alternating(width))};")
        lines += [f"  function automatic word_t {leaf}({formal} word_t arg);",
                  assignment, "    return ~arg;", "  endfunction",
                  f"  function automatic result_t {wrapper}(input word_t seed);",
                  "    word_t temporary;", "    result_t result;",
                  "    temporary = seed;", "    result.before_value = temporary;",
                  f"    result.answer = {leaf}(temporary);",
                  "    result.after_value = temporary;", "    return result;", "  endfunction"]
    return lines


def runtime(direction, width, signed):
    label = "signed" if signed else "unsigned"
    name = f"test_gen_formal_runtime_{direction}_w{width}_{label}"
    lines = definitions(name, direction, width, signed, control=True)
    lines += ["  localparam word_t C_ZERO = input_leaf(",f"      {literal(width,0)});",
              "  localparam word_t C_ONES = input_leaf(",f"      {literal(width,mask(width))});",
              "  result_t observed, input_observed;", "  initial begin"]
    expected = []
    for i, seed in enumerate((0,mask(width),1 << (width-1),alternating(width))):
        after = edited(direction,width,seed)
        answer = mask(width) ^ after
        lines += ["    observed = wrapped(",f"        {literal(width,seed)});",
                  "    input_observed = input_wrapped(",f"        {literal(width,seed)});",
                  f'    $display("p{i} runtime before=%b after=%b answer=%b",',
                  "             observed.before_value, observed.after_value, observed.answer);",
                  f'    $display("p{i} input before=%b after=%b answer=%b",',
                  "             input_observed.before_value, input_observed.after_value,",
                  "             input_observed.answer);",
                  f'    $display("p{i} decimal after=%0d answer=%0d",',
                  "             observed.after_value, observed.answer);"]
        expected += [f"p{i} runtime before={seed:0{width}b} after={after:0{width}b} answer={answer:0{width}b}",
                     f"p{i} input before={seed:0{width}b} after={seed:0{width}b} answer={answer:0{width}b}",
                     f"p{i} decimal after={decimal(after,width,signed)} "
                     f"answer={decimal(answer,width,signed)}"]
    lines += ['    $display("constant zero=%b ones=%b", C_ZERO, C_ONES);',"  end","endmodule"]
    zero_answer = mask(width) ^ edited(direction,width,0)
    ones_answer = mask(width) ^ edited(direction,width,mask(width))
    expected.append(f"constant zero={zero_answer:0{width}b} ones={ones_answer:0{width}b}")
    clauses = "13.5.2 13.5.1 13.4.1 13.4.3" if direction=="ref" else "13.5.1 13.4.1 13.4.3"
    return Case(name=name,
                description=f"runtime `{direction}` calls update `{width}`-bit `{label}` actuals while input calls retain them",
                lrm=clauses,
                comment="IEEE 1800-2023 ordinary functions may have noninput "
                        "formals. Output/inout copy back on return; ref aliases "
                        "an exactly typed automatic actual (13.5.1 and 13.5.2). "
                        "A wrapper records the caller local before and after "
                        "the call, plus the separate return value. The same "
                        "leaf body with an input formal must leave its caller "
                        "local unchanged. Both wrappers are used only at "
                        "runtime. Four seeds exercise all bits, sign and "
                        "width boundaries. The two legal constant controls "
                        "call the input leaf directly with literal actuals; "
                        "no constant call passes a local variable. Icarus "
                        "Verilog 13.0 does not implement these ordinary "
                        "noninput function formals and is not an oracle.",
                body="\n".join(lines)+"\n",expected="\n".join(expected)+"\n",
                unregistered=("icarus",))


def shift(value, width, signed):
    result = value >> 1
    if signed and value & (1 << (width-1)):
        result |= 1 << (width-1)
    return result


def constant(scope, width, signed):
    label = "signed" if signed else "unsigned"
    name = f"test_gen_formal_constant_{scope}_w{width}_{label}"
    declarations = [f"  typedef bit {label} [{width-1}:0] word_t;",
                    "  localparam word_t FIXED_ARG =",f"      {literal(width,0)};"]
    prefix = "static function" if scope=="class" else "function automatic"
    functions = [f"  {prefix} word_t leaf(input word_t arg);",
                 f"    arg = arg ^ {literal(width,alternating(width))};",
                 "    return arg >>> 1;", "  endfunction",
                 f"  {prefix} word_t calculate(input word_t seed);",
                 "    word_t local_value;", "    local_value = leaf(FIXED_ARG);",
                 "    return local_value ^ seed;", "  endfunction"]
    if scope=="package":
        lines=["package constant_helpers;",*declarations,*functions,"endpackage",
               f"module {name};","  import constant_helpers::word_t;"]
        owner="constant_helpers::"
    elif scope=="class":
        lines=[f"module {name};",*declarations,"  class helper;",
               *["  "+l for l in functions],"  endclass"]
        owner="helper::"
    else:
        lines=[f"module {name};",*declarations,*functions]
        owner=""
    lines += [f"  localparam word_t LEAF_ZERO = {owner}leaf(",f"      {literal(width,0)});",
              f"  localparam word_t LEAF_ONES = {owner}leaf(",f"      {literal(width,mask(width))});"]
    seeds=(0,mask(width),1 << (width-1),alternating(width))
    for i,seed in enumerate(seeds):
        lines += [f"  localparam word_t P{i} = {owner}calculate(",f"      {literal(width,seed)});"]
    lines += ["  word_t runtime_value;","  initial begin"]
    zero = shift(alternating(width),width,signed)
    ones = shift(mask(width)^alternating(width),width,signed)
    expected=[]
    for i,seed in enumerate(seeds):
        value=zero ^ seed
        lines += [f"    runtime_value = {owner}calculate(",f"        {literal(width,seed)});",
                  f'    $display("p{i} folded=%b runtime=%b decimal=%0d", P{i}, runtime_value, P{i});']
        expected.append(f"p{i} folded={value:0{width}b} runtime={value:0{width}b} "
                        f"decimal={decimal(value,width,signed)}")
    lines += ['    $display("leaf zero=%b ones=%b", LEAF_ZERO, LEAF_ONES);',
              '    $display("leaf decimal zero=%0d ones=%0d", LEAF_ZERO, LEAF_ONES);',
              "  end","endmodule"]
    expected += [f"leaf zero={zero:0{width}b} ones={ones:0{width}b}",
                 f"leaf decimal zero={decimal(zero,width,signed)} ones={decimal(ones,width,signed)}"]
    clauses="13.4.3 13.5.1 11.4.10"+(" 8.10" if scope=="class" else "")
    return Case(name=name,
                description=f"`{scope}` constant functions use only constant actuals with `{width}`-bit `{label}` inputs",
                lrm=clauses,
                comment="IEEE 1800-2023 13.4.3 permits constant calls to local, "
                        "package and static class functions when all actuals "
                        "are constant expressions. Every nested leaf call "
                        "here passes the already-declared FIXED_ARG parameter. "
                        "Every outer parameter call passes a literal. No "
                        "nested constant call receives a function local. "
                        "The leaf modifies its input copy and applies an "
                        "arithmetic right shift according to its declared "
                        "sign and width (11.4.10). The outer call XORs the "
                        "result with its local input seed. Four folded values "
                        "are compared with independently calculated expected "
                        "bits and runtime calls; direct zero/ones leaf calls "
                        "exercise both sign-bit cases.",
                body=("// Icarus Verilog 13.0 does not elaborate these class-static calls.\n"
                      if scope=="class" else "")+"\n".join(lines)+"\n",
                expected="\n".join(expected)+"\n")


def cases():
    assert all(0 < alternating(w) <= mask(w) for w in WIDTHS)
    return [runtime(d,w,s) for d in DIRECTIONS for w in WIDTHS for s in (False,True)] + [
        constant(c,w,s) for c in ("module","package","class")
        for w in WIDTHS for s in (False,True)]



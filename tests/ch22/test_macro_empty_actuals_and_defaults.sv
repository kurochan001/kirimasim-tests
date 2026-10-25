/*
:name: test_macro_empty_actuals_and_defaults
:description: An empty or white-space-only actual argument of a macro is replaced by the default of its formal argument, or by nothing when there is none; a = followed at once by a comma or the closing parenthesis gives an empty default; and an empty macro passed as actual replaces a nonempty default by nothing (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_empty_actuals_and_defaults.expected
*/
// IEEE 1800-2023 §22.5.1: an actual argument may be empty or white space
// only; then the formal argument is replaced by its default, or by nothing if
// it has no default. An = right before a comma, or before the closing
// parenthesis of the last formal, makes the default empty. To replace a
// formal that has a nonempty default by nothing, an empty macro such as
// `EMPTY is given as actual: it replaces the default and then expands to no
// text. Each macro below declares an int whose value shows what replaced the
// formal: WITH_DEF has the default 7 and adds 1, NO_DEF has no default and
// starts from 5, and EMPTY_DEFS has two empty defaults and starts from 1.

`define EMPTY
`define WITH_DEF(n, v = 7) int n = v + 1;
`define NO_DEF(n, v) int n = 5 v;
`define EMPTY_DEFS(n, v=, w=) int n = 1 v w;

module test_macro_empty_actuals_and_defaults;
  `WITH_DEF(a, )
  `WITH_DEF(b,     )
  `WITH_DEF(c, 2)
  `WITH_DEF(d, `EMPTY)
  `NO_DEF(e, )
  `NO_DEF(f,   )
  `NO_DEF(g, + 4)
  `EMPTY_DEFS(h)
  `EMPTY_DEFS(i, + 2)
  `EMPTY_DEFS(j, , * 5)

  initial begin
    $display("default for empty: a=%0d b=%0d, actual: c=%0d, `EMPTY: d=%0d", a, b, c, d);
    $display("no default: e=%0d f=%0d, actual: g=%0d", e, f, g);
    $display("empty defaults: h=%0d i=%0d j=%0d", h, i, j);
  end
endmodule

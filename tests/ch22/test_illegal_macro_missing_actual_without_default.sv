/*
:name: test_illegal_macro_missing_actual_without_default
:description: When a macro use gives fewer actual arguments than the macro has formal arguments, every remaining formal argument needs a default, so a use that leaves out an argument without a default is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the use of SUM3 gives only the first argument, and of the remaining formal arguments b and c, c has no default
:expected_stderr_regex: test_illegal_macro_missing_actual_without_default\.sv:25:
*/
// IEEE 1800-2023 §22.5.1: if a macro use gives fewer actual arguments than
// there are formal arguments, the defaults are used for the rest when all
// of them have defaults, and it is an error when any of them has none.
// SUM3 has the formal arguments a, b = 2 and c. The use with three
// arguments is legal; the use with one argument leaves out b, which has a
// default, and c, which has none.

`define SUM3(a, b = 2, c) ((a) + (b) + (c))

module test_illegal_macro_missing_actual_without_default;
  localparam int ALL = `SUM3(1, 2, 3);
  localparam int SHORT = `SUM3(1);  // illegal: c has no default
endmodule

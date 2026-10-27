/*
:name: test_22_extra_macro_name
:description: A macro name shall not redefine a compiler directive keyword, so `define define is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: define is a compiler directive keyword and the `define directive tries to make it a macro name
:expected_stderr_regex: test_22_extra_macro_name\.sv:(?:22|23):
*/
// IEEE 1800-2023 §22.5.1: the macro name may be a simple or an escaped
// identifier, but it shall be illegal to redefine a compiler directive as a
// macro name. The word define is a compiler directive keyword and not part of
// the normal set of keywords (22.5.1), so an ordinary identifier may be called
// define while a macro may not. The definition below is the error. Icarus
// Verilog 13.0 reports it at the directive line and Verilator 5.052 at the
// line that follows the directive text, so both lines are named here.

`define define 1
module test_22_extra_macro_name;
  initial $display("unreachable");
endmodule

/*
:name: test_22_extra_macro_formal_spacing
:description: White space between a simple macro name and its formal-argument parenthesis means that the macro has no formal arguments, so a use with an argument list afterwards is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the space before the parenthesis keeps the formal argument out of the macro name, so the use gives an actual argument to a macro that has none
:expected_stderr_regex: test_22_extra_macro_formal_spacing\.sv:24:
*/
// IEEE 1800-2023 §22.5.1: if formal arguments are used, their list shall be
// enclosed in parentheses immediately following the name of the macro; for a
// simple identifier no white space shall separate the opening parenthesis from
// the macro name. In the definition below the space means that SHOW has no
// formal argument and that its macro text starts with "(x) $display(x);".
// The use therefore substitutes that text and appends the actual argument
// list, which is not a statement, and the design is rejected there.

`define SHOW (x) $display(x);
module test_22_extra_macro_formal_spacing;
  initial `SHOW(7);
endmodule

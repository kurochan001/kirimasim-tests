/*
:name: test_illegal_macro_with_arguments_used_without_parentheses
:description: The use of a macro defined with arguments needs parentheses even when every formal argument has a default (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: INC is defined with a formal argument and is used without the parentheses of a list of actual arguments
:expected_stderr_regex: test_illegal_macro_with_arguments_used_without_parentheses\.sv:24:
*/
// IEEE 1800-2023 §22.5.1: for a macro with arguments the parentheses are
// always required in the macro call, even if all the arguments have
// defaults. INC has one formal argument with the default 1; the use with
// empty parentheses takes the default and is legal, the use without
// parentheses is the error.

`define INC(x = 1) ((x) + 1)

module test_illegal_macro_with_arguments_used_without_parentheses;
  localparam int OK = `INC();
  localparam int BAD = `INC;  // illegal: no parentheses
endmodule

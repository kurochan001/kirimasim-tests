/*
:name: test_illegal_checker_output_expression
:description: The actual argument of a checker output cannot be an expression (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual of the output formal y is the expression a & b
:expected_stderr_regex: test_illegal_checker_output_expression\.sv:30:
*/
// IEEE 1800-2023 17.3: each actual output argument of a checker instance shall
// be a variable_lvalue or a net_lvalue, because the instance is treated as if
// there were continuous assignments from the output formals to their actuals.
// The instance below passes the expression a & b for the output y, which is not
// an lvalue. The rest of the design is legal.

`timescale 1ns/1ns

checker out_lvalue(input logic a, output logic y);
  assign y = ~a;
endchecker : out_lvalue

module test_illegal_checker_output_expression;
  logic a = 1'b1, b = 1'b0;
  logic y;

  out_lvalue u(.a(a), .y(a & b));   // illegal: an expression is not an lvalue

  initial #1 $display("y=%b", y);
endmodule

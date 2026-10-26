/*
:name: test_a8_3_a8_4_mintypmax_expressions
:description: A mintypmax expression with three colon-separated expressions is a primary and a constant primary, and the value it gives is the value of the localparam and of the variable that it initializes (IEEE 1800-2023 Sections 11.2.1 and A.8.3, A.8.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 A.8.3 A.8.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a8_3_a8_4_mintypmax_expressions.expected
*/
// IEEE 1800-2023 A.8.3: a mintypmax expression is one expression or three
// colon-separated expressions. A.8.4: a primary may be a parenthesized
// mintypmax expression, and a constant primary may be a parenthesized
// constant mintypmax expression. §11.2.1 gives the value: a tool selects the
// minimum, the typical or the maximum value of the three.
//
// The localparam PAREN_ADD is (2:2:2) + 1, which uses the parenthesized
// constant mintypmax expression as a constant primary, and the variable x is
// initialized with (3:3:3), which uses the parenthesized mintypmax expression
// as a primary. The three values of each triplet are the same, so the value
// does not depend on which one the tool selects: the print is mintypmax 3 3.

`timescale 1ns/1ns
module test_a8_3_a8_4_mintypmax_expressions;
  localparam int PAREN_ADD = (2:2:2) + 1;
  int x = (3:3:3);

  initial $display("mintypmax %0d %0d", PAREN_ADD, x);
endmodule

/*
:name: test_illegal_clocking_skew_nonconstant_expression
:description: the delay control of a clocking skew has to be a time literal or a constant expression with a nonnegative integer value, so an expression that reads a variable is illegal while one of parameters is legal (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output skew of the clockvar a is the expression (d + 1), which reads the variable d and so is not a constant expression
:expected_stderr_regex: test_illegal_clocking_skew_nonconstant_expression\.sv:33:
*/
// IEEE 1800-2023 §14.3: the delay control of a clocking skew shall be either a
// time literal or a constant expression that evaluates to a nonnegative
// integer value. The output skew of b is (P + 1), an expression of a
// parameter, and that of c the time literal 2ns: both are legal. The output
// skew of a is (d + 1), which reads the variable d: its value would be the
// nonnegative integer 3, but it is not a constant expression.
// test_illegal_clocking_skew_negative covers a constant whose value is
// negative, and test_illegal_clocking_skew_real_constant one whose value is
// not an integer. Icarus Verilog 13.0 does not support clocking blocks; the
// syntax errors it reports on every line of the block do not count.

`timescale 1ns/1ns
module test_illegal_clocking_skew_nonconstant_expression;
  logic clk = 0, a = 0, b = 0, c = 0;
  localparam int P = 2;
  int d = 2;
  clocking cb @(posedge clk);
    output #(P + 1) b;
    output #2ns c;
    output #(d + 1) a;   // illegal
  endclocking
endmodule

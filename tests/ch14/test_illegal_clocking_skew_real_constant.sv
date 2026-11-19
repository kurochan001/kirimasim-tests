/*
:name: test_illegal_clocking_skew_real_constant
:description: the delay control of a clocking skew has to be a time literal or a constant expression with a nonnegative integer value, so the real number 1.5 without a time unit is illegal while the time literal 1.5ns is legal (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input skew of the clockvar a is the real number 1.5, a constant whose value is not an integer and which is not a time literal
:expected_stderr_regex: test_illegal_clocking_skew_real_constant\.sv:34:
*/
// IEEE 1800-2023 §14.3: the delay control of a clocking skew shall be either a
// time literal or a constant expression that evaluates to a nonnegative
// integer value. The skews of b (the integer 2), c (the integer 0, the
// smallest legal value) and e (the time literal 1.5ns, a number with a time
// unit) are legal. The skew of a is the real number 1.5 without a time unit:
// it is a constant expression, but its value is not an integer, and it is
// not a time literal. test_illegal_clocking_skew_negative covers a constant
// whose value is negative, and
// test_illegal_clocking_skew_nonconstant_expression one that is not constant.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports on every line of the block do not count. Verilator 5.054 accepts
// the design.

`timescale 1ns/1ps
module test_illegal_clocking_skew_real_constant;
  logic clk = 0, a = 0, b = 0, c = 0, e = 0;
  clocking cb @(posedge clk);
    input #2 b;
    input #0 c;
    input #1.5ns e;
    input #1.5 a;   // illegal
  endclocking
endmodule

/*
:name: test_illegal_clocking_skew_negative
:description: the delay control of a clocking skew has to be a time literal or a constant expression with a nonnegative integer value, so a constant expression whose value is -1 is illegal (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3 14.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input skew of the clockvar a is the constant expression (P - 3), whose value is -1
:expected_stderr_regex: test_illegal_clocking_skew_negative\.sv:33:
*/
// IEEE 1800-2023 §14.3: the delay control of a clocking skew shall be either a
// time literal or a constant expression whose value is a nonnegative integer.
// §14.4: a skew is constant and may be given by a parameter. With P = 2, the
// skew of b is the parameter itself, the skew of c is the constant expression
// (P - 2), whose value 0 is the smallest legal one, and the output skew of e
// is the time literal 1ns; these three are legal. The skew of a is the
// constant expression (P - 3), which is constant but evaluates to -1.
// test_illegal_clocking_skew_variable covers a skew that is not constant.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_clocking_skew_negative;
  logic clk = 0, a = 0, b = 0, c = 0, e = 0;
  localparam int P = 2;
  clocking cb @(posedge clk);
    input #P b;
    input #(P - 2) c;
    output #1ns e;
    input #(P - 3) a;   // illegal
  endclocking
endmodule

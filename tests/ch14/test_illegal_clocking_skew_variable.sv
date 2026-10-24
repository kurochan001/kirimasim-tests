/*
:name: test_illegal_clocking_skew_variable
:description: a clocking skew has to be a constant expression, which may be a parameter (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input skew of the clockvar a is the variable d, which is not a constant expression
:expected_stderr_regex: test_illegal_clocking_skew_variable\.sv:31:
*/
// IEEE 1800-2023 §14.4: a skew shall be a constant expression and can be
// given as a parameter; without a time unit it is in the time unit of the
// current scope. The skews of b, c and e are the parameter P, the constant
// expression (P + 1) and the time literal 1ns, which are legal; the skew of
// a is the module variable d.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_clocking_skew_variable;
  logic clk = 0, a = 0, b = 0, c = 0, e = 0;
  int d = 2;
  localparam int P = 2;
  clocking cb @(posedge clk);
    input #P b;
    input #(P + 1) c;
    input #1ns e;
    input #d a;   // illegal
  endclocking
endmodule

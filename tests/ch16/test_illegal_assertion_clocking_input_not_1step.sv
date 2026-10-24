/*
:name: test_illegal_assertion_clocking_input_not_1step
:description: a clocking block input used in an assertion has to be sampled with #1step (IEEE 1800-2023 Section 16.5.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a_bad uses the clockvar cb.a, whose input skew is #2
:expected_stderr_regex: test_illegal_assertion_clocking_input_not_1step\.sv:29:
*/
// IEEE 1800-2023 §16.5.1: if a variable of an assertion is an input of a
// clocking block, the clocking block shall sample it with #1step; any other
// sampling is an error, and the assertion uses the value sampled by the
// clocking block. The input b of cb has the skew #1step, so a_ok, which
// uses cb.b, is legal; the input a has the skew #2, and a_bad uses cb.a.
// Icarus Verilog 13.0 does not support clocking blocks, and Verilator 5.052
// accepts the design.

module test_illegal_assertion_clocking_input_not_1step;
  logic clk = 0, a = 0, b = 0;
  clocking cb @(posedge clk);
    input #1step b;
    input #2 a;
  endclocking
  a_ok: assert property (@(posedge clk) cb.b);
  a_bad: assert property (@(posedge clk) cb.a);   // illegal
endmodule

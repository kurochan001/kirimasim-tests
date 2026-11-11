/*
:name: test_illegal_triggered_ending_clock_differs
:description: the ending clock of a sequence instance to which triggered is applied has to be the clock of the context of the call (IEEE 1800-2023 Section 16.9.11)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a_bad applies triggered to s1, which ends on posedge clk1, in a context clocked by posedge clk2
:expected_stderr_regex: test_illegal_triggered_ending_clock_differs\.sv:30:
*/
// IEEE 1800-2023 §16.9.11: triggered may be used with multiple clocks, but the
// ending clock of the sequence instance to which it is applied shall be the
// same as the clock of the context where triggered appears. s1 ends on
// posedge clk1. a_same applies s1.triggered where the clock is posedge clk1,
// and a_multi does so after switching from posedge clk2 to posedge clk1;
// both are legal. a_bad applies it where the clock is posedge clk2.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support a clock inside a property; neither error counts.

module test_illegal_triggered_ending_clock_differs;
  logic clk1 = 0, clk2 = 0, a = 0, b = 0, c = 0;
  sequence s1;
    @(posedge clk1) a ##1 b;
  endsequence
  a_same: assert property (@(posedge clk1) c |-> s1.triggered);
  a_multi: assert property (@(posedge clk2) c ##1 @(posedge clk1) s1.triggered);
  a_bad: assert property (@(posedge clk2) c |-> s1.triggered);   // illegal
endmodule

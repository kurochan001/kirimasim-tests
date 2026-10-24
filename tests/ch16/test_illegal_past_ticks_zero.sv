/*
:name: test_illegal_past_ticks_zero
:description: the number of ticks of $past has to be 1 or greater (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the number of ticks of $past in p_bad is 0
:expected_stderr_regex: test_illegal_past_ticks_zero\.sv:28:
*/
// IEEE 1800-2023 §16.9.3: the number_of_ticks of $past shall be 1 or
// greater and an elaboration-time constant expression, and it is 1 when
// it is left out. p_one leaves it out, p_two gives 2 and p_par the
// parameter K, which is legal.
// p_bad gives the number of ticks 0.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_past_ticks_zero;
  logic clk = 0, a = 0, b = 0;
  localparam int K = 3;
  p_one: assert property (@(posedge clk) a |-> $past(b));
  p_two: assert property (@(posedge clk) a |-> $past(b, 2));
  p_par: assert property (@(posedge clk) a |-> $past(b, K));
  p_bad: assert property (@(posedge clk) a |-> $past(b, 0));   // illegal
endmodule

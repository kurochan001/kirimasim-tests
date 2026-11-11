/*
:name: test_illegal_sequence_event_formal_actual_not_event
:description: the actual of an event sequence formal has to be an event expression (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_ev in c_bad passes the sequence expression a ##1 b to the event formal ev
:expected_stderr_regex: test_illegal_sequence_event_formal_actual_not_event\.sv:28:
*/
// IEEE 1800-2023 §16.8.1: the actual of a formal of type event shall be an
// event expression. c_ok passes posedge clk and c_neg negedge clk; c_bad
// passes the sequence expression a ##1 b, which is not an event
// expression.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support event actuals; neither error counts.

module test_illegal_sequence_event_formal_actual_not_event;
  logic clk = 0, a = 0, b = 0;
  sequence s_ev(event ev);
    @(ev) a ##1 b;
  endsequence
  c_ok: cover property (s_ev(posedge clk));
  c_neg: cover property (s_ev(negedge clk));
  c_bad: cover property (s_ev(a ##1 b));   // illegal
endmodule

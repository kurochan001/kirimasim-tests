/*
:name: test_illegal_sequence_event_formal_as_boolean
:description: a reference to an event sequence formal has to be in a place where an event expression may be written (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s_bad uses its event formal ev as a Boolean expression of the sequence
:expected_stderr_regex: test_illegal_sequence_event_formal_as_boolean\.sv:27:
*/
// IEEE 1800-2023 §16.8.1: each reference to a formal of type event shall be
// in a place where an event expression may be written. s_ev uses ev as the
// clocking event, which is legal; s_bad uses ev as a Boolean expression of
// the sequence.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support event actuals; neither error counts.

module test_illegal_sequence_event_formal_as_boolean;
  logic clk = 0, a = 0, b = 0;
  sequence s_ev(event ev);
    @(ev) a ##1 b;
  endsequence
  sequence s_bad(event ev);
    a ##1 ev;   // illegal
  endsequence
  c_ev: cover property (s_ev(posedge clk));
endmodule

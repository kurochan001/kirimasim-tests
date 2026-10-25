/*
:name: test_illegal_sequence_formal_event_default_not_event
:description: the default actual of a typed sequence formal obeys the rules for its actuals: an event formal needs an event expression (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default actual of the event formal ev of s_bad is the sequence expression a ##1 b, which is not an event expression
:expected_stderr_regex: test_illegal_sequence_formal_event_default_not_event\.sv:26:
*/
// IEEE 1800-2023 §16.8.1: the rules for the actual of a typed formal apply
// to its default actual as well; the actual of a formal of type event shall
// be an event expression. The default of ev in s_ok is posedge clk, an event
// expression; the default of ev in s_bad is the sequence expression a ##1 b.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support event actuals; neither error counts.

module test_illegal_sequence_formal_event_default_not_event;
  logic clk = 0, a = 0, b = 0;
  sequence s_ok(event ev = posedge clk);
    @(ev) a ##1 b;
  endsequence
  sequence s_bad(event ev = a ##1 b);   // illegal
    @(ev) a ##1 b;
  endsequence
  p_ok: cover property (s_ok);
  p_bad: cover property (s_bad(negedge clk));
endmodule

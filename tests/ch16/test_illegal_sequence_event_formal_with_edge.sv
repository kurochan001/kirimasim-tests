/*
:name: test_illegal_sequence_event_formal_with_edge
:description: a sequence formal meant to be combined with an edge to form an event expression cannot have the type event (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s_bad applies posedge to its formal ev, whose type is event
:expected_stderr_regex: test_illegal_sequence_event_formal_with_edge\.sv:31:
*/
// IEEE 1800-2023 §16.8.1: if the actual is an expression that the sequence
// combines with an edge identifier to make an event expression, the formal
// shall not have the type event. s_sig applies posedge to its formal sig of
// type logic, and s_ev uses its event formal as a whole event expression,
// which are legal; s_bad applies posedge to its event formal ev.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support event actuals; neither error counts.

module test_illegal_sequence_event_formal_with_edge;
  logic clk = 0, a = 0, b = 0;
  sequence s_sig(logic sig);
    @(posedge sig) a ##1 b;
  endsequence
  sequence s_ev(event ev);
    @(ev) a ##1 b;
  endsequence
  sequence s_bad(event ev);
    @(posedge ev) a ##1 b;   // illegal
  endsequence
  c_sig: cover property (s_sig(clk));
  c_ev: cover property (s_ev(posedge clk));
  c_bad: cover property (s_bad(clk));
endmodule

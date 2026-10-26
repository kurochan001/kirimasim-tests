/*
:name: test_illegal_triggered_ending_clock
:description: triggered may detect the end point of a multiclocked sequence only when the ending clock of that sequence is the clock of the context, so s_multi.triggered under posedge c3 is an error when s_multi ends at posedge c2 (IEEE 1800-2023 Section 16.13.5)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad applies triggered in a posedge c3 context to s_multi, whose ending clock is posedge c2
:expected_stderr_regex: test_illegal_triggered_ending_clock\.sv:30:
*/
// IEEE 1800-2023 §16.13.5: triggered can detect the end point of a
// multiclocked sequence when the ending clock of the sequence instance is the
// same as the clock of the context. s_multi starts at posedge c1 and ends at
// posedge c2. p_ok applies triggered in a posedge c2 context and is legal;
// p_bad applies it in a posedge c3 context, where the end point cannot be
// detected, and is illegal.

module test_illegal_triggered_ending_clock;
  logic c1 = 0, c2 = 0, c3 = 0;
  logic a = 0, b = 0;

  sequence s_multi;
    @(posedge c1) a ##1 @(posedge c2) b;
  endsequence

  p_ok: assert property (@(posedge c2) s_multi.triggered);
  p_bad: assert property (@(posedge c3) s_multi.triggered);   // illegal
endmodule

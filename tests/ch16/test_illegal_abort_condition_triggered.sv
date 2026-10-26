/*
:name: test_illegal_abort_condition_triggered
:description: An abort condition of accept_on, reject_on, sync_accept_on or sync_reject_on shall not reference the sequence method triggered, so accept_on (s.triggered) is an error (IEEE 1800-2023 Section 16.12.14)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.14 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the abort condition of p_bad is s.triggered, a reference to the sequence method triggered
:expected_stderr_regex: test_illegal_abort_condition_triggered\.sv:30:
*/
// IEEE 1800-2023 §16.12.14: abort conditions may contain sampled value
// functions, but shall not contain any reference to local variables or to
// the sequence methods triggered and matched. p_ok aborts on the Boolean c
// and is legal. p_bad aborts on s.triggered, a sequence method inside an
// abort condition, and is illegal.

module test_illegal_abort_condition_triggered;
  logic clk = 0;
  logic a = 1;
  logic c = 0;

  sequence s;
    @(posedge clk) a;
  endsequence

  p_ok: assert property (@(posedge clk) accept_on (c) a);
  p_bad: assert property (@(posedge clk) accept_on (s.triggered) a);   // illegal
endmodule

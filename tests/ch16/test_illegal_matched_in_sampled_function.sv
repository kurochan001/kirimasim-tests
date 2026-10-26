/*
:name: test_illegal_matched_in_sampled_function
:description: It is an error to use the sequence method matched in a sampled value function, because matched is only defined in sequence expressions (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: src.matched is the argument of the sampled value function $rose
:expected_stderr_regex: test_illegal_matched_in_sampled_function\.sv:29:
*/
// IEEE 1800-2023 §16.13.6: matched can be used only in sequence expressions,
// and it shall be an error to use it in a sampled value function (16.9.3).
// In p_ok, src.matched stands alone as a sequence expression and is legal.
// In p_bad it is the argument of $rose, a sampled value function, so the
// design is illegal; $rose cannot sample the event that matched reports.

module test_illegal_matched_in_sampled_function;
  logic c1 = 0, c2 = 0;
  logic a = 0;

  sequence src;
    @(posedge c1) a;
  endsequence

  p_ok: assert property (@(posedge c2) src.matched);
  p_bad: assert property (@(posedge c2) $rose(src.matched));   // illegal
endmodule

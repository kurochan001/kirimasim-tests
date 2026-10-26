/*
:name: test_illegal_disable_iff_matched
:description: a disable iff condition uses the sequence method matched, which it shall not contain
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition of a_bad uses s.matched
:expected_stderr_regex: test_illegal_disable_iff_matched\.sv:26:
*/
// IEEE 1800-2023 §16.6: the expression of a disable condition is evaluated
// with the current values of variables, may contain sequence.triggered, and
// shall not reference local variables or the sequence method matched. The
// disable condition of a_bad is s.matched, so a_bad is illegal.

module test_illegal_disable_iff_matched;
  logic clk = 0, a = 0, b = 1;

  sequence s;
    a ##1 b;
  endsequence

  a_bad: assert property (@(posedge clk) disable iff (s.matched) a);   // illegal
endmodule

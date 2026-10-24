/*
:name: test_illegal_disable_iff_matched
:description: A disable condition cannot use the sequence method matched (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition uses s_m.matched
:expected_stderr_regex: test_illegal_disable_iff_matched\.sv:29:
*/
// IEEE 1800-2023 §16.12: the disable condition may use the method triggered
// of a sequence but shall not contain the sequence method matched. The
// assertion, clocked by clk, uses s_m.matched of a sequence clocked by clk2
// as its disable condition.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_disable_iff_matched;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  sequence s_m;
    @(posedge clk2) a ##1 b;
  endsequence

  a_m: assert property (@(posedge clk) disable iff (s_m.matched) a |=> b);   // illegal
endmodule

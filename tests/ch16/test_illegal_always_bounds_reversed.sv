/*
:name: test_illegal_always_bounds_reversed
:description: the range of always has a maximum smaller than its minimum
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: always[3:1] in a_bad has the minimum 3 and the maximum 1
:expected_stderr_regex: test_illegal_always_bounds_reversed\.sv:22:
*/
// IEEE 1800-2023 §16.12.11: when both bounds of the range of always or
// s_always are finite, the minimum shall be less than or equal to the
// maximum. always[3:1] has the minimum 3 and the maximum 1, so the property
// in a_bad is illegal.

module test_illegal_always_bounds_reversed;
  logic clk = 0, a = 1;

  a_bad: assert property (@(posedge clk) always[3:1] a);   // illegal
endmodule

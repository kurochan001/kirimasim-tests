/*
:name: test_illegal_past_count_variable
:description: the number of ticks of $past is a variable instead of an elaboration-time constant
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second argument of $past in a_bad is the variable n
:expected_stderr_regex: test_illegal_past_count_variable\.sv:22:
*/
// IEEE 1800-2023 §16.9.3: the number of ticks of $past shall be an
// elaboration-time constant expression and at least 1. The second argument
// of $past in a_bad is the variable n, so the assertion is illegal.

module test_illegal_past_count_variable;
  logic clk = 0, a = 1;
  int n = 2;

  a_bad: assert property (@(posedge clk) a |-> $past(a, n));   // illegal
endmodule

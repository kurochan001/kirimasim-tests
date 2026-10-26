/*
:name: test_illegal_repetition_upper_bound_variable
:description: the upper bound of a repetition is a variable instead of a constant expression
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the repetition a[*1:n] in a_bad uses the variable n as its upper bound
:expected_stderr_regex: test_illegal_repetition_upper_bound_variable\.sv:23:
*/
// IEEE 1800-2023 §16.9.2: the minimum and maximum of a finite repetition
// range shall be non-negative integer constant expressions, or the maximum
// may be $. The upper bound n of a[*1:n] in a_bad is a variable, so the
// sequence is illegal.

module test_illegal_repetition_upper_bound_variable;
  logic clk = 0, a = 1;
  int n = 2;

  a_bad: assert property (@(posedge clk) a[*1:n]);   // illegal
endmodule

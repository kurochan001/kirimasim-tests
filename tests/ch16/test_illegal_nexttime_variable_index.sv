/*
:name: test_illegal_nexttime_variable_index
:description: the index of nexttime is a variable instead of a constant expression
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: nexttime[n] in a_bad uses the variable n
:expected_stderr_regex: test_illegal_nexttime_variable_index\.sv:22:
*/
// IEEE 1800-2023 §16.12.10: the number of clock ticks of nexttime and
// s_nexttime shall be a non-negative integer constant expression. The index n
// of nexttime[n] in a_bad is a variable, so the property is illegal.

module test_illegal_nexttime_variable_index;
  logic clk = 0, a = 1;
  int n = 1;

  a_bad: assert property (@(posedge clk) nexttime[n] a);   // illegal
endmodule

/*
:name: test_illegal_output_actual_module_variable
:description: the actual of a local output formal is a module variable, not a local variable of the assertion
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s in a_bad binds the module variable glob to the local output formal v
:expected_stderr_regex: test_illegal_output_actual_module_variable\.sv:28:
*/
// IEEE 1800-2023 §16.8.2: the entire actual of an inout or output local
// variable formal shall be a reference to an in-scope local variable whose
// type is cast compatible with the formal. glob is a static module variable,
// not a local variable of the assertion, so the instance in a_bad is
// illegal.

module test_illegal_output_actual_module_variable;
  logic clk = 0, a = 1;
  int glob = 0;

  sequence s(local output int v);
    (a, v = 1);
  endsequence

  a_bad: assert property (@(posedge clk) s(glob));   // illegal
endmodule

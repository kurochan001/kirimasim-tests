/*
:name: test_illegal_checker_free_variable_continuous_assign
:description: A free checker variable cannot be driven by a continuous assignment (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1 17.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a continuous assignment drives a free checker variable
:expected_stderr_regex: test_illegal_checker_free_variable_continuous_assign\.sv:20:
*/
// IEEE 1800-2023 §17.7.1: a free checker variable, one declared rand, shall
// not be the target of a continuous assignment or a blocking procedural
// assignment; a nonblocking assignment in always_ff may assign one.

checker test_illegal_checker_free_variable_continuous_assign_chk(logic a, logic b, logic clk);
  rand bit x;
  assign x = a & b;   // illegal: continuous assignment to a free variable
  p: assert property (@(posedge clk) x |-> a);
endchecker

module test_illegal_checker_free_variable_continuous_assign;
  logic clk = 0, a = 1, b = 1;
  test_illegal_checker_free_variable_continuous_assign_chk c(a, b, clk);
  initial #1 clk = 1;
endmodule

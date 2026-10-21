/*
:name: test_illegal_checker_variable_initial_assignment
:description: A checker variable cannot be assigned in an initial procedure, only initialized in its declaration (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an initial procedure of the checker assigns a checker variable
:expected_stderr_regex: test_illegal_checker_variable_initial_assignment\.sv:23:
*/
// IEEE 1800-2023 §17.7.1: a checker variable may be initialized in its
// declaration but shall not be assigned in an initial procedure. §17.5: an
// initial procedure of a checker holds let declarations, assertions and event
// controls.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

checker test_illegal_checker_variable_initial_assignment_chk(logic a, logic clk);
  bit armed = 1;
  bit seen;
  initial seen = 1;   // illegal: assignment in an initial procedure
  p: assert property (@(posedge clk) armed && seen |-> a);
endchecker

module test_illegal_checker_variable_initial_assignment;
  logic clk = 0, a = 1;
  test_illegal_checker_variable_initial_assignment_chk c(a, clk);
  initial #1 clk = 1;
endmodule

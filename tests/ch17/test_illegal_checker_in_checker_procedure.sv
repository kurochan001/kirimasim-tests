/*
:name: test_illegal_checker_in_checker_procedure
:description: A checker cannot be instantiated in a procedure of another checker (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a checker is instantiated inside an always_ff procedure of another checker
:expected_stderr_regex: test_illegal_checker_in_checker_procedure\.sv:26:
*/
// IEEE 1800-2023 §17.3: it shall be illegal to instantiate a checker in a
// procedure of another checker; a checker can still instantiate one outside
// its procedures.
// The syntax error that Verilator 5.052 reports on that line does not count: it
// does not support checker instances in procedural code.

checker test_illegal_checker_in_checker_procedure_inner(logic a, logic clk);
  p: assert property (@(posedge clk) a);
endchecker

checker test_illegal_checker_in_checker_procedure_outer(logic a, logic clk);
  always_ff @(posedge clk)
    test_illegal_checker_in_checker_procedure_inner i(a, clk);   // illegal
endchecker

module test_illegal_checker_in_checker_procedure;
  logic clk = 0, a = 1;
  test_illegal_checker_in_checker_procedure_outer c(a, clk);
  initial #1 clk = 1;
endmodule

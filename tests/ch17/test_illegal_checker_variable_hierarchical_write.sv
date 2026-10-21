/*
:name: test_illegal_checker_variable_hierarchical_write
:description: A module cannot assign a checker variable through its hierarchical name (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1 23.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a module assigns a variable of a checker instance by hierarchical name
:expected_stderr_regex: test_illegal_checker_variable_hierarchical_write\.sv:30:
*/
// IEEE 1800-2023 §17.7.1: referencing a checker variable by its
// hierarchical name in an assignment shall be illegal; only the checker
// assigns its variables. No procedure of the checker assigns armed, so the
// module's assignment is the only one.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

checker test_illegal_checker_variable_hierarchical_write_chk(logic a, logic clk);
  bit armed = 1;
  p: assert property (@(posedge clk) armed |-> a);
endchecker

module test_illegal_checker_variable_hierarchical_write;
  logic clk = 0, a = 1;
  test_illegal_checker_variable_hierarchical_write_chk c(a, clk);
  initial begin
    #1 clk = 1;
    #1 c.armed = 0;   // illegal: checker variable assigned by hierarchical name
  end
endmodule

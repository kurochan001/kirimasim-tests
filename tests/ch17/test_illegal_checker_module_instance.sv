/*
:name: test_illegal_checker_module_instance
:description: A module cannot be instantiated inside a checker (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker instantiates a module
:expected_stderr_regex: test_illegal_checker_module_instance\.sv:22:
*/
// IEEE 1800-2023 §17.2: a checker body holds declarations, assertions,
// covergroups, checker variables and procedures, and other checkers, but
// modules, interfaces and programs shall not be instantiated inside it.

module test_illegal_checker_module_instance_leaf(input logic a);
endmodule

checker test_illegal_checker_module_instance_chk(logic a, logic clk);
  test_illegal_checker_module_instance_leaf u(a);   // illegal: module instance in a checker
  p: assert property (@(posedge clk) a);
endchecker

module test_illegal_checker_module_instance;
  logic clk = 0, a = 1;
  test_illegal_checker_module_instance_chk c(a, clk);
  initial #1 clk = 1;
endmodule

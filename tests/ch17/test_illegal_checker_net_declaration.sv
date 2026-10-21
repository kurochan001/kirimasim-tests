/*
:name: test_illegal_checker_net_declaration
:description: A net cannot be declared in the body of a checker (IEEE 1800-2023 Section 17.7)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker declares a net
:expected_stderr_regex: test_illegal_checker_net_declaration\.sv:18:
*/
// IEEE 1800-2023 §17.7: variables can be declared in a checker, but
// declaring nets in the checker body shall be illegal.

checker test_illegal_checker_net_declaration_chk(logic a, logic clk);
  wire w;   // illegal: a net in a checker
  p: assert property (@(posedge clk) a);
endchecker

module test_illegal_checker_net_declaration;
  logic clk = 0, a = 1;
  test_illegal_checker_net_declaration_chk c(a, clk);
  initial #1 clk = 1;
endmodule

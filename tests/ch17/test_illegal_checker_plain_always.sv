/*
:name: test_illegal_checker_plain_always
:description: A checker can hold always_comb, always_latch and always_ff procedures but not a plain always procedure (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker contains a plain always procedure
:expected_stderr_regex: test_illegal_checker_plain_always\.sv:20:
*/
// IEEE 1800-2023 §17.5: of the always procedures, only always_comb,
// always_latch and always_ff are allowed in checkers.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

checker test_illegal_checker_plain_always_chk(logic a, logic clk);
  bit seen;
  always @(posedge clk) seen <= a;   // illegal: plain always in a checker
  p: assert property (@(posedge clk) a);
endchecker

module test_illegal_checker_plain_always;
  logic clk = 0, a = 1;
  test_illegal_checker_plain_always_chk c(a, clk);
  initial #1 clk = 1;
endmodule

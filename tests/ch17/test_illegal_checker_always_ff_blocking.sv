/*
:name: test_illegal_checker_always_ff_blocking
:description: An always_ff procedure of a checker can only use nonblocking assignments (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an always_ff procedure of the checker uses a blocking assignment
:expected_stderr_regex: test_illegal_checker_always_ff_blocking\.sv:21:
*/
// IEEE 1800-2023 §17.7.1: in always_ff procedures of a checker only
// nonblocking assignments are allowed. §17.5: blocking assignments are allowed
// in always_comb and always_latch procedures only.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

checker test_illegal_checker_always_ff_blocking_chk(logic a, logic clk);
  bit last;
  always_ff @(posedge clk) last = a;   // illegal: blocking assignment in always_ff
endchecker

module test_illegal_checker_always_ff_blocking;
  logic clk = 0, a = 1;
  test_illegal_checker_always_ff_blocking_chk c(a, clk);
  initial #1 clk = 1;
endmodule

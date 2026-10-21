/*
:name: test_illegal_checker_in_fork
:description: A checker cannot be instantiated in a fork-join block (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a checker is instantiated inside a fork-join block
:expected_stderr_regex: test_illegal_checker_in_fork\.sv:28:
*/
// IEEE 1800-2023 §17.3: a checker can be instantiated where a concurrent
// assertion can appear, except that it shall be illegal to instantiate one in
// a fork-join, fork-join_any or fork-join_none block.
// The syntax error that Verilator 5.052 reports on that line does not count: it
// does not support checker instances in procedural code.

checker test_illegal_checker_in_fork_chk(logic a, logic clk);
  p: assert property (@(posedge clk) a);
endchecker

module test_illegal_checker_in_fork;
  logic clk = 0, a = 1;
  always @(posedge clk)
    fork
      test_illegal_checker_in_fork_chk c(a, clk);   // illegal: checker in fork-join
    join
  initial #1 clk = 1;
endmodule

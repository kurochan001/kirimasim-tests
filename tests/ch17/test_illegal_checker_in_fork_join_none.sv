/*
:name: test_illegal_checker_in_fork_join_none
:description: A checker cannot be instantiated in a fork-join_none block (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a checker is instantiated inside a fork-join_none block
:expected_stderr_regex: test_illegal_checker_in_fork_join_none\.sv:33:
*/
// IEEE 1800-2023 17.3: a checker may be instantiated where a concurrent
// assertion may appear, but it shall be illegal to instantiate one in a
// fork-join, fork-join_any or fork-join_none block. The block below is a
// fork-join_none block. The rest of the design is legal.
// Icarus Verilog 13.0 does not support checkers at all and Verilator 5.052
// reports a syntax error on that line because it does not support checker
// instances in procedural code, so no release is named.

`timescale 1ns/1ns

checker fork_none_chk(logic a, logic clk);
  p: assert property (@(posedge clk) a);
endchecker : fork_none_chk

module test_illegal_checker_in_fork_join_none;
  logic clk = 1'b0, a = 1'b1;

  initial begin
    fork
      fork_none_chk c(a, clk);   // illegal
    join_none
  end

  initial #1 clk = 1'b1;
endmodule

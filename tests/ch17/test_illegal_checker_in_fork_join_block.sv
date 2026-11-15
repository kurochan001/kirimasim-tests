/*
:name: test_illegal_checker_in_fork_join_block
:description: a checker can be instantiated in an initial procedure but not in a fork-join block inside it (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker instance c_fork is a statement of a fork-join block
:expected_stderr_regex: test_illegal_checker_in_fork_join_block\.sv:35:
*/
// IEEE 1800-2023 §17.3: a checker may be instantiated wherever a concurrent
// assertion may appear, but it shall be illegal to instantiate a checker in a
// fork-join, fork-join_any or fork-join_none block.
// The initial procedure below first instantiates fj_chk as a procedural
// checker instance, which is legal, and then runs a fork-join block whose
// first statement is another instance of fj_chk, which is the only error.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release
// of Verilator reports a syntax error at the legal instance c_proc
// because it does not support checker instances in procedural code, so
// neither counts.

checker fj_chk(logic a, event clk);
  p: assert property (@clk a);
endchecker : fj_chk

module test_illegal_checker_in_fork_join_block;
  logic clk = 1'b0, a = 1'b1;

  initial begin
    fj_chk c_proc(a, posedge clk);
    fork
      fj_chk c_fork(a, posedge clk);   // illegal
      #1 clk = 1'b1;
    join
  end
endmodule

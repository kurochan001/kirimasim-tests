/*
:name: test_illegal_cycle_delay_intra_nonblocking
:description: a cycle delay cannot be the intra-assignment delay of a nonblocking assignment to a variable, although it can be one in a synchronous drive (IEEE 1800-2023 Section 14.11)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.11 14.16 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nonblocking assignment to the variable b has the cycle delay ##1 as its intra-assignment delay
:expected_stderr_regex: test_illegal_cycle_delay_intra_nonblocking\.sv:37:
*/
// IEEE 1800-2023 §14.11: cycle delays shall not be used as intra-assignment
// delays of blocking or nonblocking assignments. §14.16: a synchronous drive,
// which is written with the same operator <=, may have a cycle delay on its
// right-hand side, so cb.y <= ##1 1'b1 is legal; §10.4.2: a nonblocking
// assignment may have an ordinary intra-assignment delay, so b <= #1 a is
// legal. b is a variable, not a clockvar, so b <= ##1 a is a nonblocking
// assignment with a cycle delay. test_illegal_cycle_delay_intra_assignment
// covers a blocking assignment.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_cycle_delay_intra_nonblocking;
  logic clk = 0;
  int a = 1, b = 0;
  logic y;
  default clocking cb @(posedge clk);
    output y;
  endclocking
  always #5 clk = ~clk;
  initial begin
    cb.y <= ##1 1'b1;
    b <= #1 a;
    b <= ##1 a;   // illegal
  end
  initial #30 $finish;
endmodule

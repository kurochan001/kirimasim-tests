/*
:name: test_illegal_clocking_drive_intra_event
:description: a synchronous drive cannot have an intra-assignment event control, although a nonblocking assignment to a variable can (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16 14.16.1 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the synchronous drive of cb.y has the event control @(posedge clk) as its intra-assignment timing control
:expected_stderr_regex: test_illegal_clocking_drive_intra_event\.sv:38:
*/
// IEEE 1800-2023 §14.16: the only timing control a synchronous drive may have
// on its right-hand side is a cycle delay; no other form of intra-assignment
// delay is legal in a drive to a clockvar. §14.16.1 repeats that drives do not
// take the intra-assignment timing of nonblocking assignments. cb.z <= ##1 1'b1
// is legal. §10.4.2: w is a variable, not a clockvar, and the nonblocking
// assignment w <= @(posedge clk) 1 with an intra-assignment event control is
// legal. The drive of cb.y uses the same event control.
// test_illegal_clocking_drive_intra_delay covers a # delay.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_clocking_drive_intra_event;
  logic clk = 0;
  logic y, z;
  int w = 0;
  default clocking cb @(posedge clk);
    output y, z;
  endclocking
  always #5 clk = ~clk;
  initial begin
    @(cb);
    cb.z <= ##1 1'b1;
    w <= @(posedge clk) 1;
    cb.y <= @(posedge clk) 1'b1;   // illegal
  end
  initial #30 $finish;
endmodule

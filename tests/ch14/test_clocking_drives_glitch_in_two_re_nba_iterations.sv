/*
:name: test_clocking_drives_glitch_in_two_re_nba_iterations
:description: two synchronous drives with different values that mature in two passes through the Re-NBA region of one time step make the clocking signal change twice in that time step (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2 14.16 4.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drives_glitch_in_two_re_nba_iterations.expected
*/
// IEEE 1800-2023 §14.16.2: the scheduling loop can pass through the Re-NBA
// region more than once in a time step; synchronous drives that assign
// different values to a clockvar in different passes make its signal glitch,
// that is, change more than once in the time step. §14.16: a drive at the
// time of its clocking event with zero output skew updates the signal in the
// Re-NBA region of that time step. §4.4.2: an update in the Re-NBA region
// wakes processes in the Active region, after which the loop reaches the
// Re-NBA region again.
//
// The first posedge is at 5. After ##1 the process drives cb.a <= 0 and waits
// for x. In the Re-NBA region a becomes 0; the always procedure records the
// change and triggers x, the process resumes in the same time step and drives
// cb.a <= 1, and in the next pass through the Re-NBA region a becomes 1. The
// always procedure records both changes at 5: a goes 1 -> 0 -> 1, as in the
// example of 14.16.2. A simulator that moves the second drive to the next
// clocking event has recorded only 5:0 at 6 and shows a=0 there. Changes at
// time 0 are not recorded.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns

module test_clocking_drives_glitch_in_two_re_nba_iterations;
  logic clk = 0;
  bit a = 1'b1;
  event x;
  string seen = "";

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output a;
  endclocking

  always @(a) if ($time > 0) begin
    seen = {seen, $sformatf(" %0t:%b", $time, a)};
    if (a == 1'b0) -> x;
  end

  initial begin
    ##1;
    cb.a <= 1'b0;
    @(x);
    cb.a <= 1'b1;
  end

  initial begin
    #6 $display("changes of a:%s", seen);
    $display("t=%0t a=%b", $time, a);
    $finish;
  end
endmodule

/*
:name: test_clocking_future_drive_in_re_nba
:description: A synchronous drive to an output with a nonzero skew, or with a cycle delay, changes its signal in the Re-NBA region of the later time step: processes woken there by a nonblocking assignment still see the old value, and the end of that time step sees the new one (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.4 4.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_future_drive_in_re_nba.expected
*/
// IEEE 1800-2023 §14.16: for a clocking block output with a nonzero skew,
// or a drive with a nonzero cycle delay, the signal is scheduled to change
// in the Re-NBA region of a future time step. The Re-NBA region of that time
// step comes after its whole active region set (4.4.2).
//
// The posedges are at 5, 15, 25. At the event at 5, cb.w <= 1 drives w,
// which has output skew #2, and cb.u <= ##1 1 drives u, which has no skew:
// w changes at 7 and u at 15. At 7 a process does flag_w <= 1, and at the
// event at 15 another one does flag_u <= 1; the processes woken by these
// NBA updates run before the Re-NBA region and see w = 0 and u = 0, while
// $strobe at 7 and at 15 sees the new values.
//
// Simulator note: in a run with Verilator 5.052 the process woken at 7
// already sees w = 1: the drive with output skew #2 is not applied in the
// Re-NBA region there. The u lines match.

`timescale 1ns/1ns

module test_clocking_future_drive_in_re_nba;
  logic clk = 0;
  logic w = 0, u = 0;
  bit flag_w = 0, flag_u = 0;
  int seen_w = -1, seen_u = -1;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output #2 w;
    output u;
  endclocking

  always @(flag_w) seen_w = w;
  always @(flag_u) seen_u = u;

  initial begin
    @(cb);
    cb.w <= 1'b1;
    cb.u <= ##1 1'b1;
    #2;
    flag_w <= 1'b1;
    $strobe("t=%0t end of time step: w=%b", $time, w);
    @(cb);
    flag_u <= 1'b1;
    $strobe("t=%0t end of time step: u=%b", $time, u);
    #1;
    $display("t=%0t woken at 7 by the NBA of flag_w: w=%0d", $time, seen_w);
    $display("t=%0t woken at 15 by the NBA of flag_u: u=%0d", $time, seen_u);
    $finish;
  end
endmodule

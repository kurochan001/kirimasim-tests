/*
:name: test_clocking_zero_skew_drive_in_re_nba
:description: A synchronous drive at a clocking event to an output with no skew or an explicit #0 skew updates its signal in the Re-NBA region of that time step, after the NBA updates and the processes they wake, and before the time step ends (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.4 4.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_zero_skew_drive_in_re_nba.expected
*/
// IEEE 1800-2023 §14.16: for a clocking block output with zero skew and a
// drive with no cycle delay, the drive schedules the new value in the
// Re-NBA region of the time step of the clocking event. §14.4: outputs with
// no skew, or an explicit #0 skew, are driven at the clocking event in the
// Re-NBA region. The Re-NBA region comes after the whole active region set
// of the time step, including the NBA region and the Active regions that
// follow it (4.4.2).
//
// At the clocking event at 5, a process drives y (no skew) and z (#0 skew)
// and then does the nonblocking assignment flag <= 1. The NBA update of flag
// wakes an always procedure, which runs in an Active region before the
// Re-NBA region and so still sees y = 0 and z = 0. $strobe, in the
// Postponed region of the same time step, sees both at 1.

`timescale 1ns/1ns

module test_clocking_zero_skew_drive_in_re_nba;
  logic clk = 0;
  logic y = 0, z = 0;
  bit flag = 0;
  int seen_y = -1, seen_z = -1;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    output y;
    output #0 z;
  endclocking

  always @(flag) begin
    seen_y = y;
    seen_z = z;
  end

  initial begin
    @(cb);
    cb.y <= 1'b1;
    cb.z <= 1'b1;
    flag <= 1'b1;
    $strobe("t=%0t end of time step: y=%b z=%b", $time, y, z);
    #1;
    $display("t=%0t woken by the NBA of flag: y=%0d z=%0d", $time, seen_y, seen_z);
    $finish;
  end
endmodule

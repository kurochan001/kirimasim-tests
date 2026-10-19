/*
:name: test_clocking_drive_last_wins
:description: Synchronous drives maturing together leave the last value, a cycle delay makes a drive mature later, and driving an inout does not change its sampled value (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2 14.16.1 14.16 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drive_last_wins.expected
*/
// IEEE 1800-2023 §14.16.2: when several synchronous drives to one clocking
// output mature in the same time step, only the last value is driven, and a
// drive with a cycle delay ##n matures n clocking events later. §14.16.1: a
// drive to an inout clockvar does not change what reading the clockvar gives,
// which stays the last sampled value. Without skews, inputs are sampled one
// step before the event and outputs are driven at the event (14.3).

`timescale 1ns/1ns

module test_clocking_drive_last_wins;
  logic clk = 0;
  logic [3:0] nib = 0;
  logic [3:0] io = 0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25, 35

  default clocking cb @(posedge clk);
    output nib;
    inout io;
  endclocking

  initial begin
    @(cb);
    cb.nib <= 4'h1;
    cb.nib <= 4'h3;
    cb.io <= 4'h5;
    #1;
    $display("%0d: nib=%h io=%h cb.io=%h", $time, nib, io, cb.io);
    @(cb);
    $display("%0d: cb.io=%h", $time, cb.io);
    cb.nib <= ##2 4'h7;
    #11;
    $display("%0d: nib=%h", $time, nib);
    #10;
    $display("%0d: nib=%h", $time, nib);
    $finish;
  end
endmodule

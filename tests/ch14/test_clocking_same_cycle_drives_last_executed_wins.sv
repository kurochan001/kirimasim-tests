/*
:name: test_clocking_same_cycle_drives_last_executed_wins
:description: When several synchronous drives to one clocking output mature in the same time step, only the value of the last one executed is driven, whether the drives were executed between clocking events or at a clocking event (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2 14.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_same_cycle_drives_last_executed_wins.expected
*/
// IEEE 1800-2023 §14.16.2: when more than one synchronous drive to the same
// clocking output is scheduled to mature in the same Re-NBA region of the
// same time step, only the last value is driven, whether the drives were
// executed at clocking events or between them in the same clock cycle.
// A drive between events matures at the next event, and ##1 at an event
// one event later (14.16).
//
// The posedges are at 5, 15, 25, 35. All drives go to n:
//   - at 8 and at 12, between events, n <= 1 and n <= 2: both mature at 15;
//   - at the event at 15, n <= ##1 5, and at 18 n <= 6: both mature at 25;
//   - at 28 n <= 8, and at the event at 35 n <= 9: both mature at 35.
// Each process waits for the next event or a fixed time, so the drives of
// each pair are executed in that order; n then has 2, 6 and 9. (The
// example in 14.16.2 likewise gives the value of the drive executed last
// when drives with different cycle delays mature in the same cycle.)
//
// Simulator note: in a run with Verilator 5.052 n is 5 at 26: the drive
// executed at 15 with ##1 wins over the later drive executed at 18.

`timescale 1ns/1ns

module test_clocking_same_cycle_drives_last_executed_wins;
  logic clk = 0;
  int n = 0;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output n;
  endclocking

  initial begin
    #8 cb.n <= 1;
    #4 cb.n <= 2;
  end

  initial begin
    @(cb);
    @(cb);
    cb.n <= ##1 5;
    #3 cb.n <= 6;
  end

  initial begin
    #28 cb.n <= 8;
    @(cb);
    cb.n <= 9;
  end

  initial begin
    #14 $display("t=%0t n=%0d", $time, n);
    #2 $display("t=%0t n=%0d", $time, n);
    #10 $display("t=%0t n=%0d", $time, n);
    #10 $display("t=%0t n=%0d", $time, n);
    $finish;
  end
endmodule

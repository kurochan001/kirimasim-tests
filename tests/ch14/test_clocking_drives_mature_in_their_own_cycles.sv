/*
:name: test_clocking_drives_mature_in_their_own_cycles
:description: Synchronous drives to one clocking output with different cycle delays stay pending together, and each one changes the signal in its own future cycle (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drives_mature_in_their_own_cycles.expected
*/
// IEEE 1800-2023 §14.16.2: when one clocking output is driven by several
// synchronous drives that are scheduled to mature at different future times
// because of their cycle delays, each drive matures in its own cycle; a
// later drive does not cancel an earlier one with another cycle.
//
// The posedges are at 5, 15, 25, 35, 45. At the event at 5 the process
// executes cb.v <= ##1 1, cb.v <= ##3 3 and cb.v <= ##2 2, in that order,
// without blocking. v becomes 1 at 15, 2 at 25 and 3 at 35, and keeps 3;
// it is shown one time unit after each event.

`timescale 1ns/1ns

module test_clocking_drives_mature_in_their_own_cycles;
  logic clk = 0;
  int v = 0;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output v;
  endclocking

  initial begin
    @(cb);
    cb.v <= ##1 1;
    cb.v <= ##3 3;
    cb.v <= ##2 2;
    $display("t=%0t drives done", $time);
    #1 $display("t=%0t v=%0d", $time, v);
    repeat (4) #10 $display("t=%0t v=%0d", $time, v);
    $finish;
  end
endmodule

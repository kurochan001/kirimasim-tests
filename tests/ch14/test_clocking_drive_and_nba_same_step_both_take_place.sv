/*
:name: test_clocking_drive_and_nba_same_step_both_take_place
:description: a synchronous drive and a nonblocking assignment that write the same variable in one time step both take place, in an order the standard leaves open, so the variable takes both values and ends with one of them (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2 14.16 4.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drive_and_nba_same_step_both_take_place.expected
*/
// IEEE 1800-2023 §14.16.2: a variable associated with an output clockvar may
// also be written by procedural assignments; if a synchronous drive and a
// procedural nonblocking assignment write it in the same time step, both
// writes take place, in an arbitrary order. §14.16: the drive below matures
// in the Re-NBA region of the time step of the event; §4.4.2: the
// nonblocking assignment of a module process is updated in the NBA region.
// Either write wakes the always procedure that records the values of v
// before the other one is made, since the two regions are separate passes of
// the scheduling loop.
//
// At the event at 5 the process drives cb.v <= 2 and then executes v <= 1.
// Whichever write comes first, v changes twice at 5, the always procedure
// sees 1 and 2, and v ends with 1 or with 2. The printed lines do not depend
// on the order, so the test does not fix it. A simulator that drops one of
// the two writes when both fall in one time step prints a 0 flag and one
// change. Changes at time 0 are not counted.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns

module test_clocking_drive_and_nba_same_step_both_take_place;
  logic clk = 0;
  int v = 0;
  int changes = 0;
  bit saw_nba = 0, saw_drive = 0;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    output v;
  endclocking

  always @(v) if ($time > 0) begin
    changes++;
    if (v == 1) saw_nba = 1;
    if (v == 2) saw_drive = 1;
  end

  initial begin
    @(cb);
    cb.v <= 2;
    v <= 1;
    #1;
    $display("t=%0t value of the nonblocking assignment seen: %0b", $time, saw_nba);
    $display("t=%0t value of the synchronous drive seen: %0b", $time, saw_drive);
    $display("t=%0t changes of v at 5: %0d", $time, changes);
    $display("t=%0t v ends with one of the two values: %0b", $time, v == 1 || v == 2);
    $finish;
  end
endmodule

/*
:name: test_clocking_input_step_skew
:description: An input skew of 1step samples the value the input had at the end of the previous time step, so a change in the clocking event's own time step is not seen, while a skew of one time unit samples it one unit earlier (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.13 3.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_step_skew.expected
*/
// IEEE 1800-2023 §14.4: an input skew gives the number of time units before
// the clocking event at which the clockvar samples its signal; the special
// value 1step samples the value the signal had at the end of the previous
// time step, which is the value in the Preponed region of the event's time
// step (14.4, 14.13, 4.4.2.1). §14.13: the process that waits on the block
// reads the value sampled by that event.
// With a time unit of 1ns and a precision of 1ps, d changes at 4.5, at
// 14.999 and at 15, in the time step of the edge itself. The block with the
// skew 1step therefore sees 1 at the edge at 5 and, at the edge at 15, the
// 0 of the previous time step, not the 1 written at 15; the block with the
// skew 1 samples at 4 and at 14 and sees the old values 0 and 1.

`timescale 1ns/1ps

module test_clocking_input_step_skew;
  logic clk = 0;
  logic d = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  initial #15 d = 1;      // in the time step of the edge at 15

  clocking step_ck @(posedge clk);
    input #1step d;
  endclocking

  clocking unit_ck @(posedge clk);
    input #1 d;
  endclocking

  initial begin
    #4.5 d = 1;
    @(step_ck);
    $display("%0d: step=%b unit=%b", $time, step_ck.d, unit_ck.d);
    #9.999 d = 0;
    @(step_ck);
    $display("%0d: step=%b unit=%b", $time, step_ck.d, unit_ck.d);
    $finish;
  end
endmodule

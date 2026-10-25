/*
:name: test_one_step_sample_before_time_slot
:description: A #1step input of a clocking block samples the value that the signal had immediately before the time slot of the clock edge, not a value written in the Active or NBA region of that slot (IEEE 1800-2023 Section 4.4.2.1)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.1 14.4 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_one_step_sample_before_time_slot.expected
*/
// IEEE 1800-2023 §4.4.2.1: #1step sampling takes the value immediately before
// the current time slot, as a sample in its Preponed region or in the
// Postponed region of the previous time slot. §14.4: a clocking block input
// with a skew of 1step is sampled that way at its clock event (§14.3).
// d becomes 7 at time 3. At time 5 one process writes d = 1 and then raises
// clk; the clocking block samples 7, the value before time 5. At time 15 the
// process raises clk and writes d <= 2, an NBA update of the same slot; the
// sample is 1. A process woken by the edge reads d directly and sees 1, the
// value written at time 5 before the edge. The values are printed one time
// unit after each edge.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns

module test_one_step_sample_before_time_slot;
  logic clk = 0;
  int d = 0, direct = -1;

  clocking cb @(posedge clk);
    default input #1step;
    input d;
  endclocking

  always @(posedge clk) direct = d;

  initial begin
    #3 d = 7;
    #2;
    d = 1;
    clk = 1;
    #1 $display("at 6: cb.d=%0d direct=%0d d=%0d", cb.d, direct, d);
    #4 clk = 0;
    #5;
    clk = 1;
    d <= 2;
    #1 $display("at 16: cb.d=%0d d=%0d", cb.d, d);
  end
endmodule

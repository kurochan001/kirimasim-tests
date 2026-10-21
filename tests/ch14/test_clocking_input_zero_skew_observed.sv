/*
:name: test_clocking_input_zero_skew_observed
:description: An input skew of zero samples in the Observed region of the clocking event, so it sees the nonblocking update made at that edge, which a skew of one unit misses (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_zero_skew_observed.expected
*/
// IEEE 1800-2023 §14.4: an input skew of #0 samples the clockvar in the
// Observed region of the time step of the clocking event, after the
// nonblocking assignments of that time step have updated their targets;
// a skew of #1 samples one time unit earlier.
// §14.13: the process that waits on the block reads those sampled values.
// d is incremented by a nonblocking assignment at each posedge, so at the
// edge at 5 the clockvar with #0 gets 1 and the one with #1 gets 0.

`timescale 1ns/1ns

module test_clocking_input_zero_skew_observed;
  logic clk = 0;
  logic [3:0] d = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  always_ff @(posedge clk) d <= d + 1;

  clocking cb @(posedge clk);
    input #0 at_edge = d;
    input #1 prev = d;
  endclocking

  initial begin
    @(cb);
    $display("%0d: at_edge=%0d prev=%0d d=%0d", $time, cb.at_edge, cb.prev, d);
    @(cb);
    $display("%0d: at_edge=%0d prev=%0d d=%0d", $time, cb.at_edge, cb.prev, d);
    $finish;
  end
endmodule

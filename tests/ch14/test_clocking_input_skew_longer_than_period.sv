/*
:name: test_clocking_input_skew_longer_than_period
:description: An input skew longer than the clock period samples in an earlier clock period, so blocks with skews 12 and 2 hold different values at the same edge (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_skew_longer_than_period.expected
*/
// IEEE 1800-2023 §14.4: the sample point of an input is the clocking event
// minus its skew, in the time unit of the block, and the skew may be longer
// than the clock period, so the sample point lies before the previous edge.
// §14.13: each block keeps its sampled value until its next event. The clock
// has a period of 10 and d changes at 2, 4, 14 and 16. At the edge at 15 the
// block with skew #12 samples at 3 and gets 1, and the block with skew #2
// samples at 13 and gets 2. At the edge at 25 they sample at 13 and at 23 and
// get 2 and 4.

`timescale 1ns/1ns

module test_clocking_input_skew_longer_than_period;
  logic clk = 0;
  logic [3:0] d = 0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25

  clocking far @(posedge clk);
    input #12 d;
  endclocking

  clocking near @(posedge clk);
    input #2 d;
  endclocking

  initial begin
    #2 d = 1;
    #2 d = 2;
    #10 d = 3;
    #2 d = 4;
  end

  initial begin
    @(far);
    @(far);
    $display("%0d: far=%0d near=%0d", $time, far.d, near.d);
    @(far);
    $display("%0d: far=%0d near=%0d", $time, far.d, near.d);
    $finish;
  end
endmodule

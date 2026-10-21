/*
:name: test_sched_flops_swap_values
:description: Two always_ff procedures that read each other's outputs swap their values at each edge without a race (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.2.2.4 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_flops_swap_values.expected
*/
// IEEE 1800-2023 §10.4.2: both flops read their right-hand sides at the edge
// before the NBA region (§4.4.2.4) updates either, so a and b exchange their
// values at each rising edge, whichever procedure runs first (§9.2.2.4).

`timescale 1ns/1ns

module test_sched_flops_swap_values;
  bit clk = 0;
  int a = 1, b = 2;

  always #5 clk = ~clk;
  always_ff @(posedge clk) a <= b;
  always_ff @(posedge clk) b <= a;

  initial begin
    repeat (3) #10 $display("%0t: a=%0d b=%0d", $time, a, b);
    $finish;
  end
endmodule

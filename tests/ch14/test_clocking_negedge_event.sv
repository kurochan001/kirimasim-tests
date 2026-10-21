/*
:name: test_clocking_negedge_event
:description: A clocking block on the negedge of a clock samples its input and drives its output at the falling edges (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_negedge_event.expected
*/
// IEEE 1800-2023 §14.3: the clocking event of a block is an event expression,
// here the negedge of clk, so the block has an event at 10 and at 20 and none
// at the rising edges. §14.4: the input is sampled one time unit before each
// falling edge, and a drive of the output with skew #2 matures two time
// units after it. §14.13: the waiting process reads the sampled input.
// d changes at 8.5 and at 18.5, so the block samples 1 at 10 and 0 at 20.

`timescale 1ns/1ns

module test_clocking_negedge_event;
  logic clk = 0;
  logic d = 0;
  logic q = 0;

  always #5 clk = ~clk;   // negedges at 10, 20

  clocking cb @(negedge clk);
    input #1 d;
    output #2 q;
  endclocking

  initial begin
    #8.5 d = 1;
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    cb.q <= 1;
    #3 $display("%0d: q=%b", $time, q);
    #5.5 d = 0;
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    $finish;
  end
endmodule

/*
:name: test_clocking_output_skew_cycle_delay
:description: A drive with a cycle delay matures at that later clocking event plus the output skew (IEEE 1800-2023 Sections 14.16.1, 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.1 14.4 14.11 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_output_skew_cycle_delay.expected
*/
// IEEE 1800-2023 §14.16.1: in a synchronous drive, an intra-assignment cycle
// delay ##1 moves the drive to the next clocking event, and §14.4: the output
// skew then delays the change of the signal after that event. §14.11, §14.12:
// a cycle delay counts clocking events of the default clocking. At the edge
// at 5 the block drives 1 at once and 0 with ##1; with the output skew #2 the
// signal becomes 1 at 7 and 0 at 17.

`timescale 1ns/1ns

module test_clocking_output_skew_cycle_delay;
  logic clk = 0;
  logic q = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  default clocking cb @(posedge clk);
    output #2 q;
  endclocking

  initial begin
    @(cb);
    cb.q <= 1;
    cb.q <= ##1 0;
    #1 $display("%0d: q=%b", $time, q);
    #2 $display("%0d: q=%b", $time, q);
    #8 $display("%0d: q=%b", $time, q);
    #2 $display("%0d: q=%b", $time, q);
    $finish;
  end
endmodule

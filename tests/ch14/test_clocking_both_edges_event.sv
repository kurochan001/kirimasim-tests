/*
:name: test_clocking_both_edges_event
:description: A clocking event without an edge, @(clk), occurs at every change of the clock, so the block samples and drives at both the rising and the falling edge (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_both_edges_event.expected
*/
// IEEE 1800-2023 §14.3: a clocking event is any event expression, and without
// an edge keyword @(clk) occurs at each change of clk, here at 5, 10, 15 and
// 20. §14.13: the input is sampled at each of those events, so a change of d
// between two events is seen at the next one. §14.16: a drive of the output,
// whose skew is #1, matures one time unit after its event.

`timescale 1ns/1ns

module test_clocking_both_edges_event;
  logic clk = 0;
  logic d = 0;
  logic q = 0;

  always #5 clk = ~clk;   // changes at 5, 10, 15, 20

  clocking cb @(clk);
    input d;
    output #1 q;
  endclocking

  initial begin
    #2 d = 1;
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    cb.q <= 1;
    #2 $display("%0d: q=%b", $time, q);
    #2 d = 0;
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    cb.q <= 0;
    #2 $display("%0d: q=%b", $time, q);
    $finish;
  end
endmodule

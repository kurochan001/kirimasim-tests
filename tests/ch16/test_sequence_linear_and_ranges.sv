/*
:name: test_sequence_linear_and_ranges
:description: A sequence matches along consecutive clock ticks; ##n waits n ticks, ##0 overlaps, a range ##[m:n] or ##[1:$] gives one match for each tick where the rest holds, and each end point is reported (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.7 16.14.3 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_linear_and_ranges.expected
*/
// IEEE 1800-2023 §16.7: a sequence is matched along consecutive clock ticks:
// ##1 moves one tick on, ##0 stays at the same tick, and a range ##[m:n] (or
// ##[1:$], with $ as an unbounded maximum) allows each later tick in it, so one
// attempt can have several matches. cover sequence (16.14.3) reports every
// match; each cover keeps the times of its end points. a is 1 at tick 1, b at
// ticks 2 and 4, c at tick 4. The ticks are the rising edges of clk at 5, 15,
// 25 and so on.

`timescale 1ns/1ns

module test_sequence_linear_and_ranges;
  logic clk = 0, a = 0, b = 0, c = 0;
  string linear = "", overlap = "", range = "", unbounded = "";

  always #5 clk = ~clk;

  initial begin
    a = 1;
    #10 a = 0; b = 1;
    #10 b = 0;
    #10 b = 1; c = 1;
    #10 b = 0; c = 0;
    #30;
    $display("a ##1 b ##2 b:%s", linear);
    $display("b ##0 c:%s", overlap);
    $display("a ##[1:3] b:%s", range);
    $display("a ##[1:$] c:%s", unbounded);
    $finish;
  end

  c_linear: cover sequence (@(posedge clk) a ##1 b ##2 b)
    linear = {linear, $sformatf(" %0t", $time)};
  c_overlap: cover sequence (@(posedge clk) b ##0 c)
    overlap = {overlap, $sformatf(" %0t", $time)};
  c_range: cover sequence (@(posedge clk) a ##[1:3] b)
    range = {range, $sformatf(" %0t", $time)};
  c_unbounded: cover sequence (@(posedge clk) a ##[1:$] c)
    unbounded = {unbounded, $sformatf(" %0t", $time)};
endmodule

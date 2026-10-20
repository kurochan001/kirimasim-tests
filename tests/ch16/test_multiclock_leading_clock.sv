/*
:name: test_multiclock_leading_clock
:description: A multiclocked sequence has the clock of its first part as its leading clock, and a property whose leading clocks are identical, as two subproperties on the same clock joined by and, has a unique leading clock (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.13.1 16.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multiclock_leading_clock.expected
*/
// IEEE 1800-2023 §16.16.1: the semantic leading clock of m1 ##1 m2 is that of
// m1, so a ##1 @(posedge clk2) b starts at the ticks of clk1 and, after a,
// waits for the next tick of clk2 (16.13.1). A property joined by and has the
// leading clocks of both sides, and it has a unique leading clock when they
// are identical, as here with clk1 on both sides. clk1 rises at 5, 15, 25 and
// so on, clk2 at 8, 18, 28 and so on. a is 1 at the clk1 ticks 15 and 35, b
// at the clk2 ticks 18 and 38 and at the clk1 tick 35.

`timescale 1ns/1ns

module test_multiclock_leading_clock;
  logic clk1 = 0, clk2 = 0, a = 0, b = 0;
  string two = "", same = "";

  always #5 clk1 = ~clk1;

  initial begin
    #3;
    forever #5 clk2 = ~clk2;
  end

  initial begin
    #10 a = 1;
    #6 b = 1;
    #4 a = 0; b = 0;
    #10 a = 1; b = 1;
    #10 a = 0; b = 0;
    #20;
    $display("a ##1 @(posedge clk2) b:%s", two);
    $display("a and b on clk1:%s", same);
    $finish;
  end

  c_two: cover property (@(posedge clk1) a ##1 @(posedge clk2) b)
    two = {two, $sformatf(" %0t", $time)};
  c_same: cover property (@(posedge clk1) a and @(posedge clk1) b)
    same = {same, $sformatf(" %0t", $time)};
endmodule

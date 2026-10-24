/*
:name: test_sampled_automatic_const_current
:description: in sampled value functions an automatic variable and a const cast give their current values, also for $past, while a static variable gives its sampled value of the past tick; $past can be called in a procedure with an automatic loop variable as index (IEEE 1800-2023 Section 16.5.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.1 16.9.3 16.14.6 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_automatic_const_current.expected
*/
// IEEE 1800-2023 §16.5.1: the sampled value of an automatic variable is its
// current value, and when a past value of it is referenced by a sampled value
// function the current value is taken instead. The sampled value of a const
// cast is the current value of its argument, also for a past value. §16.9.3:
// $past can be used in any expression and may refer to automatic variables,
// such as a loop variable: $past(b[i]) is bit i of the value of b sampled at
// the previous tick, and $past(i) is i. The always procedure is clocked by
// posedge clk, which gives the functions their clock (§16.14.6); b gets 0101
// at 2 and 0011 at 10, before the ticks at 5, 15 and 25, and b starts as 0,
// its default sampled value before the first tick. k becomes 3 at 15 just
// before the clock rises: a_c compares the current value const'(k) with the
// sampled k, so it fails only at 15; its action (§16.14.1) shows $sampled
// and $past of const'(k), both the current 3.

`timescale 1ns/1ns

module test_sampled_automatic_const_current;
  logic clk = 0;
  logic [3:0] b = 4'b0000;
  int k = 0;

  a_c: assert property (@(posedge clk) const'(k) == k) $display("t=%0t a_c pass", $time);
    else $display("t=%0t a_c fail: sampled k=%0d, const'(k) sampled %0d, past %0d", $time,
                  $sampled(k), $sampled(const'(k)), $past(const'(k)));

  always @(posedge clk) begin
    for (int i = 0; i < 4; i++)
      $display("t=%0t i=%0d: $past(b[i])=%b $past(i)=%0d", $time, i, $past(b[i]), $past(i));
  end

  initial begin
    #2 b = 4'b0101;
    #3 clk = 1;          // 5
    #5 clk = 0;
    b = 4'b0011;
    #5 k = 3;
    clk = 1;             // 15
    #5 clk = 0;
    #5 clk = 1;          // 25
    #5 $finish;
  end
endmodule

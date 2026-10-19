/*
:name: test_sampled_in_action_block
:description: In the action block of a concurrent assertion, which runs in the Reactive region, a variable gives its current value, already changed by a nonblocking assignment at the same clock tick, while $sampled gives the value the assertion checked (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.14.1 16.5.1 4.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_in_action_block.expected
*/
// IEEE 1800-2023 §16.9.3: $sampled returns the sampled value of its argument,
// which in an action block is the value the assertion itself used (16.5.1).
// At the tick at 5, a is 0 and b is 1 in the Preponed region, so a == b fails.
// The always procedure at that tick sets b to 0 with a nonblocking assignment,
// which takes effect in the NBA region, before the Reactive region in which
// the fail action runs (16.14.1, 4.4.2). So the action sees b as 0 but
// $sampled(b) as 1.

`timescale 1ns/1ns

module test_sampled_in_action_block;
  logic clk = 0, a = 0, b = 1;

  always #5 clk = ~clk;

  always @(posedge clk) b <= 1'b0;

  a1: assert property (@(posedge clk) a == b)
    else $display("%0d: current a=%b b=%b, sampled a=%b b=%b", $time, a, b,
                  $sampled(a), $sampled(b));

  initial #8 $finish;
endmodule

/*
:name: test_sampled_value_functions_with_clocking_event
:description: The value change and past sampled value functions take an expression and a clocking event as their last argument, and $past also takes an optional number of ticks and an optional gating expression that may be left empty; the clocking event samples the value at each of its occurrences, so $past gives the value of the previous tick and $stable says whether the value did not change (IEEE 1800-2023 Sections 16.9.3 and 16.9.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.9.1 A.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_value_functions_with_clocking_event.expected
*/
// IEEE 1800-2023 A.8.2: a system tf call can give an expression, further
// expressions that may be empty, and a clocking event as the last argument.
// §16.9.3: $past takes an expression, an optional number of ticks, an
// optional gating expression and an optional clocking event, and returns the
// sampled value of the expression the given number of ticks before,
// sampling at the clocking event that is given or that of the enclosing
// property. $stable(expression[, clocking_event]) returns true when the
// sampled value did not change at that event. An argument that is left empty
// takes its default, so the empty gating expression and number of ticks of
// $past below are the form with repeated optional expressions.
//
// a is 0 at the first posedge at time 5 and 1 from time 12, so at the posedge
// at time 15 $past(a, 1, , @(posedge clk)) is the value at time 5, 0, and
// $stable(a, @(posedge clk)) is false; at the posedge at time 25 both are 1
// because a was 1 at time 15 too.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports these arguments,
// so this expected output follows the standard.

`timescale 1ns/1ns

module test_sampled_value_functions_with_clocking_event;
  bit clk = 0, a = 0;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    if ($time == 15)
      $display("t15 past %0d stable %0d",
               $past(a, 1, , @(posedge clk)), $stable(a, @(posedge clk)));
    if ($time == 25)
      $display("t25 past %0d stable %0d",
               $past(a, 1, , @(posedge clk)), $stable(a, @(posedge clk)));
  end

  initial begin
    #12 a = 1;
    #18 $finish;
  end
endmodule

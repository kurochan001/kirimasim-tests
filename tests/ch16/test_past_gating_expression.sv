/*
:name: test_past_gating_expression
:description: $past with a gating expression returns the sampled value from the k-th earlier clock tick at which the gate was true, or the default sampled value when there are fewer such ticks (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.5.1 16.14.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_past_gating_expression.expected
*/
// IEEE 1800-2023 §16.9.3: $past(a, k, gate) returns the sampled value of a in
// the k-th strictly prior time step in which the clocking event occurred with
// gate true; if there are fewer than k such time steps, it returns the default
// sampled value of a, here 0 from its declaration (16.5.1). Without a gate
// every tick counts. a and gate change between ticks, so their values at a tick
// are the sampled values. At ticks 1 to 6, a is 1 to 6 and gate is 1, 0, 1, 0,
// 0, 1. The functions are called in an always procedure clocked by posedge clk,
// which gives them their clocking event (16.14.6).

`timescale 1ns/1ns

module test_past_gating_expression;
  logic clk = 0;
  int a = 0;
  bit gate = 0;
  int tick = 0;
  bit gates [6] = '{1, 0, 1, 0, 0, 1};

  always #5 clk = ~clk;   // ticks at 5, 15, ..., 55

  always @(posedge clk) begin
    tick++;
    $display("tick %0d: past1 %0d, gated past1 %0d, gated past2 %0d", tick,
             $past(a), $past(a, 1, gate), $past(a, 2, gate));
  end

  initial begin
    for (int k = 0; k < 6; k++) begin
      #1 a = k + 1;
      gate = gates[k];
      #9;
    end
    $finish;
  end
endmodule

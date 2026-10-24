/*
:name: test_let_sampled_value_clock_from_instance_context
:description: a sampled value function without a clock in a let body takes its clock from the place where the let is used, as if it were written there, so one let used in procedures clocked by two different clocks follows each clock (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 16.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_sampled_value_clock_from_instance_context.expected
*/
// IEEE 1800-2023 §11.12: when a let body calls a sampled value function
// without a clocking event, the clock is inferred where the let is used, in
// the same way as for a direct call there. §16.9.3: a call in a procedure
// uses the clock inferred from the procedure, here the event control of an
// always procedure (§16.14.6).
// ra = $rose(a) is used in a procedure clocked by clk1 and in one clocked by
// clk2, next to a direct call of $rose(a). The edges are clk2 at 5, 15 and
// 25 and clk1 at 10, 20 and 30; a is 1 from 12 to 17 and again from 22. With
// clk2, a rose between 5 and 15 but not between 15 and 25; with clk1 it did
// not rise between 10 and 20 but did between 20 and 30. Using one clock for
// both procedures would change the line at 25 or the one at 30. The first
// edge of each clock is not printed.
// Icarus Verilog 13.0 does not support let declarations.

`timescale 1ns/1ns

module test_let_sampled_value_clock_from_instance_context;
  logic clk1 = 0, clk2 = 0, a = 0;
  let ra = $rose(a);

  always @(posedge clk1)
    if ($time > 11) $display("t=%0t clk1: let %b direct %b", $time, ra, $rose(a));

  always @(posedge clk2)
    if ($time > 6) $display("t=%0t clk2: let %b direct %b", $time, ra, $rose(a));

  initial begin
    #5 clk2 = 1;
    #1 clk2 = 0;
    #4 clk1 = 1;
    #1 clk1 = 0;
    #1 a = 1;
    #3 clk2 = 1;
    #1 clk2 = 0;
    #1 a = 0;
    #3 clk1 = 1;
    #1 clk1 = 0;
    #1 a = 1;
    #3 clk2 = 1;
    #1 clk2 = 0;
    #4 clk1 = 1;
    #1 clk1 = 0;
    #1 $finish;
  end
endmodule

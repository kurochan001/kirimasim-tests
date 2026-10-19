/*
:name: test_checker_always_ff_sampled
:description: In a checker always_ff procedure the expressions use their sampled values, so a change in the time step of the clock event is not seen (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5 17.7 17.7.1 17.2 16.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_ff_sampled.expected
*/
// IEEE 1800-2023 §17.5: in an always_ff procedure of a checker, every
// expression other than the event control uses its sampled value (16.5.1), the
// value from before the time step. §17.7, §17.7.1: a checker variable can be
// initialized in its declaration and is written in always_ff with nonblocking
// assignments. §17.2: an event can be passed to a formal argument of type
// event. So when sig changes in the same time step as the clock edge, the
// checker still counts the old value. A final procedure prints the count.

`timescale 1ns/1ns

checker ones_at_edges(logic sig, event clk);
  int ones = 0;
  int edges = 0;
  always_ff @(clk) begin
    ones <= ones + sig;
    edges <= edges + 1;
  end
  final $display("edges=%0d ones=%0d", edges, ones);
endchecker

module test_checker_always_ff_sampled;
  logic clk = 0;
  logic sig = 0;

  ones_at_edges c1(sig, posedge clk);

  initial begin
    #5 sig = 1;
    #5 clk = 1;            // 10: sig was 1 before the edge: counted
    #5 clk = 0;
    #5 sig = 0; clk = 1;   // 20: sig was still 1 before this time step: counted
    #5 clk = 0;
    #5 clk = 1;            // 30: sig is 0: not counted
    #5 clk = 0;
    #5 sig = 1; clk = 1;   // 40: sig was 0 before this time step: not counted
    #5 clk = 0;
  end
endmodule

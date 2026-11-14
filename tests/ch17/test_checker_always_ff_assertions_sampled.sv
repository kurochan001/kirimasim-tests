/*
:name: test_checker_always_ff_assertions_sampled
:description: In a checker always_ff procedure the immediate assertion, the observed and final deferred assertions and the nonblocking assignment all use the sampled value of an input that changes in the time step of the clock edge, while the clock of the event control is used with its current value (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_ff_assertions_sampled.expected
*/
// IEEE 1800-2023 §17.5: in an always_ff procedure of a checker every
// expression is sampled (16.5.1), except the variables used in the event
// control, which keep their current values; so the expressions of immediate
// and deferred assertions written in the procedure are sampled too.
// The module sets b and then raises clk in the same time step, at 10 and at
// 20: b becomes 1 at 10 and 0 at 20, so its sampled value is 0 at the edge at
// 10 and 1 at the edge at 20, the value from before each time step. clk is in
// the event control: its current value at each edge is 1, while its sampled
// value would be 0. In each time step of an edge the immediate assertions
// run in the Active region in their order, the action of the observed
// deferred assertion in the Reactive region and that of the final deferred
// assertion in the Postponed region (16.4.1), so the four lines of an edge
// come in that order. hist collects the sampled b of the two edges, oldest
// first, and clks adds the current clk at each edge; the final procedure of
// the checker prints both at the end. With the current value of b each line
// of b would show the other value and hist would be 10; with the sampled
// value of clk the clk lines would show 0 and clks would be 0.
// Icarus Verilog 13.0 does not support checkers. The 5.054 release of
// the Verilator simulator uses the current value of b in this procedure: its
// b lines show 1 at the first edge and 0 at the second, and it prints
// hist=10.

`timescale 1ns/1ns

checker ff_sampling(input logic clk, input logic b);
  logic [1:0] hist = 2'b00;
  int clks = 0;
  always_ff @(posedge clk) begin
    hist <= {hist[0], b};
    clks <= clks + clk;
    a_imm: assert (b) $display("immediate assert (b): 1");
      else $display("immediate assert (b): 0");
    a_clk: assert (clk) $display("immediate assert (clk): 1");
      else $display("immediate assert (clk): 0");
    a_obs: assert #0 (b) $display("assert #0 (b): 1");
      else $display("assert #0 (b): 0");
    a_fin: assert final (b) $display("assert final (b): 1");
      else $display("assert final (b): 0");
  end
  final $display("hist=%b clks=%0d", hist, clks);
endchecker

module test_checker_always_ff_assertions_sampled;
  logic clk = 0;
  logic b = 0;

  ff_sampling u(clk, b);

  initial begin
    #10 b = 1; clk = 1;   // edge at 10: b was 0 before this time step
    #5 clk = 0;
    #5 b = 0; clk = 1;    // edge at 20: b was 1 before this time step
    #5 clk = 0;
  end
endmodule

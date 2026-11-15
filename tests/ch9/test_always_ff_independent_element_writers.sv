/*
:name: test_always_ff_independent_element_writers
:description: One element of an unpacked array may be written by an always_ff procedure while another element is written by a continuous assignment, since the longest static prefixes of the writes do not overlap, and each element follows its own writer (IEEE 1800-2023 Section 9.2.2.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_ff_independent_element_writers.expected
*/
// IEEE 1800-2023 §9.2.2.4: the variables assigned in an always_ff have the
// same restrictions on writes by other processes as those of an always_comb
// (§9.2.2.2), and §9.2.2.2 allows writes to independent elements of a
// variable as long as their longest static prefixes (§11.5.3) do not
// overlap. The always_ff writes mem[0] on each rising edge of clk, and a
// continuous assignment writes mem[1]; the prefixes mem[0] and mem[1] do
// not overlap, so the design is legal. A tool that took the whole of mem as
// the target of the always_ff would reject it.
// - t2: after the rising edge at time 1, mem[0] = d = 1, and
//   mem[1] = s + 100 = 102.
// - t3: d became 7 and s became 9 at time 2; mem[1] follows s at once
//   (109), while mem[0] keeps 1 until the next rising edge.
// - t5: after the rising edge at time 4, mem[0] = 7; mem[1] stays 109.

`timescale 1ns/1ns

module test_always_ff_independent_element_writers;
  logic clk = 1'b0;
  logic [7:0] d = 8'd1, s = 8'd2;
  logic [7:0] mem [0:1];

  always_ff @(posedge clk) mem[0] <= d;
  assign mem[1] = s + 8'd100;

  initial begin
    #1 clk = 1'b1;
    #1 $display("t2 mem=%0d,%0d", mem[0], mem[1]);
    d = 8'd7;
    s = 8'd9;
    #1 $display("t3 mem=%0d,%0d", mem[0], mem[1]);
    clk = 1'b0;
    #1 clk = 1'b1;
    #1 $display("t5 mem=%0d,%0d", mem[0], mem[1]);
  end
endmodule

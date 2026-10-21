/*
:name: test_checker_generate_state
:description: Each iteration of a generate loop elaborates its own checker instance with its own initialized checker variable, and the instances count the bits of a vector independently (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.7 17.7.1 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_generate_state.expected
*/
// IEEE 1800-2023 §17.3: a checker may be instantiated in a generate block, and
// "one copy of these contents exists for each instantiation", so each of the
// three iterations has its own checker variable count. §17.7: the variable is
// initialized in its declaration and keeps its value between the sampled clock
// edges. The generator loop connects bit i of v to instance i, which counts the
// edges at which that bit is 1: v is 101, 110, 001 and 111 at the four edges.

`timescale 1ns/1ns

checker chk_count(input logic sig, input logic clk, output int n);
  int count = 0;
  always_ff @(posedge clk) count <= count + sig;
  assign n = count;
endchecker

module test_checker_generate_state;
  logic clk = 0;
  logic [2:0] v = 3'b000;
  int hits[3];

  always #5 clk = ~clk;

  genvar i;
  generate
    for (i = 0; i < 3; i++) begin : g
      chk_count c(.sig(v[i]), .clk(clk), .n(hits[i]));
    end
  endgenerate

  initial begin
    v = 3'b101;          // sampled at 5
    #6 v = 3'b110;       // sampled at 15
    #10 v = 3'b001;      // sampled at 25
    #10 v = 3'b111;      // sampled at 35
    #10 $display("hits=%0d %0d %0d", hits[0], hits[1], hits[2]);
    $finish;
  end
endmodule

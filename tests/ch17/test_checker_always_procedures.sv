/*
:name: test_checker_always_procedures
:description: always_comb, always_latch and always_ff procedures in one checker use current values, hold a latch and sample at the clock, and drive their outputs (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5 17.7.1 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_procedures.expected
*/
// IEEE 1800-2023 §17.5: a checker may hold always_comb, always_latch and
// always_ff procedures. Expressions in always_comb and always_latch use their
// current values, so y_comb follows a and b at once and the latch takes a
// while en is 1 and holds it after en falls. In always_ff every expression but
// the event control is sampled at the clock edge, so count adds the value of
// (a | b) from before the edge. §17.7.1: the checker variable count is
// initialized in its declaration and assigned only by nonblocking assignments
// in always_ff. §17.2: the outputs carry these values to module variables.

`timescale 1ns/1ns

checker chk_procedures(input logic a, input logic b, input logic en, input logic clk,
                       output logic y_comb, output logic y_latch, output int y_ff);
  logic held = 1'b0;
  int count = 0;
  always_comb y_comb = a & b;
  always_latch if (en) held = a;
  always_ff @(posedge clk) count <= count + (a | b);
  assign y_latch = held;
  assign y_ff = count;
endchecker

module test_checker_always_procedures;
  logic a = 0, b = 0, en = 0, clk = 0;
  logic y_comb, y_latch;
  int y_ff;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25

  chk_procedures c(.a(a), .b(b), .en(en), .clk(clk),
                   .y_comb(y_comb), .y_latch(y_latch), .y_ff(y_ff));

  initial begin
    #1 a = 1;
    #1 $display("%0d: comb=%b latch=%b ff=%0d", $time, y_comb, y_latch, y_ff);
    en = 1;
    #1 b = 1;
    #3 $display("%0d: comb=%b latch=%b ff=%0d", $time, y_comb, y_latch, y_ff);
    en = 0;
    a = 0;
    #2 $display("%0d: comb=%b latch=%b ff=%0d", $time, y_comb, y_latch, y_ff);
    a = 1;
    #8 $display("%0d: comb=%b latch=%b ff=%0d", $time, y_comb, y_latch, y_ff);
    $finish;
  end
endmodule

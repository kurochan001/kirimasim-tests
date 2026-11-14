/*
:name: test_specify_path_forms_scalar_vector_combinations
:description: A specify block holds simple, edge-sensitive and state-dependent module path declarations, and simple paths connect a scalar to a scalar, a vector to a scalar, a scalar to a vector and a vector to a vector, each delaying its destination by its own delay (IEEE 1800-2023 Section 30.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_path_forms_scalar_vector_combinations.expected
*/
// IEEE 1800-2023 §30.4: a module path declaration in a specify block is a
// simple path, an edge-sensitive path or a state-dependent path, and module
// paths can connect any combination of vectors and scalars.
//
// The cell has one destination per path:
//   (a => y1) = 20      scalar a to scalar y1, y1 = a
//   (v *> y2) = 30      vector v to scalar y2, y2 = v[1] ^ v[0]
//   (a *> y3) = 40      scalar a to vector y3, y3 = {a, a}
//   (v => y4) = 50      vector v to vector y4, y4 = v
//   (posedge clk => (q +: a)) = 60     edge-sensitive, q loads a at posedge
//   if (s) (a => r) = 70; if (!s) (a => r) = 90;   state-dependent, r = a
// a rises at 100 (s is 1): y1 at 120, y3 at 140 and r at 170. clk rises at
// 200: q rises at 260. v becomes 01 at 300: y2 at 330, y4 at 350. s falls at
// 400, which changes no output. a falls at 500: y1 at 520, y3 at 540 and r,
// now with s 0, at 590. v becomes 11 at 600: y2 falls at 630, y4 at 650.
// clk falls at 700 and rises at 800: q falls at 860.
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs. The 5.054
// release of Verilator ignores module path delays.

`timescale 1ns/1ns

module test_specify_path_forms_scalar_vector_combinations_cell
  (input clk, input s, input a, input [1:0] v, output y1, output y2,
   output [1:0] y3, output [1:0] y4, output q, output r);
  reg qi = 0;

  always @(posedge clk) qi <= a;

  buf g1 (y1, a);
  xor g2 (y2, v[1], v[0]);
  buf g31 (y3[1], a);
  buf g30 (y3[0], a);
  buf g41 (y4[1], v[1]);
  buf g40 (y4[0], v[0]);
  buf gq (q, qi);
  buf gr (r, a);

  specify
    (a => y1) = 20;
    (v *> y2) = 30;
    (a *> y3) = 40;
    (v => y4) = 50;
    (posedge clk => (q +: a)) = 60;
    if (s) (a => r) = 70;
    if (!s) (a => r) = 90;
  endspecify
endmodule

module test_specify_path_forms_scalar_vector_combinations;
  reg clk = 0, s = 1, a = 0;
  reg [1:0] v = 2'b00;
  wire y1, y2, q, r;
  wire [1:0] y3, y4;
  logic [7:0] prev;

  test_specify_path_forms_scalar_vector_combinations_cell u
    (.clk(clk), .s(s), .a(a), .v(v), .y1(y1), .y2(y2), .y3(y3), .y4(y4),
     .q(q), .r(r));

  initial begin
    #100 a = 1;
    #100 clk = 1;
    #100 v = 2'b01;
    #100 s = 0;
    #100 a = 0;
    #100 v = 2'b11;
    #100 clk = 0;
    #100 clk = 1;
  end

  initial begin
    #95 prev = {y1, y2, y3, y4, q, r};
    repeat (80) begin
      #10 if ({y1, y2, y3, y4, q, r} != prev)
        $display("%0d: y1=%b y2=%b y3=%b y4=%b q=%b r=%b", $time - 5, y1, y2, y3, y4, q, r);
      prev = {y1, y2, y3, y4, q, r};
    end
    $finish;
  end
endmodule

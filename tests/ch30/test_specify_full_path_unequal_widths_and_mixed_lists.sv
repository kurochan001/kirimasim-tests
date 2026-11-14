/*
:name: test_specify_full_path_unequal_widths_and_mixed_lists
:description: A full connection path connects every bit of its source to every bit of its destination when their widths differ, and one full path declaration with lists of scalar and vector sources and destinations makes a path from each source to each destination (IEEE 1800-2023 Sections 30.4.5 and 30.4.6)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.5 30.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_full_path_unequal_widths_and_mixed_lists.expected
*/
// IEEE 1800-2023 §30.4.5: with *> every bit of the source connects to every
// bit of the destination, and the two need not have the same width.
// §30.4.6: a comma-separated list of sources joined by *> to a list of
// destinations, which may mix scalars and vectors of any size, declares a
// full path from each source to each destination. A two-value delay gives
// the rise and the fall delay of each destination bit (30.5.1).
//
// The cell fw has (a *> y) = (20, 50) from the 3-bit a to the 2-bit y, with
// y[0] = ^a and y[1] = ~^a, so a change of any bit of a makes one bit of y
// rise and the other fall. a goes 000 -> 100 at 100 (y[0] rises at 120,
// y[1] falls at 150), 100 -> 101 at 200 (y[1] rises at 220, y[0] falls at
// 250) and 101 -> 111 at 300 (y[0] rises at 320, y[1] falls at 350): each of
// a[2], a[0] and a[1] reaches both bits of y.
// The cell ml has (s, v *> p, w) = (30, 60) from the scalar s and the 2-bit v
// to the scalar p and the 3-bit w, with p and every bit of w equal to
// s ^ v[1] ^ v[0]. s rises at 400 (p and w rise at 430), v[1] rises at 500
// (they fall at 560) and v[0] rises at 600 (they rise at 630).
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs.
//
// Icarus Verilog 13.0 says that it uses the delay of the LSB for every bit
// of a multi-bit destination, so both bits of y change at 120, 250 and 320.
// The 5.054 release of Verilator ignores module path delays.

`timescale 1ns/1ns

module test_specify_full_path_unequal_widths_and_mixed_lists_fw
  (input [2:0] a, output [1:0] y);
  xor g0 (y[0], a[2], a[1], a[0]);
  xnor g1 (y[1], a[2], a[1], a[0]);
  specify
    (a *> y) = (20, 50);
  endspecify
endmodule

module test_specify_full_path_unequal_widths_and_mixed_lists_ml
  (input s, input [1:0] v, output p, output [2:0] w);
  xor gp (p, s, v[1], v[0]);
  xor g2 (w[2], s, v[1], v[0]);
  xor g1 (w[1], s, v[1], v[0]);
  xor g0 (w[0], s, v[1], v[0]);
  specify
    (s, v *> p, w) = (30, 60);
  endspecify
endmodule

module test_specify_full_path_unequal_widths_and_mixed_lists;
  reg [2:0] a = 3'b000;
  reg s = 0;
  reg [1:0] v = 2'b00;
  wire [1:0] y;
  wire p;
  wire [2:0] w;
  logic [5:0] prev;

  test_specify_full_path_unequal_widths_and_mixed_lists_fw ufw (a, y);
  test_specify_full_path_unequal_widths_and_mixed_lists_ml uml (s, v, p, w);

  initial begin
    #100 a = 3'b100;
    #100 a = 3'b101;
    #100 a = 3'b111;
    #100 s = 1;
    #100 v[1] = 1;
    #100 v[0] = 1;
  end

  initial begin
    #95 prev = {y, p, w};
    repeat (60) begin
      #10 if ({y, p, w} != prev) $display("%0d: y=%b p=%b w=%b", $time - 5, y, p, w);
      prev = {y, p, w};
    end
    $finish;
  end
endmodule

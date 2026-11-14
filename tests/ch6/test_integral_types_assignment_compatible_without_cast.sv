/*
:name: test_integral_types_assignment_compatible_without_cast
:description: Integral types of different widths, signedness and numbers of states are assigned to each other without a cast, and each assignment gives the converted value, truncated, zero- or sign-extended, or with unknown bits made zero (IEEE 1800-2023 Section 6.22.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.3 6.11.2 10.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_integral_types_assignment_compatible_without_cast.expected
*/
// IEEE 1800-2023 §6.22.3 makes all integral types assignment compatible with
// each other, so none of the assignments below needs a cast; the conversion
// can lose data by truncation. The values follow the conversion rules:
// §10.7 pads a narrower right-hand side by its own signedness (zero-extended
// if unsigned, sign-extended if signed) and truncates the most significant
// bits of a wider one, and §6.11.2 turns unknown and high-impedance bits into
// zeros when a 4-state value goes to a 2-state type.
//
// Width: 300 keeps its low byte 8'h2c = 44 in a byte; -200 is 32'hffffff38
// and keeps 8'h38 = 56; 64'sh1_0000_0005 keeps 5 in an int; the integer
// 70000 = 32'h0001_1170 keeps 16'h1170 = 4464 in a shortint.
// Signedness: the byte -3 is sign-extended, to -3 in an int and to
// 16'hfffd = 65533 in bit [15:0]; bit [7:0] 8'hf0 has the same bits in a
// byte, -16; the shortint -1 is sign-extended to 4294967295 in an
// int unsigned.
// Number of states: logic 4'b1x0z becomes 4'b1000 in bit [3:0]; bit 4'b1010
// is zero-extended to 8'b00001010 in logic [7:0]; logic signed [7:0] -5 is
// sign-extended to 12'hffb = 4091 in bit [11:0].
//
// An implementation that required a cast between some of these types would
// reject the design. One that kept the value of the source type, chose the
// extension by the signedness of the target, or kept x or z in a 2-state
// variable would change the corresponding value.

module test_integral_types_assignment_compatible_without_cast;
  int i300 = 300;
  int in200 = -200;
  longint big = 64'sh1_0000_0005;
  integer i70000 = 70000;
  byte bm3 = -3;
  bit [7:0] u8 = 8'hf0;
  shortint sm1 = -1;
  logic [3:0] l4 = 4'b1x0z;
  bit [3:0] k4 = 4'b1010;
  logic signed [7:0] ls = -8'sd5;

  byte b1, b2, s8;
  int w1, w2;
  shortint s16;
  bit [15:0] u16;
  int unsigned iu;
  bit [3:0] t4;
  logic [7:0] l8;
  bit [11:0] u12;

  initial begin
    #1;
    b1 = i300;
    b2 = in200;
    w1 = big;
    s16 = i70000;
    w2 = bm3;
    u16 = bm3;
    s8 = u8;
    iu = sm1;
    t4 = l4;
    l8 = k4;
    u12 = ls;
    $display("width: %0d %0d %0d %0d", b1, b2, w1, s16);
    $display("signedness: %0d %0d %0d %0d", w2, u16, s8, iu);
    $display("states: %b %b %0d", t4, l8, u12);
  end
endmodule

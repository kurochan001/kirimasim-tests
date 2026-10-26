/*
:name: test_specify_simple_path_declarations_and_terminals
:description: A simple path declaration uses => for a parallel connection or *> for a full connection, with an optional polarity operator and lists of input and output terminals that name input, output and inout ports and their bit and part selects, and each path delays the destination by its rise or fall delay (IEEE 1800-2023 Sections 30.4.2, 30.4.5 and 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.2 30.4.5 30.5.1 A.7.2 A.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_simple_path_declarations_and_terminals.expected
*/
// IEEE 1800-2023 §30.4.2, Syntax 30-3: a simple path declaration is a
// parallel path description, which connects one input terminal to one output
// terminal with =>, or a full path description, which connects a list of
// input terminals to a list of output terminals with *>, followed by = and a
// path delay value. A.7.2 gives the same productions, with an optional
// polarity_operator before => or *>. A.7.3 defines the terminal lists: one or
// more comma-separated specify terminal descriptors, each an input, output or
// inout port identifier with an optional [constant_range_expression].
// §30.4.5: => connects each source bit to the corresponding destination bit,
// while *> connects every source bit to every destination bit; §30.5.1: a
// two-value delay gives the rise and fall delays.
//
// The cell par has the parallel path (a + => y) with the rise and fall delays
// 2 and 4; a[1] rises, a[0] rises and a[1] falls one at a time, so y follows
// 2 after a rise and 4 after a fall. The cell full has the full path
// (b, c - *> y1, y2) with the delays 3 and 5; y1 = b & c and y2 = b | c, so a
// change of either input reaches both outputs, 3 after a rise and 5 after a
// fall. The cell sel connects the part-select d[3:2] to q[3:2] with 1 and the
// scalar s to o with 2, so each selected bit arrives 1 later. The cell io
// uses the inout port io as the destination of (a => io) and the source of
// (io => y), so a rise of a reaches io 3 later and y 4 after that.
//
// Icarus Verilog 13.0 applies a part-select path to the whole vector, which
// gives the same output because only d[3] and d[2] change; Verilator 5.052
// ignores module path delays, so it does not produce this output.

`timescale 1ns/1ns

module sp_par (input wire [1:0] a, output wire [1:0] y);
  buf g0 (y[0], a[0]);
  buf g1 (y[1], a[1]);
  specify
    (a + => y) = (2, 4);
  endspecify
endmodule

module sp_full (input wire b, input wire c, output wire y1, output wire y2);
  and g1 (y1, b, c);
  or g2 (y2, b, c);
  specify
    (b, c - *> y1, y2) = (3, 5);
  endspecify
endmodule

module sp_sel (input wire [3:0] d, input wire s, output wire [3:0] q,
               output wire o);
  buf g3 (q[3], d[3]);
  buf g2 (q[2], d[2]);
  buf g1 (q[1], d[1]);
  buf g0 (q[0], d[0]);
  buf gs (o, s);
  specify
    (d[3:2] => q[3:2]) = 1;
    (s => o) = 2;
  endspecify
endmodule

module sp_io (input wire a, inout wire io, output wire y);
  buf gi (io, a);
  buf go (y, io);
  specify
    (a => io) = 3;
    (io => y) = 4;
  endspecify
endmodule

module test_specify_simple_path_declarations_and_terminals;
  reg [1:0] a = 2'b00;
  wire [1:0] y;
  reg b = 1'b0, c = 1'b0;
  wire y1, y2;
  reg [3:0] d = 4'b0000;
  reg s = 1'b0;
  wire [3:0] q;
  wire o;
  reg ia = 1'b0;
  wire iio, iy;

  sp_par u_par (a, y);
  sp_full u_full (.b(b), .c(c), .y1(y1), .y2(y2));
  sp_sel u_sel (.d(d), .s(s), .q(q), .o(o));
  sp_io u_io (.a(ia), .io(iio), .y(iy));

  initial begin
    #10 a = 2'b10;                              // y[1] rises at 12
    #1  $display("t=%0t par y=%b", $time, y);   // 11
    #2  $display("t=%0t par y=%b", $time, y);   // 13
    #7  a = 2'b11;                              // 20: y[0] rises at 22
    #1  $display("t=%0t par y=%b", $time, y);   // 21
    #2  $display("t=%0t par y=%b", $time, y);   // 23
    #7  a = 2'b01;                              // 30: y[1] falls at 34
    #1  $display("t=%0t par y=%b", $time, y);   // 31
    #4  $display("t=%0t par y=%b", $time, y);   // 35
    #5  b = 1'b1;                               // 40: y2 rises at 43
    #1  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #3  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #6  c = 1'b1;                               // 50: y1 rises at 53
    #1  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #3  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #6  b = 1'b0;                               // 60: y1 falls at 65
    #1  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #5  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #5  c = 1'b0;                               // 71: y2 falls at 76
    #1  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #5  $display("t=%0t full y1=%b y2=%b", $time, y1, y2);
    #4  d[3] = 1'b1;                            // 81: q[3] at 82
    #2  $display("t=%0t sel q=%b o=%b", $time, q, o);
    #8  s = 1'b1;                               // 91: o at 93
    #1  $display("t=%0t sel q=%b o=%b", $time, q, o);
    #2  $display("t=%0t sel q=%b o=%b", $time, q, o);
    #7  d[2] = 1'b1;                            // 101: q[2] at 102
    #2  $display("t=%0t sel q=%b o=%b", $time, q, o);
    #8  d = 4'b0000;                            // 111: q at 112
    #2  $display("t=%0t sel q=%b o=%b", $time, q, o);
    #8  ia = 1'b1;                              // 121: io at 124, y at 128
    #2  $display("t=%0t io io=%b y=%b", $time, iio, iy);
    #2  $display("t=%0t io io=%b y=%b", $time, iio, iy);
    #4  $display("t=%0t io io=%b y=%b", $time, iio, iy);
    #10 $finish;
  end
endmodule

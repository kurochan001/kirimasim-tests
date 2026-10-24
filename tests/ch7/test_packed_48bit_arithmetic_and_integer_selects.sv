/*
:name: test_packed_48bit_arithmetic_and_integer_selects
:description: a 48-bit packed vector does integer arithmetic at 48 bits, and the integer types with a predefined width can be selected from as if declared [n-1:0] (IEEE 1800-2023 Sections 7.4.1, 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_48bit_arithmetic_and_integer_selects.expected
*/
// IEEE 1800-2023 §7.4.1: packed arrays give integers of any length, so a
// 48-bit vector does 48-bit arithmetic: results wrap at 2**48, not at 32 or
// 64 bits, and products above 2**32 are kept. The integer types with a
// predefined width n (byte, shortint, int, longint, integer, time) are not
// packed arrays, but they can be selected from as if they were declared with
// the single dimension [n-1:0]; §7.4.5: such selections number the bits down
// to 0. The test reads and writes bit-selects and part-selects of each type,
// with constant and variable positions; a part-select is unsigned, so the
// part-select of the whole byte widens to 254 while the byte itself is -2.

module test_packed_48bit_arithmetic_and_integer_selects;
  bit [47:0] a, b, p;
  bit signed [47:0] s;
  byte by;
  shortint sh;
  int k, w, idx;
  longint lg;
  integer ig;
  time tm;

  initial begin
    a = 48'hffff_ffff_ffff;
    a = a + 48'd1;
    b = 48'h0001_0000;
    p = b * b;
    $display("48-bit: max+1=%h 2**16*2**16=%h", a, p);
    p = 48'h0000_ffff_ffff * 48'h0000_0001_0001;
    $display("48-bit: (2**32-1)*(2**16+1)=%h", p);
    s = -48'sd5;
    $display("48-bit signed: s/2=%0d s>>>1=%0d top>max31=%0d", s / 2, s >>> 1,
             48'h8000_0000_0000 > 48'h7fff_ffff_ffff);

    by = -8'sd2;
    sh = 16'h8001;
    k = 32'h1234_5678;
    lg = 64'h8000_0000_0000_0001;
    ig = 32'hdead_beef;
    tm = 64'd1000;
    $display("byte: [0]=%b [7:1]=%h", by[0], by[7:1]);
    $display("shortint: [15]=%b [14:0]=%h", sh[15], sh[14:0]);
    $display("int: [31:28]=%h [7:0]=%h [3]=%b [0]=%b", k[31:28], k[7:0], k[3], k[0]);
    $display("longint: [63]=%b [63:60]=%h [3:0]=%h", lg[63], lg[63:60], lg[3:0]);
    $display("integer: [15:0]=%h [31:16]=%h", ig[15:0], ig[31:16]);
    $display("time: [9:3]=%h", tm[9:3]);
    idx = 28;
    $display("int variable select: k[idx]=%b k[idx+:4]=%h", k[idx], k[idx+:4]);
    k[15:8] = 8'hab;
    by[7] = 1'b0;
    lg[62:61] = 2'b11;
    $display("after writes: k=%h by=%0d lg=%h", k, by, lg);
    by = -8'sd2;
    w = by[7:0];
    k = by;
    $display("byte widened: part-select=%0d whole=%0d", w, k);
  end
endmodule

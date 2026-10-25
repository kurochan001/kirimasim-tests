/*
:name: test_primary_literal_forms_number_time_unbased_string
:description: A primary literal is a number in binary, octal, decimal or hexadecimal with underscores and a sign, a time literal whose number is followed directly by the unit, an unbased unsized literal whose apostrophe is followed directly by 0 or 1, or a string literal; each gives its value, its width and, for a delay in time units, the time (IEEE 1800-2023 Sections 5.7.1, 5.7.2, 5.8 and 5.9, footnotes 49 and 53 of A.10)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 5.7.2 5.8 5.9 A.8.4 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_primary_literal_forms_number_time_unbased_string.expected
*/
// IEEE 1800-2023 A.8.4: a primary literal is a number, a time literal, an
// unbased unsized literal or a string literal, and the primary can be such a
// literal. §5.7.1: a sized number gives its value in the base of its digits
// and may hold underscores; a signed number keeps its sign. §5.7.2: an
// unbased unsized literal is an apostrophe and 0, 1, x or z, and takes the
// width of its context, so '1 is all ones and '0 is all zeros. Footnote 53 of
// A.10: the apostrophe is followed directly by the digit. §5.8: a time
// literal is an unsigned number or a fixed-point number followed directly by
// a time unit, which footnote 49 of A.10 also requires; #10ns is a delay of
// ten nanoseconds, which is 10 time units with a unit of 1ns. §5.9: a string
// literal is a packed array of bytes, so "abc" has 24 bits and three
// characters. The escaped name \$bits is a user variable, so it is not the
// system function $bits.
//
// 8'b1010_1010, 8'o252 and 8'd170 and 8'hAA all give 8'hAA, and 8'sh80 is
// -128. m1 = '1 is all ones, which is -1 as an int. Icarus Verilog 13.0
// and the 5.052 release of Verilator produce this output.

`timescale 1ns/1ps

module test_primary_literal_forms_number_time_unbased_string;
  logic [7:0] ones = '1;
  logic [7:0] zeros = '0;
  int m1 = '1;
  logic [7:0] a = 8'b1010_1010;
  logic [7:0] b = 8'o252;
  logic [7:0] c = 8'd170;
  logic [7:0] d = 8'hAA;
  logic signed [7:0] s = 8'sh80;
  string str = "abc";
  int \$bits = 3;

  initial begin
    $display("unbased %h %h %0d", ones, zeros, m1);
    $display("number %h %h %h %h %0d", a, b, c, d, s);
    $display("string %s %0d", str, str.len());
    $display("bits %0d %0d", $bits("abc"), $bits(8'hAA));
    $display("sys %0d %0d", $bits("ab"), \$bits );
    #10ns $display("time %0d", $time);
  end
endmodule

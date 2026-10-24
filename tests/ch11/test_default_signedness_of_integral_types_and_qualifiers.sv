/*
:name: test_default_signedness_of_integral_types_and_qualifiers
:description: byte, shortint, int, integer and longint are signed by default, the other integral types unsigned, and the signed and unsigned qualifiers of variables and nets change that (IEEE 1800-2023 Section 11.4.3.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_signedness_of_integral_types_and_qualifiers.expected
*/
// IEEE 1800-2023 §11.4.3.1: variables of type byte, shortint, int, integer
// and longint are signed unless declared otherwise; bit, logic, reg and time
// variables and nets are unsigned unless declared signed. Both variables and
// nets can be declared signed or unsigned explicitly.
// Every operand holds all ones. Compared with the signed 0, a signed operand
// is -1 and less than 0, and %0d prints -1; an unsigned one is the largest
// value of its width and not less than 0. The default and the qualified forms
// of each kind of type are compared side by side.

module test_default_signedness_of_integral_types_and_qualifiers;
  byte by = '1;
  shortint sh = '1;
  int in = '1;
  integer ig = '1;
  longint lo = '1;
  bit [7:0] bt = '1;
  logic [7:0] lg = '1;
  reg [7:0] rg = '1;
  time tm = '1;
  byte unsigned byu = '1;
  int unsigned inu = '1;
  bit signed [7:0] bts = '1;
  logic signed [7:0] lgs = '1;
  reg signed [7:0] rgs = '1;
  wire [7:0] wu = '1;
  wire signed [7:0] ws = '1;

  initial begin
    #1;
    $display("signed by default: %0d %0d %0d %0d %0d", by < 0, sh < 0, in < 0, ig < 0, lo < 0);
    $display("values: %0d %0d %0d %0d %0d", by, sh, in, ig, lo);
    $display("unsigned by default: %0d %0d %0d %0d %0d", bt < 0, lg < 0, rg < 0, tm < 0, wu < 0);
    $display("values: %0d %0d %0d %0d %0d", bt, lg, rg, tm, wu);
    $display("unsigned qualifier: %0d %0d values %0d %0d", byu < 0, inu < 0, byu, inu);
    $display("signed qualifier: %0d %0d %0d %0d values %0d %0d %0d %0d", bts < 0, lgs < 0,
             rgs < 0, ws < 0, bts, lgs, rgs, ws);
  end
endmodule

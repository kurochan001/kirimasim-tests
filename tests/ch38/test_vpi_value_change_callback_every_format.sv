/*
:name: test_vpi_value_change_callback_every_format
:description: A cbValueChange callback registered with each value format of Table 38-5 gets the new value in that format, binary, octal, decimal and hex strings, scalar, integer, real, string, time, vector and strength values, with vpiObjTypeVal in the format of the object, and with vpiSuppressVal no value (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.15
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_value_change_callback_every_format.c
:expected_stdout: @test_vpi_value_change_callback_every_format.expected
*/
// IEEE 1800-2023 §38.36.1: the value format given at the registration of a
// simulation event callback is one of the formats of Table 38-5, or
// vpiSuppressVal when no value is needed, and the value passed to the
// callback routine is set as that format asks. Table 38-5 has the binary,
// octal, decimal and hex strings, vpiScalarVal, vpiIntVal, vpiRealVal,
// vpiStringVal, vpiTimeVal (two integers), vpiVectorVal (aval/bval),
// vpiStrengthVal (value and strength of a scalar) and vpiObjTypeVal, which
// gives the value in the format closest to the object: as 38.15 lists them,
// vpiIntVal for an integer, vpiRealVal for a real, vpiTimeVal of the type
// vpiSimTime for a time variable and vpiVectorVal for a vector.
//
// At time 1 the application places one cbValueChange callback with
// vpiSimTime on each variable below, and on the net sw, which a continuous
// assignment of pull strength drives; each registration has its own format.
// From time 10 on, one object changes in each time unit. Each callback
// prints the time, the format it asked for, the format it got and the value:
// strings as they are, the scalar code, the integer, the real with two
// decimals, the two time words, the aval and bval words (the top word only
// in the bits of the vector), and for sw the logic value and the strength of
// its 1 component. With vpiSuppressVal, no value means a NULL value or one
// of the format vpiSuppressVal. The release 13.0 of Icarus Verilog rejects
// the vpiTimeVal and vpiStrengthVal formats for these callbacks, leaves
// vpiObjTypeVal unconverted for an integer and a vector, and stops with a
// signal; the 5.054 release of Verilator stops at the registrations. The
// expected output follows the clauses.

`timescale 1ns/1ns

module test_vpi_value_change_callback_every_format;
  logic [3:0] b4 = 0;
  logic [5:0] o6 = 0;
  logic [7:0] d8 = 0;
  logic [11:0] h12 = 0;
  logic s = 0;
  int i32 = 0;
  real r = 0.0;
  logic [23:0] str = 0;
  time t64 = 0;
  logic [35:0] v36 = 0;
  logic sd = 0;
  wire sw;
  integer oi = 0;
  real ro = 0.0;
  time ot = 0;
  logic [7:0] ov = 0;
  int sp = 0;

  assign (pull0, pull1) sw = sd;

  initial begin
    #10 b4 = 4'b1x0z;
    #1 o6 = 6'o57;
    #1 d8 = 8'd200;
    #1 h12 = 12'ha5f;
    #1 s = 1'b1;
    #1 i32 = -7;
    #1 r = 2.75;
    #1 str = "xyz";
    #1 t64 = 64'h0000_0002_0000_0003;
    #1 v36 = {4'b1z0x, 32'h8000_0001};
    #1 sd = 1'b1;
    #1 oi = 12;
    #1 ro = -0.5;
    #1 ot = 64'd9;
    #1 ov = 8'b10xz_0011;
    #1 sp = 3;
    #1 $finish;
  end
endmodule

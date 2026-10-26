/*
:name: test_vpi_put_value_formats
:description: vpi_put_value writes a variable, a vector and a real from the vpiBinStrVal, vpiOctStrVal, vpiDecStrVal, vpiHexStrVal, vpiScalarVal, vpiIntVal, vpiRealVal, vpiStringVal and vpiVectorVal formats, with the value structure, its pointed-to storage and the delay structure allocated by the application (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_formats.c
:expected_stdout: @test_vpi_put_value_formats.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value sets the value of an object from an
// s_vpi_value that the application allocates, together with any storage that
// the value union points to, and from an s_vpi_time that the application
// allocates when a delay mode needs it. The formats are those of Table 38-3
// (38.15): binary, octal, decimal and hexadecimal strings, a scalar value, an
// integer, a real, an ASCII string, and aval/bval words.
//
// At time 1 the application writes b as "1011", o as "17", d as "42", h as
// "3f", sc as vpi1, i as -5, r as 2.5, st as the characters "AB", and vec
// from the two words 0x89abcdef and 0x12, all with vpiNoDelay. The design
// prints the results at time 1.

`timescale 1ns/1ns

module test_vpi_put_value_formats;
  logic [3:0] b;
  logic [5:0] o;
  logic [7:0] d;
  logic [7:0] h;
  logic sc;
  int i;
  real r;
  logic [15:0] st;
  logic [39:0] vec;

  initial begin
    #1 $vt_put;
    #1 $display("b=%b o=%0o d=%0d h=%h sc=%b i=%0d r=%0.1f st=%h vec=%h",
                b, o, d, h, sc, i, r, st, vec);
    $finish;
  end
endmodule

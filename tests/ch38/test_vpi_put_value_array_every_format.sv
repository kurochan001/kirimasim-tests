/*
:name: test_vpi_put_value_array_every_format
:description: vpi_put_value_array takes the values of contiguous array elements in the layout its format selects, for each of the formats vpiIntVal, vpiVectorVal, vpiTimeVal, vpiRealVal, vpiRawFourStateVal, vpiRawTwoStateVal, vpiShortIntVal, vpiLongIntVal and vpiShortRealVal (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_put_value_array_every_format.c
:expected_stdout: @test_vpi_put_value_array_every_format.expected
*/
// IEEE 1800-2023 §38.35: the format field of the s_vpi_arrayvalue given to
// vpi_put_value_array selects how the values of the elements are laid out.
// Besides vpiIntVal (32-bit integers), vpiVectorVal (A/B word pairs, as many
// pairs per element as it has started 32-bit words), vpiTimeVal (s_vpi_time
// structures) and vpiRealVal (doubles), the formats vpiRawFourStateVal
// (for each element its aval bytes, then its bval bytes, as many bytes as it
// has started 8-bit groups, bit 0 in the low bit of the first byte),
// vpiRawTwoStateVal (the aval bytes alone), vpiShortIntVal (16-bit
// integers), vpiLongIntVal (64-bit integers) and vpiShortRealVal (floats) can
// be used.
//
// At time 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application writes the two elements of nine static arrays
// from index 0, each with one of these formats and with values that differ
// between the elements and between the bytes or words of one element; the
// vector and raw four-state values have x and z bits. The design prints the
// arrays at time 2. The release 13.0 of Icarus Verilog has no
// vpi_put_value_array, and the 5.054 release of Verilator stops at the
// vpiTimeVal format, so the expected output follows the clause alone.

`timescale 1ns/1ns

module test_vpi_put_value_array_every_format;
  int ia [0:1];
  logic [39:0] va [0:1];
  time ta [0:1];
  real ra [0:1];
  shortreal sra [0:1];
  logic [11:0] r4 [0:1];
  bit [11:0] r2 [0:1];
  shortint sa [0:1];
  longint la [0:1];

  initial begin
    #2;
    $display("ia: %0d %0d", ia[0], ia[1]);
    $display("va: %h %h", va[0], va[1]);
    $display("ta: %0d %0d", ta[0], ta[1]);
    $display("ra: %.2f %.2f", ra[0], ra[1]);
    $display("sra: %.2f %.2f", sra[0], sra[1]);
    $display("r4: %h %h", r4[0], r4[1]);
    $display("r2: %h %h", r2[0], r2[1]);
    $display("sa: %0d %0d", sa[0], sa[1]);
    $display("la: %0d %0d", la[0], la[1]);
    $finish;
  end
endmodule

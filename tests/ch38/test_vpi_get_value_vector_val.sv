/*
:name: test_vpi_get_value_vector_val
:description: vpi_get_value with vpiVectorVal gives one aval/bval pair per 32 bits, from the least significant bit, with 0, 1, x and z coded 00, 10, 11 and 01 (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_get_value_vector_val.c
:expected_stdout: @test_vpi_get_value_vector_val.expected
*/
// IEEE 1800-2023 §38.15 (Figure 38-8, Table 38-3): with vpiVectorVal,
// value.vector points to ((size - 1) / 32 + 1) s_vpi_vecval structures; the
// least significant bit of element 0 is bit 0 of the object and the least
// significant bit of element 1 its bit 32. Each bit is coded by the pair
// (aval bit, bval bit): 0 as (0,0), 1 as (1,0), x as (1,1) and z as (0,1).
// The 40-bit w has 0, 1, x and z in bits 0 to 3 and again in bits 32 to 35,
// and 1 in bits 31 and 39; the 32-bit v has x in bit 31 and z in bit 0. The
// application reads them in a cbAfterDelay callback at 1 (38.36.2),
// registered at the start of the simulation (38.36.3), and prints the words
// in hex; the bits of element 1 of w above bit 39 are left out.

`timescale 1ns/1ns

module test_vpi_get_value_vector_val;
  logic [39:0] w;
  logic [31:0] v;

  initial begin
    w = 40'b1000_zx10_1000_0000_0000_0000_0000_0000_0000_zx10;
    v = 32'bx000_0000_0000_0000_0000_0000_0101_101z;
    #2 $finish;
  end
endmodule

/*
:name: test_vpi_get_value_strength
:description: vpi_get_value with vpiStrengthVal gives the logic value as vpi0, vpi1, vpiX or vpiZ and the drive strength of a net as an Annex K strength constant, one s_vpi_strengthval per bit, and always strong for a variable (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 28.11 38.36.2 38.36.3 K.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_get_value_strength.c
:expected_stdout: @test_vpi_get_value_strength.expected
*/
// IEEE 1800-2023 §38.15 (Table 38-3, Figure 38-9): with vpiStrengthVal,
// value.strength points to an array of s_vpi_strengthval structures, at least
// one per bit of the object, each with the logic value (vpi0, vpi1, vpiX or
// vpiZ) in logic and the strengths of the 0 and 1 parts in s0 and s1, coded
// as in Annex K (vpiSupplyDrive, vpiStrongDrive, vpiPullDrive, vpiWeakDrive,
// ...). For a variable the strength is always strong. The nets wk, pl and sp
// are driven with weak 1, pull 0 and supply 1 strength (28.11), nz only by
// the z of dz and nx by two strong drivers of opposite values; rv is a 4-bit
// variable. The application reads them in a cbAfterDelay callback at 1
// (38.36.2), registered at the start of the simulation (38.36.3), and prints
// the logic value and, for 0 or 1, the strength of that part. For rv it
// counts the first 4 elements by value and strength, so the order of the
// elements does not matter.

`timescale 1ns/1ns

module test_vpi_get_value_strength;
  wire (weak0, weak1) wk = 1'b1;
  wire (pull0, pull1) pl = 1'b0;
  supply1 sp;
  wire nz;
  wire nx;
  logic [3:0] rv;
  logic dz;

  assign nz = dz;
  assign nx = 1'b0;
  assign nx = 1'b1;

  initial begin
    rv = 4'b1101;
    dz = 1'bz;
    #2 $finish;
  end
endmodule

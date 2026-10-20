/*
:name: test_vpi_constant_select
:description: vpiConstantSelect is true for a var select or bit-select whose indices are elaboration-time constants and false for one with a variable index (IEEE 1800-2023 Section 37.19)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.19 37.58 37.75
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_constant_select.c
:expected_stdout: @test_vpi_constant_select.expected
*/
// IEEE 1800-2023 §37.19: vpiConstantSelect is TRUE for a var select when all
// its index expressions are elaboration-time constants, its parent array has
// static bounds and the property holds for the parent. §37.58: the same holds
// for a bit-select of a vector. The right-hand sides of the continuous
// assignments (37.75) are m[2] and m[i], selects of an unpacked array, and v[3]
// and v[i], bit-selects. The lines are sorted by the name of the target.

`timescale 1ns/1ns

module test_vpi_constant_select;
  logic [7:0] v = 8'b1010_0110;
  int m [0:3] = '{10, 20, 30, 40};
  int i = 1;
  int c1, c2;
  logic d1, d2;

  assign c1 = m[2];
  assign c2 = m[i];
  assign d1 = v[3];
  assign d2 = v[i];

  initial #1 $vt_selects;
endmodule

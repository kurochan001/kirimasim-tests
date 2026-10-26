/*
:name: test_vpi_interconnect_array_ranges
:description: An interconnect array iterates its range declarations and gives the left and right bounds of that range as expressions (IEEE 1800-2023 Section 37.24)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.24 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interconnect_array_ranges.c
:expected_stdout: @test_vpi_interconnect_array_ranges.expected
*/
// IEEE 1800-2023 §37.24: an interconnect array has a one-to-many relation to
// range with the untagged range access type (37.24 diagram, detail 2), and a
// one-to-one relation to an expression with each of the tags vpiLeftRange and
// vpiRightRange. The two arrays are declared with a descending range [2:0]
// and an ascending range [1:4] (6.6.8), so the bound expressions are read and
// their values printed.

`timescale 1ns/1ns

module test_vpi_interconnect_array_ranges;
  interconnect ia [2:0];
  interconnect ib [1:4];

  initial #1 $vt_icrange;
endmodule

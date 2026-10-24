/*
:name: test_vpi_handle_by_multi_index
:description: vpi_handle_by_multi_index creates a handle to the element of a two-dimensional array that its indices select, leftmost index first, optionally followed by a bit-select index (IEEE 1800-2023 Section 37.2.1)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.1 38.20 38.34
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_by_multi_index.c
:expected_stdout: @test_vpi_handle_by_multi_index.expected
*/
// IEEE 1800-2023 §37.2.1: vpi_handle_by_multi_index creates a handle to an
// indexed subobject of a multidimensional object. §38.20: the indices are
// given leftmost dimension first and may be followed by a bit-select index.
// At the start of the simulation the application gets m[1][2] with the
// indices {1, 2}, prints its full name and writes 42 to it (38.34); it gets
// bit 5 of bv[1] with {1, 5} and writes 1 to it. At 1 the design prints
// m[1][2], m[2][1], which the indices in the other order would select, and
// bv[1]. The vpi_user.h of Icarus Verilog 13.0 does not declare
// vpi_handle_by_multi_index, so the application does not build there.

`timescale 1ns/1ns

module test_vpi_handle_by_multi_index;
  int m [0:2][3:0];
  bit [7:0] bv [0:3];

  initial #1 $display("m[1][2]=%0d m[2][1]=%0d bv[1]=%b", m[1][2], m[2][1], bv[1]);
endmodule

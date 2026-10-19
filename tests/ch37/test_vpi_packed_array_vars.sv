/*
:name: test_vpi_packed_array_vars
:description: a packed array of packed structs is a packed array variable whose size is its number of bits; vpiElement gives its elements, struct variables that are packed array members with the array as parent and their index, and the array can be read as a whole (IEEE 1800-2023 Section 37.18)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.18 37.17 37.26 7.4.1 7.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_packed_array_vars.c
:expected_stdout: @test_vpi_packed_array_vars.expected
*/
// IEEE 1800-2023 §37.18: a packed array (§7.4.1) of packed structs (§7.2.1)
// is a vpiPackedArrayVar; vpiPacked and vpiVector are true (detail 1) and
// vpiSize is its number of bits, 3 x 8 (detail 2). vpiElement iterates its
// elements one dimension at a time (detail 3), here three vpiStructVar
// objects; vpiPackedArrayMember is true for each (detail 4), vpiParent is the
// array, and vpiIndex iterates their index (detail 6). The value of the whole
// array is that of its bits. Elements are printed sorted by name.

`timescale 1ns/1ns

module test_vpi_packed_array_vars;
  typedef struct packed {
    logic [3:0] hi, lo;
  } pair_t;

  pair_t [2:0] pav = {8'h12, 8'h34, 8'h56};

  initial #1 $vt_packed;
endmodule

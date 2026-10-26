/*
:name: test_vpi_cont_assign_rhs_and_load
:description: A continuous assignment gives its right-hand expression with vpiRhs and its left-hand net with vpiLhs, and the bit of another continuous assignment that reads one bit of a vector net is the load of that net bit (IEEE 1800-2023 Sections 37.47 and 37.46)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.47 37.46 10.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_cont_assign_rhs_and_load.c
:expected_stdout: @test_vpi_cont_assign_rhs_and_load.expected
*/
// IEEE 1800-2023 §37.47: a continuous assignment reaches its right-hand
// expression with vpiRhs and its left-hand expression with vpiLhs; it iterates
// its bits with vpiBit, and a bit has vpiOffset (zero for the LSB) and a
// scalar size (detail 1 and 3). The assignment assign o = wv[1] & a has the
// operation wv[1] & a as its right-hand side, whose decompilation is fixed by
// §37.59 and whose value at time 1 is 1. §37.46: the net loads group includes
// the bit of a continuous assignment, so the load set of the net bit wv[1]
// contains the bit of that assignment, found here by comparing the handles
// with vpi_compare_objects.

module test_vpi_cont_assign_rhs_and_load;
  logic a = 1'b1, b = 1'b1;
  wire [1:0] wv;
  wire o;

  assign wv = {a, b};
  assign o = wv[1] & a;

  initial #1 $vt_ca;
endmodule

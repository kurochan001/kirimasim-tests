/*
:name: test_vpi_variable_driver_load_kinds
:description: A scalar variable written by a continuous assignment has that assignment as its driver and as its cont assign, one read by a continuous assignment has it as its load, and a variable connected to an input terminal of a gate iterates that primitive terminal (IEEE 1800-2023 Sections 37.17 and 37.21)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.21 37.47 37.35 10.3.2 28.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_driver_load_kinds.c
:expected_stdout: @test_vpi_variable_driver_load_kinds.expected
*/
// IEEE 1800-2023 §37.17 and §37.21: a variable iterates its drivers with
// vpiDriver and its loads with vpiLoad; a continuous assignment belongs to both
// groups. A variable also iterates the continuous assignments and the
// primitive terminals connected to it. The scalar variable v1 is written only
// by a continuous assignment (10.3.2), whose vpiLhs (37.47) is v1: it is the
// one driver of v1 and its one cont assign, and v1 has no loads. v2 is read
// only by a continuous assignment, whose vpiRhs is v2: that is its one load,
// and it has no drivers (its initializer is not a driver). v3 is connected to
// the input terminal 1 of the and gate g1 (28.4; terminals 37.35, numbered
// from 0), a to its terminal 2; v4 is connected to nothing and has no driver,
// cont assign or terminal. A terminal found from a variable is compared with
// the one found from g1. The variables are scalars, so no bit objects are
// involved.

module test_vpi_variable_driver_load_kinds;
  logic a = 1'b1, b = 1'b0;
  logic v1;
  logic v2 = 1'b1;
  logic v3 = 1'b0;
  logic v4 = 1'b1;
  wire w1, w2;

  assign v1 = a & b;
  assign w1 = v2;
  and g1 (w2, v3, a);

  initial #1 $vt_dl;
endmodule

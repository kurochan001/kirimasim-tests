/*
:name: test_vpi_ref_obj_actual
:description: The low connection of a ref port is a ref obj with the name of the port, and vpiActual gives the variable it refers to (IEEE 1800-2023 Section 37.15)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.15 37.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_ref_obj_actual.c
:expected_stdout: @test_vpi_ref_obj_actual.expected
*/
// IEEE 1800-2023 §37.15: a ref obj stands for a declaration that refers to an
// object instantiated elsewhere, such as the low connection of a ref port. It
// is reached by walking port connections (37.14), its name is that of its
// declaration, and vpiActual returns the actual object it is bound to. u has
// the ref port r bound to v, which u increments at 1; at 2 the actual reads 10.

`timescale 1ns/1ns

module test_vpi_ref_obj_actual_user (ref int r);
  initial #1 r = r + 1;
endmodule

module test_vpi_ref_obj_actual;
  int v = 9;

  test_vpi_ref_obj_actual_user u(v);

  initial #2 $vt_ref;
endmodule

/*
:name: test_vpi_variable_drivers_loads
:description: vpiDrivers and vpiLoads of a structure variable include the drivers and loads of its members (IEEE 1800-2023 Section 37.21)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.21 37.75
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_drivers_loads.c
:expected_stdout: @test_vpi_variable_drivers_loads.expected
*/
// IEEE 1800-2023 §37.21: the drivers and loads of a structure, union or class
// variable include those of the whole variable, of its selects and of any
// member nested in it. s is driven only through its members a and b, by two
// continuous assignments (37.75), and read through b by a third.

`timescale 1ns/1ns

module test_vpi_variable_drivers_loads;
  typedef struct {
    int a;
    int b;
  } pair_t;

  pair_t s;
  int x = 1, y = 2, z;

  assign s.a = x;
  assign s.b = y;
  assign z = s.b;

  initial #1 $vt_dl;
endmodule

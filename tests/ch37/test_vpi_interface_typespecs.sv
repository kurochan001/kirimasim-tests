/*
:name: test_vpi_interface_typespecs
:description: An interface typespec for a modport has the modport as its vpiDefName and the interface typespec as its vpiParent; one for an interface has the interface name and no parent (IEEE 1800-2023 Section 37.30)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.30 37.29
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_typespecs.c
:expected_stdout: @test_vpi_interface_typespecs.expected
*/
// IEEE 1800-2023 §37.30: the vpiDefName of an interface typespec is the name of
// the interface, or of the modport when it represents a modport, and vpiParent
// of a modport typespec returns the typespec of its interface, while that of an
// interface typespec is NULL. The vpiTypedef iteration of the module returns
// the typedefs bus_t and phy_t. The lines are sorted by name.

`timescale 1ns/1ns

interface test_vpi_interface_typespecs_bus;
  logic r;
  modport phy (input r);
endinterface

module test_vpi_interface_typespecs;
  typedef virtual test_vpi_interface_typespecs_bus bus_t;
  typedef virtual test_vpi_interface_typespecs_bus.phy phy_t;

  test_vpi_interface_typespecs_bus b1();

  initial #1 $vt_typespecs;
endmodule

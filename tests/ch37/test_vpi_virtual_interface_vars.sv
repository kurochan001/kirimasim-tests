/*
:name: test_vpi_virtual_interface_vars
:description: vpiExpr of a virtual interface variable gives the interface instance of its declaration or NULL, vpiActual the instance it holds now, and vpiIsModPort whether it names a modport (IEEE 1800-2023 Section 37.29)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.29 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_virtual_interface_vars.c
:expected_stdout: @test_vpi_virtual_interface_vars.expected
*/
// IEEE 1800-2023 §37.29: the vpiVirtualInterfaceVar iteration of a module
// returns its virtual interface variables (25.9). vpiExpr returns the interface
// instance assigned in the declaration, or NULL; vpiActual returns the
// interface the variable refers to when it is asked, and vpiIsModPort tells
// whether its type names a modport. v_init is set in its declaration, v_late by
// an assignment at 0, and v_mp is never set. The lines are sorted by name.

`timescale 1ns/1ns

interface test_vpi_virtual_interface_vars_bus;
  logic r;
  modport phy (input r);
endinterface

module test_vpi_virtual_interface_vars;
  test_vpi_virtual_interface_vars_bus b1();
  virtual test_vpi_virtual_interface_vars_bus v_init = b1;
  virtual test_vpi_virtual_interface_vars_bus v_late;
  virtual test_vpi_virtual_interface_vars_bus.phy v_mp;

  initial begin
    v_late = b1;
    #1 $vt_vif;
  end
endmodule

/*
:name: test_vpi_virtual_interface_var_iteration
:description: vpi_iterate(vpiVirtualInterfaceVar) of a module gives a scalar virtual interface variable and each element of an array of them, each with the module as its scope, while vpiVariables gives the array as one array variable (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 37.17 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_virtual_interface_var_iteration.c
:expected_stdout: @test_vpi_virtual_interface_var_iteration.expected
*/
// IEEE 1800-2023 §37.12: a scope has a one-to-many relation to its virtual
// interface variables and each has a one-to-one relation, vpiScope, back to
// it. When the scope declares an array of virtual interfaces, the
// vpiVirtualInterfaceVar iteration gives each element of the array separately,
// while the vpiVariables iteration gives the array declaration as a single
// vpiArrayVar (detail 7). §37.17: virtual interface var is a member of the
// variables group. The module declares the virtual interface variable vs and
// the two-element array va (25.9), and no other variable, so the first
// iteration gives vs, va[0] and va[1], and vpiVariables gives va and vs. The
// application prints the names sorted, with their types.

interface vii_if;
  logic s;
endinterface

module test_vpi_virtual_interface_var_iteration;
  vii_if i0();
  vii_if i1();
  virtual vii_if vs;
  virtual vii_if va [2];

  initial begin
    vs = i0;
    va[0] = i0;
    va[1] = i1;
    #1 $vt_vifs;
  end
endmodule

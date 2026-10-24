/*
:name: test_vpi_virtual_interface_init_parent
:description: vpiExpr of a virtual interface variable gives the interface instance of its declaration or a NULL handle when it has no initializer, and its vpiFullName is its hierarchical name; a param assign of an interface typespec leads back to that typespec; vpiParent of a modport interface typespec is the interface typespec of its interface, and that of an interface typespec is a NULL handle (IEEE 1800-2023 Sections 37.29 and 37.30)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.29 37.30 37.12 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_virtual_interface_init_parent.c
:expected_stdout: @test_vpi_virtual_interface_init_parent.expected
*/
// IEEE 1800-2023 §37.29: a virtual interface var has vpiName and vpiFullName,
// and vpiExpr (detail 1) gives the interface instance assigned in its
// declaration, here the interface b1 for vi_init, or NULL when there is none
// (vi_none and vi_blk, the latter declared in the named block blk, whose full
// name contains it). The application prints NULL only for a NULL handle.
// §37.30: an interface typespec iterates its param assigns, and a param assign
// leads with vpiInterfaceTypespec to the interface typespec it belongs to (the
// typedef v4_t sets W to 4, detail 3; typedefs come from the vpiTypedef
// iteration of the module, 37.12). Detail 2: vpiParent of the modport typespec
// mp_t gives the interface typespec of its interface (not a modport, def name
// of the interface), and vpiParent of the interface typespec v4_t is NULL.

interface test_vpi_virtual_interface_init_parent_if #(parameter int W = 2);
  logic [W-1:0] r;
  modport mp (input r);
endinterface

module test_vpi_virtual_interface_init_parent;
  typedef virtual test_vpi_virtual_interface_init_parent_if #(.W(4)) v4_t;
  typedef virtual test_vpi_virtual_interface_init_parent_if.mp mp_t;

  test_vpi_virtual_interface_init_parent_if b1();
  virtual test_vpi_virtual_interface_init_parent_if vi_init = b1;
  virtual test_vpi_virtual_interface_init_parent_if vi_none;

  initial begin : blk
    virtual test_vpi_virtual_interface_init_parent_if vi_blk;
    #1 $vt_vif;
  end
endmodule

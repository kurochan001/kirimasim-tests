/*
:name: test_vpi_virtual_interface_expr
:description: vpiExpr of a virtual interface variable gives the interface instance assigned in its declaration and NULL without one, while an assignment to a virtual interface has a virtual interface variable or a null constant as its right-hand expression (IEEE 1800-2023 Section 37.29)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.29 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_virtual_interface_expr.c
:expected_stdout: @test_vpi_virtual_interface_expr.expected
*/
// IEEE 1800-2023 §37.29: the vpiExpr relation of a virtual interface variable
// gives the interface instance assigned in its declaration, or NULL when it
// has none (detail 1). The interface expression group includes a virtual
// interface variable and a constant, which may be an interface expression only
// if its vpiConstType is vpiNullConst (detail 2); the example shows that the
// right-hand side of an assignment to a virtual interface is a virtual
// interface variable. The test initializes one virtual interface with an
// interface instance, leaves one uninitialized, and gives a never-called task
// two assignments, one from null and one from another virtual interface
// variable; the application prints the declaration expressions and the kind of
// each assignment's right-hand expression.

interface vi_if;
  logic v;
endinterface

module test_vpi_virtual_interface_expr;
  vi_if b ();
  virtual vi_if v0;
  virtual vi_if v1 = b;
  virtual vi_if v2;

  task sets;
    v0 = null;
    v2 = v1;
  endtask

  initial #1 $vt_vif;
endmodule

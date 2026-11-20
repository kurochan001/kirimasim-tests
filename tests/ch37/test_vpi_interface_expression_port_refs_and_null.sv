/*
:name: test_vpi_interface_expression_port_refs_and_null
:description: Interface-expression references identify local interface and modport ports and their distinct actuals, while the null expression has vpiNullConst type
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.29 37.15 37.14 37.12 37.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_expression_port_refs_and_null.c
:expected_stdout: @test_vpi_interface_expression_port_refs_and_null.expected
*/
// IEEE 1800-2023 37.29 B007 detail 2 restricts reference-object interface
// expressions to local declarations passed through interface/modport ports,
// and constant interface expressions to vpiNullConst. In the never-called
// task, s and m are precisely those local port declarations (37.15 detail 1).
// The application compares each RHS with the corresponding port lowconn,
// then compares its vpiActual with the specific interface or modport bound at
// elaboration. Distinct instances make a shared or wrong actual observable.
// The null RHS is inspected as expression metadata; no null is dereferenced.

interface test_vpi_interface_expression_port_refs_and_null_bus;
  logic sig;
  modport mp(input sig);
endinterface

module test_vpi_interface_expression_port_refs_and_null_child(
  test_vpi_interface_expression_port_refs_and_null_bus s,
  test_vpi_interface_expression_port_refs_and_null_bus.mp m
);
  virtual test_vpi_interface_expression_port_refs_and_null_bus vi, vn;
  virtual test_vpi_interface_expression_port_refs_and_null_bus.mp vm;
  task sets;
    vi = s;
    vm = m;
    vn = null;
  endtask
endmodule

module test_vpi_interface_expression_port_refs_and_null;
  test_vpi_interface_expression_port_refs_and_null_bus left();
  test_vpi_interface_expression_port_refs_and_null_bus right();
  test_vpi_interface_expression_port_refs_and_null_child u(left, right.mp);
  initial #1 $vt_interface_refs;
endmodule

/*
:name: test_vpi_null_reference_relations
:description: Relations that start from a circle in the diagrams are traversed with NULL as the reference handle: vpi_handle(vpiSysTfCall, NULL) gives the system task call being executed, and vpi_iterate(vpiModule, NULL) and vpi_iterate(vpiUserSystf, NULL) give the top modules and the registered system tasks and functions (IEEE 1800-2023 Section 37.4.3)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.4.3 37.5 37.42
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_null_reference_relations.c
:expected_stdout: @test_vpi_null_reference_relations.expected
*/
// IEEE 1800-2023 §37.4.3: a relation that starts from a circle in a diagram
// has no reference object, and it is traversed with NULL as the reference
// handle: vpi_handle(Obj, NULL) for a single arrow, vpi_iterate(Obj, NULL)
// and vpi_scan for a double arrow.
//
// Single arrow: in 37.42 the arrow tagged vpiSysTfCall leads from a circle
// to the system task or function call, the call that invoked the
// application (detail 3). $vt_root is called twice, on lines 45 and 46 with
// the arguments 11 and 22; each time the application prints the name, line
// and argument of the call that vpi_handle(vpiSysTfCall, NULL) gives, and
// the name of its user systf (the single arrow from the call to user systf).
// Double arrows: in 37.5 a double arrow leads from a circle to module, the
// top modules: test_vpi_null_reference_relations and the module _other,
// which nothing instantiates (the module _leaf is instantiated); in 37.42 a
// double arrow leads from a circle to user systf, the registered system
// tasks and functions (detail 6): $vt_root and $vt_seven. Lists are sorted,
// and only the names that start with $vt_ are kept, since a tool can
// register system tasks of its own.

module test_vpi_null_reference_relations_leaf;
endmodule

module test_vpi_null_reference_relations_other;
endmodule

module test_vpi_null_reference_relations;
  int seven;

  test_vpi_null_reference_relations_leaf u();

  initial begin
    #1 $vt_root(11);
    #1 $vt_root(22);
    seven = $vt_seven;
    $display("$vt_seven returns %0d", seven);
  end
endmodule

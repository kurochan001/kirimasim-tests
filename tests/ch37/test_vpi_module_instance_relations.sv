/*
:name: test_vpi_module_instance_relations
:description: a module iterates the interfaces and the interface arrays it instantiates, vpiModule of each of them, of a module array and of a child module leads to the instance that holds it, an instance array iterates its elements, and an element leads to its array through vpiInstanceArray and vpiModuleArray (IEEE 1800-2023 Sections 37.5 and 37.6)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.6 37.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_instance_relations.c
:expected_stdout: @test_vpi_module_instance_relations.expected
*/
// IEEE 1800-2023 §37.5: a module has one-to-many relations to the
// interfaces (vpiInterface) and interface arrays (vpiInterfaceArray) it
// holds, each of which, like a child module and a module array, leads back
// to the module through the one-to-one relation vpiModule; a top-level
// module has no such parent. An instance array (§37.11) iterates its
// elements: vpi_iterate(vpiModule) for the module array la and, §37.6,
// vpi_iterate(vpiInterface) for the interface array ba; an element leads to
// its array through vpiInstanceArray and, for a module, vpiModuleArray, which
// give NULL for an instance that is not in an array. m1 and m2 are instances
// of a module holding the interfaces b1 and b2 and the module l1; a1 holds
// the arrays. The application prints each relation with the full name of the
// object it gives and whether that is the expected object; lists are sorted.
// The output is printed from a cbStartOfSimulation callback. The VPI headers
// of Icarus Verilog 13.0 lack the array constants used here, and the
// iterations of interfaces and arrays give no object in Verilator 5.052.

interface test_vpi_module_instance_relations_bus;
  logic v;
endinterface

module test_vpi_module_instance_relations_leaf;
endmodule

module test_vpi_module_instance_relations_mid;
  test_vpi_module_instance_relations_bus b1();
  test_vpi_module_instance_relations_bus b2();
  test_vpi_module_instance_relations_leaf l1();
endmodule

module test_vpi_module_instance_relations_arrs;
  test_vpi_module_instance_relations_bus ba [1:0] ();
  test_vpi_module_instance_relations_leaf la [2:0] ();
endmodule

module test_vpi_module_instance_relations;
  test_vpi_module_instance_relations_mid m1();
  test_vpi_module_instance_relations_mid m2();
  test_vpi_module_instance_relations_arrs a1();
endmodule

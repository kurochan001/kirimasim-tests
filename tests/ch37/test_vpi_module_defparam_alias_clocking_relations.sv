/*
:name: test_vpi_module_defparam_alias_clocking_relations
:description: a module iterates its defparam statements and its clocking blocks, and vpiModule of each of them and of its alias statements leads back to the instance that has it; a module without them iterates none (IEEE 1800-2023 Section 37.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.48 37.76 23.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_defparam_alias_clocking_relations.c
:expected_stdout: @test_vpi_module_defparam_alias_clocking_relations.expected
*/
// IEEE 1800-2023 §37.5: a module has one-to-many relations to its defparam
// statements (vpiDefParam), its alias statements (vpiAliasStmt) and its
// clocking blocks (vpiClockingBlock), and each of these has a one-to-one
// relation back to the module, vpi_handle(vpiModule). m1 and m2 are
// instances of a module that holds the defparam l.P = 5 (§23.10.1), which
// sets the parameter of its child l, the alias a = b and the clocking blocks
// cb1 and cb2 (§37.48). The application prints, for m1 and m2, each object,
// sorted (the defparam by the name of the parameter its vpiLhs gives, the
// alias by the names of vpiLhs and vpiRhs, §37.76), with the instance that
// vpiModule gives for it; the top module has none of these objects. The
// output is printed from a cbStartOfSimulation callback. Icarus Verilog 13.0
// does not parse the alias statement and the clocking blocks, and the
// iterations give no object in Verilator 5.052.

module test_vpi_module_defparam_alias_clocking_relations_leaf #(parameter int P = 1) ();
endmodule

module test_vpi_module_defparam_alias_clocking_relations_mid;
  logic clk;
  wire a, b;

  test_vpi_module_defparam_alias_clocking_relations_leaf l();
  defparam l.P = 5;

  alias a = b;

  clocking cb1 @(posedge clk);
  endclocking

  clocking cb2 @(negedge clk);
  endclocking
endmodule

module test_vpi_module_defparam_alias_clocking_relations;
  test_vpi_module_defparam_alias_clocking_relations_mid m1();
  test_vpi_module_defparam_alias_clocking_relations_mid m2();
endmodule

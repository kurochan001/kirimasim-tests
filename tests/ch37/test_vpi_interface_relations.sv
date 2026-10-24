/*
:name: test_vpi_interface_relations
:description: an interface gives its global clocking block and its default disable condition, iterates its clocking blocks and its interface arrays, and its clocking blocks, child interfaces and interface arrays lead back to it through vpiInstance (IEEE 1800-2023 Section 37.6)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.6 37.10 14.14 16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_relations.c
:expected_stdout: @test_vpi_interface_relations.expected
*/
// IEEE 1800-2023 §37.6: an interface has the one-to-one relations
// vpiGlobalClocking to its global clocking block (§14.14) and
// vpiDefaultDisableIff to the expression of its default disable iff
// (§16.15), and one-to-many relations to its clocking blocks
// (vpiClockingBlock) and to the interface arrays it holds
// (vpiInterfaceArray); its clocking blocks, the interfaces and the interface
// arrays it holds lead back to it through vpiInstance, the immediate
// instance in which they are declared (§37.10 detail 3). o1 and o2 are
// instances of an interface with a global clocking block gck, a default
// disable iff on rst, a child interface n1 and an interface array na; c1 is
// an instance of an interface with the clocking blocks cb1 and cb2, and p an
// instance of an interface with neither. The application prints each
// relation with the names it gives and whether vpiInstance gives the
// expected interface; lists are sorted. The output is printed from a
// cbStartOfSimulation callback. The VPI headers of Icarus Verilog 13.0 lack
// vpiGlobalClocking and the other constants used here, and in Verilator
// 5.052 vpiGlobalClocking of an interface is NULL.

interface test_vpi_interface_relations_inner;
  logic v;
endinterface

interface test_vpi_interface_relations_outer;
  logic clk, rst;

  global clocking gck @(posedge clk);
  endclocking

  default disable iff (rst);

  test_vpi_interface_relations_inner n1();
  test_vpi_interface_relations_inner na [1:0] ();
endinterface

interface test_vpi_interface_relations_clk;
  logic clk;

  clocking cb1 @(posedge clk);
  endclocking

  clocking cb2 @(negedge clk);
  endclocking
endinterface

interface test_vpi_interface_relations_plain;
  logic v;
endinterface

module test_vpi_interface_relations;
  test_vpi_interface_relations_outer o1();
  test_vpi_interface_relations_outer o2();
  test_vpi_interface_relations_clk c1();
  test_vpi_interface_relations_plain p();
endmodule

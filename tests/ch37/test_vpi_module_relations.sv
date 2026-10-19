/*
:name: test_vpi_module_relations
:description: a module gives whether it is a top module, its default decay time, its global and default clocking blocks, its default disable condition, its index in a module array and its alias statements; vpi_iterate(vpiModule, NULL) gives the top modules (IEEE 1800-2023 Sections 37.5, 37.76)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.76 14.12 14.14 16.15 22.7 10.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_relations.c
:expected_stdout: @test_vpi_module_relations.expected
*/
// IEEE 1800-2023 §37.5: vpi_iterate(vpiModule, NULL) gives the top modules
// (detail 1); vpiTopModule tells whether a module is one; vpiDefDecayTime is
// the default decay time (§22.7); vpiGlobalClocking and vpiDefaultClocking
// give the global (§14.14) and default (§14.12) clocking blocks, and
// vpiDefaultDisableIff the default disable condition (§16.15); vpiIndex gives
// the index of a module in a module array, and NULL for a module that is not
// in one (detail 2). §37.76: alias a = b = c is the two alias statements
// a = c and b = c (§10.11), each with vpiLhs and vpiRhs.

`timescale 1ns/1ns
`default_decay_time 50

module leaf(input a);
endmodule

module test_vpi_module_relations;
  logic clk = 0, rst = 0;
  wire n1, n2, n3;

  global clocking gclk @(posedge clk); endclocking
  default clocking dcb @(negedge clk); endclocking
  default disable iff (rst);

  alias n1 = n2 = n3;

  leaf single(clk);
  leaf arr [1:0] (clk);

  initial #1 $vt_module;
endmodule

`resetall

/*
:name: test_vpi_clocking_scope_group
:description: A clocking block is an internal scope of its module with the scope name properties and the clocking block type (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_clocking_scope_group.c
:expected_stdout: @test_vpi_clocking_scope_group.expected
*/
// IEEE 1800-2023 §37.12: the scope group lists the clocking block among its
// members, and the group properties vpiName and vpiFullName apply to every
// member (37.12 diagram). A clocking block is therefore reached from its
// module with vpiInternalScope, and it gives the name of the declaration and
// its full hierarchical name (§14.3). The other internal scopes of the module
// are not printed.

`timescale 1ns/1ns

module test_vpi_clocking_scope_group;
  logic clk = 0;

  clocking cb @(posedge clk);
    default input #1;
    input clk;
  endclocking

  initial #1 $vt_clock;
endmodule

/*
:name: test_vpi_clocking_edges_prefix
:description: vpiInputEdge and vpiOutputEdge give the edges of the default skews of a clocking block and of the own skews of its clocking io decls, an io decl gives its input skew as a delay control and its output skew as an expression, a clocking block gives its instance, and a clocking block reached through a virtual interface gives that interface variable as its prefix and the clocking block it refers to as its actual, NULL while the variable is null (IEEE 1800-2023 Section 37.48)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.48 37.61 14.3 14.4 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_clocking_edges_prefix.c
:expected_stdout: @test_vpi_clocking_edges_prefix.expected
*/
// IEEE 1800-2023 §37.48: on a clocking block, vpiInputEdge and vpiOutputEdge
// give the edges of its default input and output skews, and on a clocking io
// decl those of the io decl's own skew (detail 1, §14.3, §14.4): ck has the
// defaults negedge and posedge, c its own posedge #2 and b negedge.
// vpiInputSkew of an io decl is a delay control, here of 2, and vpiOutputSkew
// an expression, here 3 for e. A clocking block leads to the instance
// it is declared in with vpiInstance. §37.61, §25.9: in vif.cb.gnt, gnt is
// prefixed by the clocking block vif.cb, which is itself prefixed by the
// virtual interface vif: vpiPrefix of that clocking block is vif (detail 2),
// and vpiActual is the clocking block cb of the interface instance that vif
// holds, or NULL while vif is null (detail 3). The task peek is never called;
// the application reaches vif.cb.gnt as the right-hand side of its
// assignment, at 1 with vif null and at 2 with vif set to bus.

`timescale 1ns/1ns

interface test_vpi_clocking_edges_prefix_bus(input logic clk);
  logic gnt = 1'b0;

  clocking cb @(posedge clk);
    input gnt;
  endclocking
endinterface

module test_vpi_clocking_edges_prefix;
  logic clk = 0, a = 0, b, c = 0, e, r;

  test_vpi_clocking_edges_prefix_bus bus(clk);
  virtual test_vpi_clocking_edges_prefix_bus vif;

  clocking ck @(posedge clk);
    default input negedge output posedge;
    input a;
    input posedge #2 c;
    output negedge b;
    output #3 e;
  endclocking

  task peek;
    r = vif.cb.gnt;
  endtask

  initial begin
    #1 $vt_clocking;
    vif = bus;
    #1 $vt_actual;
  end
endmodule

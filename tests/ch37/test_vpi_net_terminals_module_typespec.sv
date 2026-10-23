/*
:name: test_vpi_net_terminals_module_typespec
:description: A scalar net gives the primitive terminals and continuous assignments that use it across a port into a child instance, a vector net gives its primitive terminals only through its bits, and nets give their path terminals and timing check terminals, their module and their typespec (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 37.39 37.40 37.47 28.4 30.4 31.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_terminals_module_typespec.c
:expected_stdout: @test_vpi_net_terminals_module_typespec.expected
*/
// IEEE 1800-2023 §37.16: a net has one-to-many relations to primitive
// terminals, continuous assignments, path terminals and timing check
// terminals, and one-to-one relations to its module and its typespec.
// Continuous assignments and primitive terminals are reached regardless of
// hierarchical boundaries (detail 4), from scalar nets or bit-selects
// (detail 5): from the top-level net tn, which is connected to the input pin
// of l, they are the input terminal of the buf g (28.4) and the continuous
// assignment to pout (37.47) inside l, the same as from l.pin itself. The
// vector lv2 gives no terminal, while its bit lv2[1] gives the input terminal
// of gv. In t, the module path a => y (30.4) gives a an input path terminal
// and y an output one (37.39), and the $setup check (31.3) gives d a terminal
// without edge and clk one with posedge (37.40). The application prints each
// list sorted.

`timescale 1ns/1ns

module ntmt_leaf (input wire pin, output wire pout);
  wire pmid, pmid2;
  wire [1:0] lv2 = 2'b10;

  buf g (pmid, pin);
  buf gv (pmid2, lv2[1]);
  assign pout = pin;
endmodule

module ntmt_timed (input wire a, input wire d, input wire clk, output wire y);
  buf gb (y, a);

  specify
    (a => y) = 2;
    $setup(d, posedge clk, 1);
  endspecify
endmodule

module test_vpi_net_terminals_module_typespec;
  wire tn, to;
  wire ta, td, tclk, ty;

  ntmt_leaf l (.pin(tn), .pout(to));
  ntmt_timed t (.a(ta), .d(td), .clk(tclk), .y(ty));

  initial #1 $vt_terms;
endmodule

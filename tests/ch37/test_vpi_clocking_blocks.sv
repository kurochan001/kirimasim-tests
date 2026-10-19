/*
:name: test_vpi_clocking_blocks
:description: a module gives its clocking blocks with their clocking event and default input and output skews, and each clocking block its clocking io declarations with their direction, their own skew and the signal they refer to (IEEE 1800-2023 Section 37.48)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.48 37.65 37.68 38.10 14.3 14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_clocking_blocks.c
:expected_stdout: @test_vpi_clocking_blocks.expected
*/
// IEEE 1800-2023 §37.48: vpi_iterate(vpiClockingBlock, module) gives the
// clocking blocks of a module; vpiClockingEvent gives an event control
// (§37.65) whose condition is the clocking event; on the clocking block,
// vpiInputSkew and vpiOutputSkew give delay controls (§37.68) for the default
// skews (detail 1, §14.4), read with vpi_get_delays (§38.10). Each clocking
// io decl has vpiName and vpiDirection; vpiInputSkew on it gives its own
// input skew, and vpiExpr the signal it refers to (detail 4), here a signal
// of another name for an io decl with an expression (§14.3). Lists are
// sorted.

`timescale 1ns/1ns

module test_vpi_clocking_blocks;
  logic clk = 0, a = 0, b, c = 0, raw = 0;

  clocking cb @(posedge clk);
    default input #2 output #1;
    input a;
    output b;
    input #3 c;
    input renamed = raw;
  endclocking

  initial #1 $vt_clocking;
endmodule

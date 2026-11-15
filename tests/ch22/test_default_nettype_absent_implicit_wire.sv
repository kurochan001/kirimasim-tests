/*
:name: test_default_nettype_absent_implicit_wire
:description: With no `default_nettype directive in the source, implicit nets are wire nets: one driven only by z reads z, and one driven by 0 and by 1 reads x (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_default_nettype_absent_implicit_wire.expected
*/
// IEEE 1800-2023 §22.8: when no `default_nettype directive is present,
// implicit nets are of type wire. This file has no such directive. The two
// continuous assignments below create implicit nets for their undeclared
// targets (6.10). n_float has one driver of z, and a wire with no other driver
// reads z; a tri0, tri1 or trireg net would read 0, 1 or its stored charge.
// n_clash has two strong drivers of 0 and of 1, and a wire reads x; a wand or
// wor net would read 0 or 1. The values are printed at time 1, after the
// continuous assignments have settled.

module test_default_nettype_absent_implicit_wire;
  assign n_float = 1'bz;
  assign n_clash = 1'b0;
  assign n_clash = 1'b1;

  initial #1 $display("only a z driver: %b, drivers of 0 and 1: %b", n_float, n_clash);
endmodule

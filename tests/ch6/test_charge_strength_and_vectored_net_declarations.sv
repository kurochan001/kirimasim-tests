/*
:name: test_charge_strength_and_vectored_net_declarations
:description: A charge strength is allowed with the trireg keyword, which makes a net that stores charge, and a wire declared vectored or scalared has at least one packed dimension; the trireg carries the driven 1 and the two wires carry A and 5 (IEEE 1800-2023 Sections 6.3.2.1, 6.3.3 and 6.6.1 and footnote 16 of A.10)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.2.1 6.3.3 6.6.1 A.10
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_charge_strength_and_vectored_net_declarations.expected
*/
// IEEE 1800-2023 footnote 16 of A.10: a charge strength is used only with
// the trireg keyword, and the vectored or scalared keyword needs at least one
// packed dimension. §6.3.2.1: trireg is the net that stores charge, and the
// strength large is one of its charge strengths. §6.3.3: vectored and
// scalared say how the bits of a vector net are accessed, and both need a
// packed dimension. §6.6.1: a net declaration gives the net its data type and
// dimensions, and a net declaration assignment drives it.
//
// The trireg t is driven with 1, so it carries 1 at time 1. wv is declared
// vectored [3:0] and driven with 4'hA, and ws is declared scalared [3:0] and
// driven with 4'h5, so they carry A and 5.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports trireg nets, so
// this expected output follows the standard.

`timescale 1ns/1ns

module test_charge_strength_and_vectored_net_declarations;
  trireg (large) t;
  wire vectored [3:0] wv = 4'hA;
  wire scalared [3:0] ws = 4'h5;

  assign t = 1'b1;

  initial #1 $display("charge %b vec %h %h", t, wv, ws);
endmodule

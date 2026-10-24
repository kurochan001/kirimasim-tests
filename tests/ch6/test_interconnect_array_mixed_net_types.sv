/*
:name: test_interconnect_array_mixed_net_types
:description: The elements of one interconnect array can resolve to different net types, each taking the type of the ports it connects, here wand for one element and wor for the other (IEEE 1800-2023 Section 6.6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.8 23.3.3.7.1 6.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_array_mixed_net_types.expected
*/
// IEEE 1800-2023 §6.6.8: an interconnect net is typeless, and an interconnect
// array is valid even when its elements are resolved to different net types.
// §23.3.3.7.1: a port connection with an interconnect net merges the nets,
// and the merged net takes the type of the other side.
// bus[0] connects two inout wand ports, driven with 0 and 1, so it is a wand
// and resolves to 0 (6.6.3); bus[1] connects two inout wor ports driven the
// same way, so it is a wor and resolves to 1. Readers with wire inputs, which
// do not change the type, show both. If both elements had one type, both
// would show the same value (x for a wire).
// Oracle checks: neither Icarus Verilog 13.0 nor the 5.052 release supports
// interconnect nets, so the expected output follows the cited clauses alone.

module test_interconnect_array_mixed_net_types_wand(inout wand w);
  parameter bit V = 1'b0;
  assign w = V;
endmodule

module test_interconnect_array_mixed_net_types_wor(inout wor w);
  parameter bit V = 1'b0;
  assign w = V;
endmodule

module test_interconnect_array_mixed_net_types_reader(input wire logic i);
endmodule

module test_interconnect_array_mixed_net_types;
  interconnect bus [0:1];

  test_interconnect_array_mixed_net_types_wand #(.V(1'b0)) a0(bus[0]);
  test_interconnect_array_mixed_net_types_wand #(.V(1'b1)) a1(bus[0]);
  test_interconnect_array_mixed_net_types_wor #(.V(1'b0)) o0(bus[1]);
  test_interconnect_array_mixed_net_types_wor #(.V(1'b1)) o1(bus[1]);
  test_interconnect_array_mixed_net_types_reader r0(bus[0]);
  test_interconnect_array_mixed_net_types_reader r1(bus[1]);

  initial #1 $display("bus[0] (wand ports): %b, bus[1] (wor ports): %b", r0.i, r1.i);
endmodule

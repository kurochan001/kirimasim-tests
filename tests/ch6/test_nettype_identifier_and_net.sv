/*
:name: test_nettype_identifier_and_net
:description: A nettype declaration names a user-defined net type with a data type and an identifier, and a net declared with that name carries the driven value with the four-state semantics of that data type (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 6.6.1 A.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_identifier_and_net.expected
*/
// IEEE 1800-2023 A.9.3: a nettype identifier is an identifier. §6.6.7: a
// nettype declaration gives a net type a data type and a name, here the name
// nibble for a four-bit logic net type, and a net declared with that name has
// that data type. The net n is driven with 4'h9, so the test prints 9.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations, so this expected output follows the standard.

`timescale 1ns/1ns

module test_nettype_identifier_and_net;
  nettype logic [3:0] nibble;

  nibble n;

  assign n = 4'h9;

  initial #1 $display("nettype %h", n);
endmodule

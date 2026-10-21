/*
:name: test_illegal_default_nettype_none_gate_terminal
:description: Under `default_nettype none, a gate terminal cannot declare an implicit net (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.8 6.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an undeclared identifier is connected to a gate output while `default_nettype is none
:expected_stderr_regex: test_illegal_default_nettype_none_gate_terminal\.sv:24:
*/
// IEEE 1800-2023 §6.10: an undeclared identifier connected to a terminal of a
// primitive implicitly declares a net. §22.8: with `default_nettype none,
// implicit nets are not declared, and the undeclared identifier is an error.

`timescale 1ns/1ns

`default_nettype none

module test_illegal_default_nettype_none_gate_terminal;
  wire a = 1'b1, b = 1'b0;
  and g(y, a, b);   // illegal: y is not declared
  initial #1 $display("done");
endmodule

`default_nettype wire

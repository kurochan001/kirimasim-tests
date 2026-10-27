/*
:name: test_illegal_checker_port_types
:description: A checker input may have the property formal type, but an output shall not have the untyped, sequence or property type (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: three checkers declare an output without a type, an output of type property, and an output of type sequence, while the input property formal is legal
:expected_stderr_regex: test_illegal_checker_port_types\.sv:(32|36|39):
*/
// IEEE 1800-2023 17.2: the legal data types for checker formals are those
// legal for a property, so an input may be a property. The type of an output
// shall not be untyped, sequence or property. legal_input has an input
// property and is legal. bad_untyped has an explicit output direction but no
// type, bad_property has an output property, and bad_sequence has an output
// sequence. Those three declarations are the error; the module instantiates
// only the legal checker.
// Icarus Verilog 13.0 has no checkers and Verilator 5.052 rejects the
// unsupported forms at other sites, so neither release gives the expected
// result.

`timescale 1ns/1ns

checker legal_input(input property p, input logic clk);
  p_ok: assert property (p);
  c_ok: cover property (@(posedge clk) 1'b1);
endchecker

checker bad_untyped(input logic a, output o);   // illegal: output type omitted
  assign o = a;
endchecker

checker bad_property(input logic a, output property p);   // illegal
endchecker

checker bad_sequence(input logic a, output sequence s);   // illegal
endchecker

module test_illegal_checker_port_types;
  logic clk = 1'b0, v = 1'b1;
  logic o;

  property pp;
    @(posedge clk) v;
  endproperty

  legal_input u_legal(pp, clk);
  bad_untyped u_untyped(v, o);

  always #5 clk = ~clk;
  initial #20 $finish;
endmodule

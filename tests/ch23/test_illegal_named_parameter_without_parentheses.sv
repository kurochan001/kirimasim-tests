/*
:name: test_illegal_named_parameter_without_parentheses
:description: A parameter assignment by name needs its parentheses even when it has no expression, so .D without them is illegal, while .D() keeps the default value (IEEE 1800-2023 Section 23.10.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter value assignment of u2 names D without parentheses
:expected_stderr_regex: test_illegal_named_parameter_without_parentheses\.sv:29:
*/
// IEEE 1800-2023 §23.10.2.2: the parameter expression of an assignment by name
// is optional, so that an instance can document a parameter without assigning
// it, but the parentheses are required, and the parameter then keeps its
// default value. Unlike a port, a parameter has no .name shorthand. u1 writes
// .D(), which is legal; u2 writes .D alone. The localparam D of the top module
// gives a value that a reading of .D as .D(D) would find.
// The 5.052 release of Verilator accepts the design.

module npp_leaf #(parameter int W = 4, parameter int D = 2) ();
  initial #1 $display("%m W=%0d D=%0d", W, D);
endmodule

module test_illegal_named_parameter_without_parentheses;
  localparam int D = 5;
  npp_leaf #(.W(8), .D()) u1 ();
  npp_leaf #(.W(8), .D) u2 ();   // illegal: no parentheses after .D
endmodule

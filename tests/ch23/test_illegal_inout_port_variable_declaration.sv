/*
:name: test_illegal_inout_port_variable_declaration
:description: An inout port cannot be declared as a variable; a variable type is not allowed on the inside of an inout port (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inout port p of vio_child is declared with var, which makes it a variable
:expected_stderr_regex: test_illegal_inout_port_variable_declaration\.sv:(21|26):
*/
// IEEE 1800-2023 §23.3.3.2: a variable data type is not permitted on either
// side of an inout port. The port p of vio_child is declared with the var
// keyword, so it is a variable on the inside of the port; the instance
// connects it to a net, so only the inside breaks the rule. The port q, an
// inout of data type logic without var, is a net (23.2.2.3) and is legal.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module vio_child(inout var logic p, inout logic q);   // illegal: p is a variable
endmodule

module test_illegal_inout_port_variable_declaration;
  wire a, b;
  vio_child u (.p(a), .q(b));   // the error can also be reported here
endmodule

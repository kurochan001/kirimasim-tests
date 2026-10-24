/*
:name: test_illegal_inout_port_declared_as_variable
:description: An inout port cannot be declared as a variable (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 23.2.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inout port p is declared with var, which makes it a variable
:expected_stderr_regex: test_illegal_inout_port_declared_as_variable\.sv:19:
*/
// IEEE 1800-2023 §6.5: variables cannot be connected to either side of an
// inout port. The keyword var makes the port p a variable (23.2.2.3), so the
// inside of the inout port is a variable; the parent connects a net to it.
// Oracle checks: the 5.052 release accepts the design.

module test_illegal_inout_port_declared_as_variable_child(inout var logic p);   // illegal
endmodule

module test_illegal_inout_port_declared_as_variable;
  wire w;
  test_illegal_inout_port_declared_as_variable_child c(.p(w));
endmodule

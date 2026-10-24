/*
:name: test_illegal_variable_actual_on_inout_port
:description: A variable cannot be connected to an inout port of an instance (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 23.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v is connected to the inout port p of the instance c
:expected_stderr_regex: test_illegal_variable_actual_on_inout_port\.sv:25:
*/
// IEEE 1800-2023 §6.5: variables cannot be connected to either side of an
// inout port; only nets can (23.3.3), and a variable can be shared across a
// port only with a ref port. The port p of the child is a net, so the error
// is only in the connection of the parent's variable v to it.
// Oracle checks: the 5.052 release accepts the design.

module test_illegal_variable_actual_on_inout_port_child(inout wire p);
endmodule

module test_illegal_variable_actual_on_inout_port;
  logic v;
  test_illegal_variable_actual_on_inout_port_child c(.p(v));   // illegal: v is a variable
endmodule

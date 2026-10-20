/*
:name: test_illegal_input_port_variable_assigned
:description: A module cannot assign to its own input port when the port is a variable (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 23.2.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module assigns to its input port a, which is declared as a variable
:expected_stderr_regex: test_illegal_input_port_variable_assigned\.sv:20:
*/
// IEEE 1800-2023 §6.5: an input port that is a variable gets its value from the
// connection, which acts as a continuous assignment, so the module itself
// cannot assign to it. The port is declared with var (23.2.2.3), so it is a
// variable and not a net.

module sub(input var logic a);
  initial a = 1'b1;    // illegal: a is an input port
endmodule

module test_illegal_input_port_variable_assigned;
  logic x = 1'b0;
  sub u(.a(x));
endmodule

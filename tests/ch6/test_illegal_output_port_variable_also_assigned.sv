/*
:name: test_illegal_output_port_variable_also_assigned
:description: A variable connected to an output port of an instance cannot also be assigned elsewhere (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 23.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable w is driven by the output port of u and assigned by an initial procedure
:expected_stderr_regex: test_illegal_output_port_variable_also_assigned\.sv:(25|26):
*/
// IEEE 1800-2023 §6.5: a variable connected to an output port of an instance is
// written through that port as if by a continuous assignment, so no other
// assignment can write it. Here w is also written by an initial procedure; a
// tool can report the connection or the procedural assignment.

module sub(output logic y);
  assign y = 1'b1;
endmodule

module test_illegal_output_port_variable_also_assigned;
  logic w;
  sub u(.y(w));        // illegal: the port of u writes w
  initial w = 1'b0;    // illegal: and so does this procedure
endmodule

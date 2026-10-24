/*
:name: test_illegal_output_port_variable_procedural_write
:description: A variable connected to a variable output port of an instance is driven by the port and cannot also be assigned procedurally (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable r, connected to the output port o of u, is also assigned in an initial procedure
:expected_stderr_regex: test_illegal_output_port_variable_procedural_write\.sv:(30|31):
*/
// IEEE 1800-2023 §23.3.3.2: an output port declared as a variable can be
// connected to a variable or a concatenation of variables of a compatible
// type; the connection implies a continuous assignment to it, so a procedural
// or continuous assignment to such a variable is illegal. The instance ok
// connects the concatenation {hi, lo}, which nothing else assigns; u
// connects r, which an initial procedure also assigns.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module ovp_child(output logic [1:0] o);
  assign o = 2'b10;
endmodule

module test_illegal_output_port_variable_procedural_write;
  logic hi, lo;
  logic [1:0] r;
  ovp_child ok (.o({hi, lo}));
  ovp_child u (.o(r));   // the error can also be reported here
  initial r = 2'b01;   // illegal: r is driven by the output port of u
endmodule

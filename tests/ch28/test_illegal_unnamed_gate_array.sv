/*
:name: test_illegal_unnamed_gate_array
:description: An array of gate instances has to be named (IEEE 1800-2023 Section 28.3.4)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.4 28.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array of and gates has no name
:expected_stderr_regex: test_illegal_unnamed_gate_array\.sv:19:
*/
// IEEE 1800-2023 §28.3.4: the name of a gate instance is optional, but an array
// of instances (28.3.5) shall have one.

module test_illegal_unnamed_gate_array;
  wire [1:0] o, a, b;
  and [1:0] (o, a, b);   // illegal: an array without a name
endmodule

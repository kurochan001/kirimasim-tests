/*
:name: test_illegal_scope_gate_named_as_output_net
:description: A gate instance cannot have the same name as the net connected to its output, since one name declares one item in a scope (IEEE 1800-2023 Section 23.9)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the buf instance is named y, the name of the net connected to its output
:expected_stderr_regex: test_illegal_scope_gate_named_as_output_net\.sv:24:
*/
// IEEE 1800-2023 §23.9: an identifier declares only one item within a scope,
// so a gate instance cannot be given the name of the net that is connected
// to its output. The gate g drives the net z and is legal; the second buf is
// named y and drives the net y.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module test_illegal_scope_gate_named_as_output_net;
  wire a = 1'b1;
  wire y, z;
  buf g (z, a);
  buf y (y, a);   // illegal: the instance name y is the name of the net y
endmodule

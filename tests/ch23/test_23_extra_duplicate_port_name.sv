/*
:name: test_23_extra_duplicate_port_name
:description: External port identifiers have their own namespace for each port list, so two port declarations of one list cannot define the same external port name (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ANSI port list of dp declares the external port name a twice, once for each of two local variables
:expected_stderr_regex: test_23_extra_duplicate_port_name\.sv:24:
*/
// IEEE 1800-2023 §23.2.2.2: the port identifiers of an ANSI list of port
// declarations exist in their own namespace for that port list. When a
// port item is just a simple port identifier, that identifier is both the
// reference to an interface item and the external port identifier. Once a
// port identifier has been defined, there shall not be another port
// definition with the same name. The header of dp defines a twice, so the
// second declaration is illegal even though the two ports would be
// different objects internally.
// Both simulators report the duplicate port at this line.

module dp(input logic a, input logic a);
endmodule

module test_23_extra_duplicate_port_name;
  logic v = 1'b1;
  dp u(.a(v));
endmodule

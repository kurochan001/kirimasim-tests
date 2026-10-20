/*
:name: test_illegal_port_connected_twice
:description: A port cannot be connected twice in the named connections of an instance (IEEE 1800-2023 Section 23.3.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input port a of u is connected twice
:expected_stderr_regex: test_illegal_port_connected_twice\.sv:23:
*/
// IEEE 1800-2023 §23.3.2.2: in named port connections each port can be
// connected at most once.

module sub(input logic a, output logic y);
  assign y = a;
endmodule

module test_illegal_port_connected_twice;
  logic p = 1'b0, q = 1'b1, r;
  sub u(.a(p), .a(q), .y(r));   // illegal: a is connected twice
endmodule

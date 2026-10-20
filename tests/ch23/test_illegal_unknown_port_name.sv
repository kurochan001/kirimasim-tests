/*
:name: test_illegal_unknown_port_name
:description: A named port connection has to name a port of the module (IEEE 1800-2023 Section 23.3.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u connects b, which sub does not have
:expected_stderr_regex: test_illegal_unknown_port_name\.sv:22:
*/
// IEEE 1800-2023 §23.3.2.2: the name in a named port connection is the name of
// a port in the module declaration; sub has no port b.

module sub(input logic a);
endmodule

module test_illegal_unknown_port_name;
  logic p = 1'b0;
  sub u(.b(p));        // illegal: sub has no port b
endmodule

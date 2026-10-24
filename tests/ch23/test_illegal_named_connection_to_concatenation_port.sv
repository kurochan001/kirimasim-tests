/*
:name: test_illegal_named_connection_to_concatenation_port
:description: A named port connection cannot be used for an implicit port unless its port expression is a simple or escaped identifier, so connecting by name a port that is the concatenation {c, d} is an error (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first port of concat_port_leaf is the implicit port {c, d}, which has no port name, and u2 connects it by the name c
:expected_stderr_regex: test_illegal_named_connection_to_concatenation_port\.sv:35:
*/
// IEEE 1800-2023 §23.2.2.1: a port that has only a port expression is an
// implicit port, and named port connections shall not be used for an
// implicit port unless its expression is a simple or escaped identifier,
// which is then the name of the port. The first port of concat_port_leaf
// is {c, d}, so it has no name; the second is y, a simple identifier. The
// instance u1 connects both by order, which is legal; u2 connects y by
// name, which is legal, and the first port by the name c.
// The first port is rejected by Verilator 5.052, which does not support a
// concatenation as a port expression, so its error does not come from
// this rule.

module concat_port_leaf({c, d}, y);
  input c, d;
  output [1:0] y;
  assign y = {d, c};
endmodule

module test_illegal_named_connection_to_concatenation_port;
  logic [1:0] v = 2'b10;
  wire [1:0] w1, w2;
  concat_port_leaf u1(v, w1);
  concat_port_leaf u2(.c(v), .y(w2));  // illegal: the port {c, d} has no name
endmodule

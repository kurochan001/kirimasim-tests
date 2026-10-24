/*
:name: test_illegal_named_connection_by_internal_name
:description: An explicit non-ANSI port gives the name used to connect the instance port, so connecting it by the name of the internal net in its port expression is an error (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the explicit port .e(f) of explicit_port_leaf is named e, and u2 connects it by the internal name f
:expected_stderr_regex: test_illegal_named_connection_by_internal_name\.sv:35:
*/
// IEEE 1800-2023 §23.2.2.1: an explicit port, .port_identifier(expression),
// gives the port_identifier that instances use to connect the port by name,
// and its expression names the internal nets or variables. The first port
// of explicit_port_leaf is .e(f): its name is e and f is declared inside.
// u1 connects it by the name e, which is legal; u2 uses the name f, which
// is not a port name. The second port, y, is an implicit port whose
// expression is a simple identifier, so both instances can connect it by
// name.
// The module is rejected by Verilator 5.052, which does not support
// explicit ports such as .e(f), so its error does not come from this rule.

module explicit_port_leaf(.e(f), y);
  input f;
  output y;
  assign y = ~f;
endmodule

module test_illegal_named_connection_by_internal_name;
  logic s = 1'b1;
  wire w1, w2;
  explicit_port_leaf u1(.e(s), .y(w1));
  explicit_port_leaf u2(.f(s), .y(w2));  // illegal: the port is named e
endmodule

/*
:name: test_illegal_named_connection_concatenated_port_member
:description: A port whose port expression is a concatenation has no name, so a named connection cannot use the name of a net inside the concatenation (IEEE 1800-2023 Section 23.3.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.2 23.2.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the named connection of u uses lo, a net in the concatenated port {hi, lo}, which is not a port name of the module
:expected_stderr_regex: test_illegal_named_connection_concatenated_port_member\.sv:29:
*/
// IEEE 1800-2023 §23.3.2.2: the port name of a named port connection is
// the name in the module declaration; it cannot be a bit-select, a
// part-select or a concatenation of ports. The module has one port, the
// concatenation {hi, lo} (a non-ANSI port expression, §23.2.2.1), which
// has no port name; lo is a net of the module, not a port, so u cannot
// connect .lo. A positional connection of the port would be legal.
// The design is rejected by Verilator 5.052 at the module, which it does
// not support with a concatenated port expression.

module named_connection_concatenated_m({hi, lo});
  input hi, lo;
endmodule

module test_illegal_named_connection_concatenated_port_member;
  logic p = 1'b0;
  named_connection_concatenated_m u(.lo(p));   // illegal
endmodule

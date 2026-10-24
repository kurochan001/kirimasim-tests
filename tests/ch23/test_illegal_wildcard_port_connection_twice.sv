/*
:name: test_illegal_wildcard_port_connection_twice
:description: The .* token may stand anywhere among named port connections, but at most once in a port list (IEEE 1800-2023 Section 23.3.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port list of u has the .* token twice
:expected_stderr_regex: test_illegal_wildcard_port_connection_twice\.sv:29:
*/
// IEEE 1800-2023 §23.3.2.4: when .* is mixed with named port connections it
// can be placed anywhere in the port list, but it appears at most once. The
// instance first puts .* between two named connections and last puts it at
// the end, which is legal; u gives it twice.
// Oracle checks: Icarus Verilog 13.0 accepts the design.

module wpt_child(input logic a, input logic b, output logic y);
  assign y = a & b;
endmodule

module test_illegal_wildcard_port_connection_twice;
  logic a = 1'b1, b = 1'b1, c = 1'b0;
  logic y1, y2, y3;
  wpt_child first (.y(y1), .*, .b(c));
  wpt_child last (.y(y2), .*);
  wpt_child u (.*, .y(y3), .*);   // illegal: .* twice
endmodule

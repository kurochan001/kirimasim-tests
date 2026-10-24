/*
:name: test_illegal_two_wildcard_tokens_in_port_list
:description: The .* token pair can appear at most once in a list of port connections, so an instance with two of them is an error (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port connection list of u2 contains the .* token pair twice
:expected_stderr_regex: test_illegal_two_wildcard_tokens_in_port_list\.sv:28:
*/
// IEEE 1800-2023 §23.3.2 (footnote 34 of Syntax 23-6): the .* token pair
// shall appear at most once in a list of port connections. The instance
// u1 has one .* and an explicit named connection, which is legal; u2 has
// a second .* after them.
// The design is accepted by Icarus Verilog 13.0.

module wild_leaf(input logic a, input logic b, output logic y);
  assign y = a ^ b;
endmodule

module test_illegal_two_wildcard_tokens_in_port_list;
  logic a = 1'b1, b = 1'b0;
  wire y, y2;
  wild_leaf u1(.*, .y(y));
  wild_leaf u2(.*, .y(y2), .*);  // illegal: .* twice
endmodule

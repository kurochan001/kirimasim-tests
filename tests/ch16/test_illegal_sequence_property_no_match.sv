/*
:name: test_illegal_sequence_property_no_match
:description: A sequence used as a property cannot be a sequence that admits no match (IEEE 1800-2023 Section 16.12.22)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.22 16.12.2 16.9.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sequence used as the property can never match, so it is degenerate
:expected_stderr_regex: test_illegal_sequence_property_no_match\.sv:25:
*/
// IEEE 1800-2023 §16.12.22, restriction a): a sequence used as a property
// (§16.12.2) shall be nondegenerate and shall not admit an empty match.
// (a ##1 b) intersect (a ##2 b) admits no empty match, but no match at all
// either, as the two operands of intersect (§16.9.6) always have different
// lengths, so it is degenerate. It is the whole property of the assertion.
// Icarus Verilog 13.0 does not support these concurrent assertions, so the
// syntax error it reports on this line does not count; the 5.052 release
// of Verilator accepts the design.

module test_illegal_sequence_property_no_match;
  logic clk = 0, a = 0, b = 0;
  p_nm: assert property (@(posedge clk) (a ##1 b) intersect (a ##2 b));  // illegal
endmodule

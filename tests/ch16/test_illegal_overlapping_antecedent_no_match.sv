/*
:name: test_illegal_overlapping_antecedent_no_match
:description: The antecedent of an overlapping implication cannot be a sequence that admits no match (IEEE 1800-2023 Section 16.12.22)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.22 16.12.7 16.9.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the antecedent of |-> can never match, so it is degenerate
:expected_stderr_regex: test_illegal_overlapping_antecedent_no_match\.sv:25:
*/
// IEEE 1800-2023 §16.12.22, restriction b): the antecedent of an
// overlapping implication (§16.12.7) shall be nondegenerate, that is, it
// shall admit at least one nonempty match. (a ##1 b) intersect (a ##2 b)
// admits no match at all, as the two operands of intersect (§16.9.6) always
// have different lengths, so it is degenerate.
// Icarus Verilog 13.0 does not support these concurrent assertions, so the
// syntax error it reports on this line does not count; the 5.052 release
// of Verilator accepts the design.

module test_illegal_overlapping_antecedent_no_match;
  logic clk = 0, a = 0, b = 0, c = 0;
  p_nm: assert property (@(posedge clk) ((a ##1 b) intersect (a ##2 b)) |-> c);  // illegal
endmodule

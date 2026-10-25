/*
:name: test_illegal_nonoverlapping_antecedent_no_match
:description: The antecedent of a nonoverlapping implication has to admit at least one match (IEEE 1800-2023 Section 16.12.22)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.22 16.12.7 16.9.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the antecedent of |=> can never match
:expected_stderr_regex: test_illegal_nonoverlapping_antecedent_no_match\.sv:22:
*/
// IEEE 1800-2023 §16.12.22: the antecedent of a nonoverlapping implication
// shall admit at least one match. The two sides of the intersect (16.9.6) have
// different lengths, so the intersection never matches. Icarus Verilog 13.0
// does not support these concurrent assertions, so the syntax error it reports
// here does not count.

module test_illegal_nonoverlapping_antecedent_no_match;
  logic ck, a, b, c;
  p_nm: assert property (@(posedge ck) ((a ##1 b) intersect (a ##2 b)) |=> c);  // illegal
endmodule

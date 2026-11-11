/*
:name: test_illegal_overlapping_antecedent_empty_only
:description: The antecedent of an overlapping implication cannot be a sequence that admits only empty matches (IEEE 1800-2023 Section 16.12.22)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.22 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the antecedent of |-> admits only an empty match
:expected_stderr_regex: test_illegal_overlapping_antecedent_empty_only\.sv:22:
*/
// IEEE 1800-2023 §16.12.22: the antecedent of an overlapping implication
// (16.12.7) shall be nondegenerate. a[*0] admits only the empty match, so it is
// degenerate; as the antecedent of |=> it would be allowed. Icarus Verilog 13.0
// does not support these concurrent assertions and Verilator 5.052 does not
// support [*0], so the errors they report here do not count.

module test_illegal_overlapping_antecedent_empty_only;
  logic clk, a, c;
  p_ante: assert property (@(posedge clk) a[*0] |-> c);   // illegal: degenerate antecedent
endmodule

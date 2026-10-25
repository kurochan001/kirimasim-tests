/*
:name: test_illegal_plain_sequence_property_empty_match
:description: the sequence of a plain sequence property cannot admit an empty match (IEEE 1800-2023 Section 16.12.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the consequent of p_bad is the sequence property b[*0:2], whose sequence admits an empty match
:expected_stderr_regex: test_illegal_plain_sequence_property_empty_match\.sv:27:
*/
// IEEE 1800-2023 §16.12.2: a sequence property has the form sequence_expr,
// weak(sequence_expr) or strong(sequence_expr), and its sequence_expr shall
// not admit an empty match (16.12.22). Here the form is
// the plain sequence_expr. In p_ok the consequent is b[*1:2],
// whose sequence takes at least one cycle; in p_bad the consequent is
// b[*0:2], whose sequence also matches with zero repetitions,
// which is an empty match.
// Icarus Verilog 13.0 does not support this repetition, so the syntax error
// it reports on this line does not count; Verilator 5.052 accepts the design.

module test_illegal_plain_sequence_property_empty_match;
  logic clk = 0, a = 0, b = 0;
  p_ok: assert property (@(posedge clk) a |-> b[*1:2]);
  p_bad: assert property (@(posedge clk) a |-> b[*0:2]);   // illegal
endmodule

/*
:name: test_illegal_sequence_property_empty_match
:description: A sequence used as a property cannot admit an empty match (IEEE 1800-2023 Section 16.12.22)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.22 16.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sequence used as the property admits an empty match
:expected_stderr_regex: test_illegal_sequence_property_empty_match\.sv:22:
*/
// IEEE 1800-2023 §16.12.22: a sequence used as a property shall be
// nondegenerate and shall not admit an empty match. (a ##1 b)[*0:1] can match
// with zero repetitions, which is an empty match. Icarus Verilog 13.0 does not
// support these concurrent assertions and Verilator 5.052 does not support this
// repetition, so the errors they report here do not count.

module test_illegal_sequence_property_empty_match;
  logic clk, a, b;
  p_empty: assert property (@(posedge clk) (a ##1 b)[*0:1]);   // illegal: empty match
endmodule

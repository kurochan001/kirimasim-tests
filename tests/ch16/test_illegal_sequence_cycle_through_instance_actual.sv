/*
:name: test_illegal_sequence_cycle_through_instance_actual
:description: an instance whose actual argument instantiates a named sequence counts as a dependency for the cycle rule (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an instance of s7 has an actual that instantiates s9, and s9 instantiates s7 in its declaration
:expected_stderr_regex: test_illegal_sequence_cycle_through_instance_actual\.sv:(33|36):
*/
// IEEE 1800-2023 §16.8: in the graph of the cycle rule, a named sequence also
// depends on each one that an actual argument of one of its instances
// instantiates. The instance of s7 in p_bad has the actual s9, so s7 depends
// on s9, and s9 instantiates s7 in its declaration: a cycle, although the
// flattened sequence would be finite. The instance of s7 with the actual
// s_leaf in p_ok makes no cycle. A tool can report the error at the
// instance or in the declaration of s9.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_sequence_cycle_through_instance_actual;
  logic clk = 0, a = 0, b = 0;
  sequence s_leaf;
    b ##1 a;
  endsequence
  sequence s7(x);
    a ##1 x;
  endsequence
  sequence s9;
    s7(b);
  endsequence
  p_ok: assert property (@(posedge clk) s7(s_leaf));
  p_bad: assert property (@(posedge clk) s7(s9));   // illegal
endmodule

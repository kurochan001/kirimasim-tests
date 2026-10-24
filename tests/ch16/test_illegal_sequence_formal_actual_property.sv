/*
:name: test_illegal_sequence_formal_actual_property
:description: the actual of a sequence formal of type sequence has to be a sequence expression (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_s in p_bad passes the property expression a |-> b to the formal q of type sequence
:expected_stderr_regex: test_illegal_sequence_formal_actual_property\.sv:28:
*/
// IEEE 1800-2023 §16.8.1: the actual of a formal of type sequence shall be a
// sequence expression. p_seq passes a ##1 b and p_bool the Boolean b, which
// is a sequence expression too; p_bad passes the implication a |-> b, a
// property expression.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support formals of type sequence; neither error counts.

module test_illegal_sequence_formal_actual_property;
  logic clk = 0, a = 0, b = 0, c = 0;
  sequence s_s(sequence q);
    c ##1 q;
  endsequence
  p_seq: assert property (@(posedge clk) s_s(a ##1 b));
  p_bool: assert property (@(posedge clk) s_s(b));
  p_bad: assert property (@(posedge clk) s_s(a |-> b));   // illegal
endmodule

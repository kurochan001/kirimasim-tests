/*
:name: test_illegal_sequence_formal_goto_operand
:description: a reference to a sequence formal of type sequence has to be where a sequence expression is legal, which excludes the operand of goto repetition (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s_bad applies goto repetition to its formal q of type sequence
:expected_stderr_regex: test_illegal_sequence_formal_goto_operand\.sv:29:
*/
// IEEE 1800-2023 §16.8.1: a reference to a formal of type sequence shall be
// where a sequence expression is legal, or the operand of the sequence
// methods triggered and matched; the operand of a goto repetition is not
// such a place, whatever the actual. s_ok uses q in a concatenation and
// with consecutive repetition, which is legal; s_bad applies goto
// repetition to q.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support formals of type sequence; neither error counts.

module test_illegal_sequence_formal_goto_operand;
  logic clk = 0, a = 0, b = 0, c = 0;
  sequence s_ok(sequence q);
    c ##1 q[*2];
  endsequence
  sequence s_bad(sequence q);
    c ##1 q[->2];   // illegal
  endsequence
  p_ok: assert property (@(posedge clk) s_ok(b));
endmodule

/*
:name: test_illegal_matched_in_disable
:description: The sequence method matched may be used only in sequence expressions, so it cannot appear in a disable iff condition of a property (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: src.matched is used in a disable iff condition, which is not a sequence expression
:expected_stderr_regex: test_illegal_matched_in_disable\.sv:30:
*/
// IEEE 1800-2023 §16.13.6: matched detects the end point of a source sequence
// in a multiclocked destination sequence and can only be used in sequence
// expressions. In p_ok, src.matched is the left operand of the implication,
// which is a sequence expression, and is legal. In p_bad the same method is
// the argument of disable iff, a Boolean property condition and not a
// sequence expression, so the design is illegal.

module test_illegal_matched_in_disable;
  logic c1 = 0, c2 = 0;
  logic a = 0, b = 0;

  sequence src;
    @(posedge c1) a ##1 b;
  endsequence

  p_ok: assert property (@(posedge c2) src.matched |-> a);
  p_bad: assert property (@(posedge c2) disable iff (src.matched) a);   // illegal
endmodule

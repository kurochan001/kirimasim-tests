/*
:name: test_illegal_triggered_on_expression
:description: The operand of the sequence method triggered shall be a named sequence instance, an untyped formal argument or a sequence formal argument, so applying triggered to the sequence expression (a ##1 b) is an error (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad applies triggered to the parenthesized sequence expression (a ##1 b) instead of a named sequence
:expected_stderr_regex: test_illegal_triggered_on_expression\.sv:31:
*/
// IEEE 1800-2023 §16.13.6: the operand of triggered or matched shall be a
// named sequence instance, with or without arguments, an untyped formal
// argument, or a formal argument of type sequence. p_ok applies triggered to
// the named sequence s and is legal. p_bad applies it to the sequence
// expression (a ##1 b), which has no name for the method to refer to, and is
// illegal.

module test_illegal_triggered_on_expression;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  sequence s;
    @(posedge clk) a ##1 b;
  endsequence

  p_ok: assert property (@(posedge clk) s.triggered);
  p_bad: assert property (@(posedge clk) (a ##1 b).triggered);   // illegal
endmodule

/*
:name: test_illegal_multiclock_operator
:description: Differently clocked sequence operands may be combined only with ##1 or ##0, so a ##2 between a posedge c1 operand and a posedge c2 operand is an error (IEEE 1800-2023 Section 16.13.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the differently clocked operands a and b are joined with ##2 instead of ##1 or ##0
:expected_stderr_regex: test_illegal_multiclock_operator\.sv:26:
*/
// IEEE 1800-2023 §16.13.1: a multiclocked sequence is built from singly
// clocked subsequences with ##1 or ##0 only. Differently clocked or
// multiclocked sequence operands cannot be combined with any other sequence
// operator. p_ok joins a under posedge c1 to b under posedge c2 with ##1 and
// is legal; p_bad uses ##2 and is illegal, because the delay would have to be
// measured in a clock that the sequence does not define.

module test_illegal_multiclock_operator;
  logic c1 = 0, c2 = 0;
  logic a = 0, b = 0;

  p_ok: assert property (@(posedge c1) a ##1 @(posedge c2) b);
  p_bad: assert property (@(posedge c1) a ##2 @(posedge c2) b);   // illegal
endmodule

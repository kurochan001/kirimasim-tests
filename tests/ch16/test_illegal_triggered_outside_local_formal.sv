/*
:name: test_illegal_triggered_outside_local_formal
:description: triggered may be used outside a sequence context only when the sequence does not treat a formal as a local variable, so a wait on s(v).triggered is an error when s increments its formal (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s_bad increments its untyped formal x in a match item, and the wait calls s_bad(v).triggered outside a sequence context
:expected_stderr_regex: test_illegal_triggered_outside_local_formal\.sv:35:
*/
// IEEE 1800-2023 §16.13.6: triggered may be used in wait statements and other
// Boolean expressions outside a sequence context, but it is an error to call
// it there on a sequence that treats a formal argument as a local variable,
// which the sequence does by using the formal as the lvalue of an assignment
// or increment in a sequence_match_item. s_ok only reads x, so the wait on
// s_ok(1'b1).triggered is legal. s_bad increments x, and the wait on
// s_bad(v).triggered is outside a sequence context and is illegal.

module test_illegal_triggered_outside_local_formal;
  logic a = 0, b = 0;
  int v = 0;

  sequence s_ok(x);
    x ##1 b;
  endsequence

  sequence s_bad(x);
    (a, x++) ##1 b;
  endsequence

  initial wait (s_ok(1'b1).triggered);
  initial wait (s_bad(v).triggered);   // illegal: formal used as an lvalue
endmodule

/*
:name: test_illegal_cover_action_concurrent
:description: The optional pass statement of a cover statement shall not contain a concurrent assert, assume or cover statement, so a cover property whose pass statement is assert property is an error (IEEE 1800-2023 Section 16.14.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pass statement of p_bad is the concurrent assertion assert property
:expected_stderr_regex: test_illegal_cover_action_concurrent\.sv:27:
*/
// IEEE 1800-2023 §16.14.3: a cover statement may have an optional pass
// statement, which shall not include any concurrent assert, assume or cover
// statement. p_ok has a display as its pass statement and is legal. p_bad
// has assert property as its pass statement, so a successful coverage match
// would start another concurrent assertion, and the design is illegal.

module test_illegal_cover_action_concurrent;
  logic clk = 0;
  logic a = 1;
  logic b = 1;

  p_ok: cover property (@(posedge clk) a) $display("a covered");
  p_bad: cover property (@(posedge clk) a)
    assert property (@(posedge clk) b);   // illegal
endmodule

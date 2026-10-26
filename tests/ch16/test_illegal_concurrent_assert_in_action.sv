/*
:name: test_illegal_concurrent_assert_in_action
:description: The action block of a concurrent assert statement shall not contain a concurrent assert, although it may contain an immediate assertion (IEEE 1800-2023 Section 16.14.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the else action block of p_bad contains a concurrent assert property statement
:expected_stderr_regex: test_illegal_concurrent_assert_in_action\.sv:29:
*/
// IEEE 1800-2023 §16.14.1: the action block of a concurrent assert statement
// shall not include any concurrent assert, assume or cover statement, but it
// can contain immediate assertion statements. The else block of p_ok contains
// the immediate assertion assert (b), which is legal. The else block of p_bad
// contains assert property, a concurrent assertion, and is illegal.

module test_illegal_concurrent_assert_in_action;
  logic clk = 0;
  logic a = 1;
  logic b = 1;

  p_ok: assert property (@(posedge clk) a) else begin
    assert (b);
  end
  p_bad: assert property (@(posedge clk) a) else begin
    assert property (@(posedge clk) b);   // illegal
  end
endmodule

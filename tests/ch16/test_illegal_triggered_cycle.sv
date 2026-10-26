/*
:name: test_illegal_triggered_cycle
:description: two sequences depend on each other through the sequence method triggered, which makes a circular dependency
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s1 uses s2.triggered and s2 uses s1.triggered, so the sequence dependencies are circular
:expected_stderr_regex: test_illegal_triggered_cycle\.sv:(23|27|30):
*/
// IEEE 1800-2023 §16.13.6: there shall be no circular dependencies between
// sequences induced by the use of the sequence method triggered. s1 waits for
// the end point of s2 and s2 waits for the end point of s1, so each depends on
// the other and the assertion of s1 is illegal. Each sequence alone is legal.

module test_illegal_triggered_cycle;
  logic clk = 0, a = 0, b = 0;

  sequence s1;
    a ##1 s2.triggered;
  endsequence

  sequence s2;
    b ##1 s1.triggered;
  endsequence

  a_bad: assert property (@(posedge clk) s1);   // illegal: circular triggered dependency
endmodule

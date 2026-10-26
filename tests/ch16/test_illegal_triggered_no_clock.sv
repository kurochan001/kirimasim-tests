/*
:name: test_illegal_triggered_no_clock
:description: the sequence method triggered is applied to a clock-free sequence that has no clock to infer
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.13.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the wait in the initial block uses s.triggered, and s has no clock and no enclosing clock
:expected_stderr_regex: test_illegal_triggered_no_clock\.sv:26:
*/
// IEEE 1800-2023 §16.13.6: the sequence on which triggered is applied shall
// be clocked or shall infer its clock from the context where it is used. s
// has no clocking event, and the wait in the initial block has no clock to
// infer, so the use of s.triggered is illegal.

module test_illegal_triggered_no_clock;
  logic a = 0, b = 0;

  sequence s;
    a ##1 b;
  endsequence

  initial wait (s.triggered);   // illegal
endmodule

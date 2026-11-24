/*
:name: test_event_case_comparison_rejects_integral_zero
:description: Event case inequality accepts the null literal on the left but rejects integral zero on the left
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.5.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: case inequality cannot use an integral zero as the other operand of an event
:expected_stderr_regex: test_event_case_comparison_rejects_integral_zero\.sv:19:(?:\d+:)?[^\n]*(?i:(event[^\n]*(integer|int|operand|compar)|int[^\n]*event|invalid operands))
*/
module test_event_case_comparison_rejects_integral_zero;
  event reference_event;

  initial begin
    if (null !== reference_event) $display("not null");
    if (0 !== reference_event) $display("not zero"); // illegal
  end
endmodule

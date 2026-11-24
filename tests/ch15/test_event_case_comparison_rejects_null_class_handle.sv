/*
:name: test_event_case_comparison_rejects_null_class_handle
:description: Event case equality accepts the null literal but rejects a class handle whose current value is null
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.5.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: case equality compares an event with a class handle rather than an event or the null literal
:expected_stderr_regex: test_event_case_comparison_rejects_null_class_handle\.sv:24:(?:\d+:)?[^\n]*(?i:(event[^\n]*(class|operand|compar)|class[^\n]*event|invalid operands))
*/
module test_event_case_comparison_rejects_null_class_handle;
  class token;
  endclass

  event reference_event;
  token handle = null;

  initial begin
    if (reference_event === null) $display("event is null");
    if (handle === null) $display("class handle is null");
    if (reference_event === handle) $display("same"); // illegal
  end
endmodule

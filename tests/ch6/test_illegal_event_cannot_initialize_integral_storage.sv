/*
:name: test_illegal_event_cannot_initialize_integral_storage
:description: A named event does not provide a value for an integral assignment
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.3.1 6.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a named event is a synchronization object and cannot be read as integral storage
:expected_stderr_regex: test_illegal_event_cannot_initialize_integral_storage\.sv:20:(?:\d+:)?[^\n]*(?i:(?:event|wake)[^\n]*(?:logic|integral|assign|type|convert)|(?:logic|integral|assign|type|convert)[^\n]*(?:event|wake))
*/
module test_illegal_event_cannot_initialize_integral_storage;
  event wake;
  logic [7:0] captured;

  initial begin
    -> wake;
    captured = wake;
    $display("unexpected integral value=%h", captured);
  end
endmodule

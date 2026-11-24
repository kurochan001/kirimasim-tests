/*
:name: test_illegal_event_cannot_store_four_state_bit_value
:description: A named event can be triggered but cannot store a four-state logic value
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.3.1 6.17
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: assignment of a four-state logic value to an event has no value-storage semantics
:expected_stderr_regex: test_illegal_event_cannot_store_four_state_bit_value\.sv:20:(?:\d+:)?[^\n]*(?i:(?:event|wake)[^\n]*(?:logic|assign|type|convert|l-value)|(?:logic|assign|type|convert|l-value)[^\n]*(?:event|wake))
*/
module test_illegal_event_cannot_store_four_state_bit_value;
  event wake;
  logic source = 1'bx;

  initial begin
    -> wake;
    wake = source;
    $display("unexpected assignment to event");
  end
endmodule

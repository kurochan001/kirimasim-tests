/*
:name: test_illegal_property_positional_comma_event_without_parentheses
:description: A comma in an unparenthesized positional property actual separates two arguments
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: without parentheses the second clock becomes an extra positional property argument
:expected_stderr_regex: test_illegal_property_positional_comma_event_without_parentheses\.sv:22:(?:\d+:)?[^\n]*(?i:(?:too many|number of|expected|invalid)[^\n]*(?:argument|actual|event))
*/
`timescale 1ns/1ns
module test_illegal_property_positional_comma_event_without_parentheses;
  bit clock_a, clock_b;
  bit armed = 1;
  property on_tick(event tick, bit enabled);
    @(tick) enabled;
  endproperty

  cover property (on_tick(posedge clock_a, posedge clock_b, armed)); // illegal
endmodule

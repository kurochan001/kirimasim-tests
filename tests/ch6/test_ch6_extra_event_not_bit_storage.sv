/*
:name: test_ch6_extra_event_not_bit_storage
:description: The event type has no storage, so a four-state logic value cannot be assigned to an event variable (IEEE 1800-2023 Section 6.3.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.3.1 6.17
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure assigns the logic value 1'b0 to the event variable e
:expected_stderr_regex: test_ch6_extra_event_not_bit_storage\.sv:23:
*/
// IEEE 1800-2023 §6.3.1: several data types are 4-state, some are 2-state,
// and the event type is an exception: it has no storage. §6.17 makes an event
// variable a handle to a synchronization object that is triggered and waited
// on, not a bit container. Assigning a logic value to it is therefore not an
// assignment to stored bits but a type error, which both oracles report on
// the marked line.

module test_ch6_extra_event_not_bit_storage;
  event e;
  initial e = 1'b0;   // illegal: an event has no storage for a bit value
endmodule

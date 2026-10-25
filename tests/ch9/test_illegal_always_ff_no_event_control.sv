/*
:name: test_illegal_always_ff_no_event_control
:description: An always_ff procedure must contain an event control; one without any is illegal (IEEE 1800-2023 Section 9.2.2.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_ff procedure contains no event control
:expected_stderr_regex: test_illegal_always_ff_no_event_control\.sv:21:
*/
// IEEE 1800-2023 §9.2.2.4: an always_ff procedure contains one and only one
// event control. The procedure below has none: its body is a nonblocking
// assignment without any @ before or inside it.
// The 5.052 release of Verilator accepts the design with a warning.

module test_illegal_always_ff_no_event_control;
  logic d = 0, q;
  always_ff q <= d;   // illegal: always_ff without an event control
endmodule

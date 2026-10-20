/*
:name: test_illegal_pullup_delay
:description: A pullup instance cannot have a delay specification (IEEE 1800-2023 Section 28.3.3)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.3 28.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pullup instance has a delay
:expected_stderr_regex: test_illegal_pullup_delay\.sv:19:
*/
// IEEE 1800-2023 §28.3.3: pullup and pulldown instance declarations shall not
// include delay specifications (28.10).

module test_illegal_pullup_delay;
  wire w;
  pullup #1 (w);   // illegal: a delay on a pullup
endmodule

/*
:name: test_illegal_uwire_two_drivers
:description: A uwire net with two drivers is an error (IEEE 1800-2023 Section 6.6.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the uwire net w has two continuous assignments
:expected_stderr_regex: test_illegal_uwire_two_drivers\.sv:(20|21):
*/
// IEEE 1800-2023 §6.6.2: a uwire net allows a single driver, and connecting a
// bit of it to more than one driver is an error. Both assignments below drive
// w.

module test_illegal_uwire_two_drivers;
  uwire w;
  assign w = 1'b0;     // illegal: the first driver of w
  assign w = 1'b1;     // illegal: and the second
endmodule

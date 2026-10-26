/*
:name: test_illegal_interconnect_strength
:description: an interconnect declaration with a drive strength is illegal
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1 6.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: an interconnect declaration shall not specify drive or charge strength
:expected_stderr_regex: test_illegal_interconnect_strength\.sv:19:
*/
// IEEE 1800-2023 6.7.1: a net declared as interconnect shall not specify
// drive_strength or charge_strength. The marked declaration gives it the
// drive strength pair (strong1, pull0), which a tool has to reject.

module test_illegal_interconnect_strength;
  interconnect (strong1, pull0) w; // illegal: drive strength
endmodule

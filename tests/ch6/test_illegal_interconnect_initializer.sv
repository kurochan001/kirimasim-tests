/*
:name: test_illegal_interconnect_initializer
:description: an interconnect declaration with an assignment expression is illegal
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an interconnect declaration shall not have an assignment expression
:expected_stderr_regex: test_illegal_interconnect_initializer\.sv:19:
*/
// IEEE 1800-2023 6.7.1: a net declared as interconnect shall not have
// assignment expressions. The marked declaration attaches one, which a tool
// has to reject.

module test_illegal_interconnect_initializer;
  interconnect w = 1'b0; // illegal: assignment in the declaration
endmodule

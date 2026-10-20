/*
:name: test_illegal_default_nettype_none_assign
:description: With `default_nettype none, an undeclared name on the left of a continuous assignment is an error (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: b is not declared and `default_nettype none forbids an implicit net
:expected_stderr_regex: test_illegal_default_nettype_none_assign\.sv:21:
*/
// IEEE 1800-2023 §22.8: after `default_nettype none, every net has to be
// declared, so a name that would otherwise become an implicit net is an error.
// b on the left of the continuous assignment is not declared.

`default_nettype none
module test_illegal_default_nettype_none_assign;
  wire a = 1'b1;
  assign b = a;        // illegal: b is not declared
endmodule
`default_nettype wire

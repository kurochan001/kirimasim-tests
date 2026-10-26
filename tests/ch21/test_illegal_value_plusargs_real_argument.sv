/*
:name: test_illegal_value_plusargs_real_argument
:description: $value$plusargs is given a real as its first argument (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first argument of $value$plusargs is the real variable r
:expected_stderr_regex: test_illegal_value_plusargs_real_argument\.sv:20:
*/
// The first argument of $value$plusargs is a string or an integral
// variable that is interpreted as a string. A real value is neither.

module test_illegal_value_plusargs_real_argument;
  real r = 1.0;
  int v;
  initial $display("%0d", $value$plusargs(r, v));   // illegal: real
endmodule

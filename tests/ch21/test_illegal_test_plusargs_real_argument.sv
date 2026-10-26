/*
:name: test_illegal_test_plusargs_real_argument
:description: $test$plusargs is given a real instead of a string or integral value (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument of $test$plusargs is the real variable r
:expected_stderr_regex: test_illegal_test_plusargs_real_argument\.sv:19:
*/
// The argument of $test$plusargs is a string or an integral variable
// that is interpreted as a string. A real value is neither.

module test_illegal_test_plusargs_real_argument;
  real r = 1.0;
  initial $display("%0d", $test$plusargs(r));   // illegal: real
endmodule

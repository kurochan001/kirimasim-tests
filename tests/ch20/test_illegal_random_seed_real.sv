/*
:name: test_illegal_random_seed_real
:description: the $random seed argument is a real variable (IEEE 1800-2023 Section 20.14.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the seed argument of $random is the real variable seed
:expected_stderr_regex: test_illegal_random_seed_real\.sv:19:
*/
// The optional seed argument of $random shall be an integral variable
// that controls the stream it generates. The argument here is real.

module test_illegal_random_seed_real;
  real seed = 1.0;
  initial $display("%0d", $random(seed));   // illegal: real seed
endmodule

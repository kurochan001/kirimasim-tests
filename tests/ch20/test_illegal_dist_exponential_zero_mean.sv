/*
:name: test_illegal_dist_exponential_zero_mean
:description: a distribution generator gets a mean that is not greater than zero (IEEE 1800-2023 Section 20.14.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.14.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the mean argument of $dist_exponential is 0
:expected_stderr_regex: test_illegal_dist_exponential_zero_mean\.sv:19:
*/
// The mean of $dist_exponential shall be greater than zero. The call
// here passes 0 as the mean.

module test_illegal_dist_exponential_zero_mean;
  int seed = 1;
  initial $display("%0d", $dist_exponential(seed, 0));   // illegal: mean 0
endmodule

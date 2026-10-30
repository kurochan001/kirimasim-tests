/*
:name: test_illegal_dist_exponential_zero_mean
:description: a distribution generator gets a mean that is not greater than zero, and the algorithm of Annex N answers with a warning and the value 0 (IEEE 1800-2023 Section 20.14.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: 0
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|\berror\b)
*/
// The mean of $dist_exponential shall be greater than zero (20.14.2). The call
// here passes 0 as the mean. The standard does not make such a call an
// illegal design: Annex N, which defines the algorithm of the distribution
// functions, checks the mean when the function runs, prints a warning when it
// is not positive and returns 0. The test therefore checks the value 0 and
// that the run reports the problem; the form and the severity word of the
// message are left to the tool, so a warning or an error is accepted.

module test_illegal_dist_exponential_zero_mean;
  int seed = 1;
  initial $display("%0d", $dist_exponential(seed, 0));   // mean 0
endmodule

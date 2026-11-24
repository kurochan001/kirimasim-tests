/*
:name: test_distribution_diagnoses_invalid_exponential_mean
:description: A random distribution diagnoses a nonpositive parameter for exponential mean
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_distribution_diagnoses_invalid_exponential_mean.expected
:expected_stdout_icarus: @test_distribution_diagnoses_invalid_exponential_mean.icarus.expected
:expected_stderr_regex: (?im)^(?=[^\n]*(?:error|warning|fatal))(?=[^\n]*exponential)(?=[^\n]*(?:mean|argument|nonpositive|positive|invalid|must be >))[^\n]+
*/
module test_distribution_diagnoses_invalid_exponential_mean;
  int seed, ignored;

  initial begin
    seed = 417;
    $display("checking distribution parameter");
    ignored = $dist_exponential(seed, 0);
  end
endmodule

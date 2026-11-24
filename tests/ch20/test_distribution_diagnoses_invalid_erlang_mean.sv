/*
:name: test_distribution_diagnoses_invalid_erlang_mean
:description: A random distribution diagnoses a nonpositive parameter for erlang mean
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_distribution_diagnoses_invalid_erlang_mean.expected
:expected_stderr_regex: (?im)^(?=[^\n]*(?:error|warning|fatal))(?=[^\n]*erlang)(?=[^\n]*(?:mean|argument|nonpositive|positive|invalid|must be >))[^\n]+
*/
module test_distribution_diagnoses_invalid_erlang_mean;
  int seed, ignored;

  initial begin
    seed = 417;
    $display("checking distribution parameter");
    ignored = $dist_erlang(seed, 2, 0);
  end
endmodule

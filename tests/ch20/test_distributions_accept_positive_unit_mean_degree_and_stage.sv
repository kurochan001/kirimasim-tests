/*
:name: test_distributions_accept_positive_unit_mean_degree_and_stage
:description: All five affected distributions accept one as the smallest positive parameter
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_distributions_accept_positive_unit_mean_degree_and_stage.expected
*/
module test_distributions_accept_positive_unit_mean_degree_and_stage;
  int seed, exponential, poisson, chi_square, t_sample, erlang;

  initial begin
    seed = 417;
    exponential = $dist_exponential(seed, 1);
    poisson = $dist_poisson(seed, 1);
    chi_square = $dist_chi_square(seed, 1);
    t_sample = $dist_t(seed, 1);
    erlang = $dist_erlang(seed, 1, 1);
    $display("positive boundary calls completed=%0d",
             exponential >= 0 && poisson >= 0 && chi_square >= 0 &&
             erlang >= 0 && !$isunknown(t_sample));
  end
endmodule

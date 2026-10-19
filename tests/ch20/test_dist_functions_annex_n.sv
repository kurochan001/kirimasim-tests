/*
:name: test_dist_functions_annex_n
:description: The probabilistic distribution functions and $random return the values that the algorithm of Annex N gives for each seed, and update the seed as it does (IEEE 1800-2023 Section 20.14.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 20.14.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_functions_annex_n.expected
*/
// IEEE 1800-2023 §20.14.2: the seed argument is inout, and the same seed always
// gives the same value. Annex N defines the algorithm by C code: a linear
// congruential generator on the 32-bit seed, from which $dist_uniform,
// $dist_normal, $dist_exponential, $dist_poisson, $dist_chi_square, $dist_t
// and $dist_erlang are derived, and $random(seed) is $dist_uniform over the
// whole integer range (20.14.1). The expected values were computed with that C
// code, taking its long as the 32-bit integer of the seed. Each function is
// called twice or three times in a row from its own starting seed, and the
// value and the updated seed are printed.

module test_dist_functions_annex_n;
  integer seed, v;

  initial begin
    seed = 1;
    repeat (3) begin
      v = $dist_uniform(seed, 0, 99);
      $display("uniform(0, 99) = %0d, seed = %0d", v, seed);
    end
    seed = -5;
    repeat (2) begin
      v = $dist_uniform(seed, -10, 10);
      $display("uniform(-10, 10) = %0d, seed = %0d", v, seed);
    end
    seed = 7;
    repeat (2) begin
      v = $dist_normal(seed, 100, 10);
      $display("normal(100, 10) = %0d, seed = %0d", v, seed);
    end
    seed = 11;
    repeat (2) begin
      v = $dist_exponential(seed, 50);
      $display("exponential(50) = %0d, seed = %0d", v, seed);
    end
    seed = 13;
    repeat (2) begin
      v = $dist_poisson(seed, 5);
      $display("poisson(5) = %0d, seed = %0d", v, seed);
    end
    seed = 17;
    repeat (2) begin
      v = $dist_chi_square(seed, 3);
      $display("chi_square(3) = %0d, seed = %0d", v, seed);
    end
    seed = 19;
    repeat (2) begin
      v = $dist_t(seed, 4);
      $display("t(4) = %0d, seed = %0d", v, seed);
    end
    seed = 23;
    repeat (2) begin
      v = $dist_erlang(seed, 3, 30);
      $display("erlang(3, 30) = %0d, seed = %0d", v, seed);
    end
    seed = 0;
    repeat (2) begin
      v = $random(seed);
      $display("random = %0d, seed = %0d", v, seed);
    end
  end
endmodule

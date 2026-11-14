/*
:name: test_dist_annex_n_random_uniform_normal_exponential
:description: $random with a seed, $dist_uniform, $dist_normal and $dist_exponential give the values and the new seeds of the algorithm that the standard defines in Annex N, so the random sets are the same in every implementation, here from a seed of 0, negative seeds, negative bounds and means and the largest integer as the end of a range (IEEE 1800-2023 Section 20.14)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_annex_n_random_uniform_normal_exponential.expected
*/
// IEEE 1800-2023 §20.14: the algorithm that generates the values of $random
// and of the $dist_ functions is part of the standard, given as C code in
// Annex N, so that the random sets are the same in different implementations.
// N.1: $random(seed) is rtl_dist_uniform(seed, LONG_MIN, LONG_MAX), and
// $dist_uniform, $dist_normal and $dist_exponential are rtl_dist_uniform,
// rtl_dist_normal and rtl_dist_exponential. N.2: every draw replaces the seed
// by 69069 * seed + 1, a seed of 0 is first replaced by 259341593, and the
// value is derived from the new seed.
//
// The seed is a 32-bit int and the C long is taken as 32 bits, the width of
// $random (20.14.1). The expected values were computed with the C code of
// N.2 under that reading. The test draws three values in a row for each
// case: $random from the seeds 0, 42 and -7; $dist_uniform over -1000 to
// 1000, and over 0 to 2147483647, which takes the branch of N.2 for an end
// equal to LONG_MAX; $dist_normal with mean -50 and standard deviation 25;
// and $dist_exponential with mean 1000. It prints each value and the seed.
// No value is within 0.03 of the point where N.2 truncates or rounds it.
// Icarus Verilog 13.0 prints the expected output. $random(seed) gives other
// values and seeds in the 5.054 release of Verilator, as in 5.052.

module test_dist_annex_n_random_uniform_normal_exponential;
  int seed, v;
  int starts[3] = '{0, 42, -7};

  initial begin
    foreach (starts[i]) begin
      seed = starts[i];
      repeat (3) begin
        v = $random(seed);
        $display("random(seed from %0d) = %0d, seed = %0d", starts[i], v, seed);
      end
    end
    seed = 99;
    repeat (3) begin
      v = $dist_uniform(seed, -1000, 1000);
      $display("uniform(-1000, 1000) = %0d, seed = %0d", v, seed);
    end
    seed = 123;
    repeat (3) begin
      v = $dist_uniform(seed, 0, 2147483647);
      $display("uniform(0, 2147483647) = %0d, seed = %0d", v, seed);
    end
    seed = 2024;
    repeat (3) begin
      v = $dist_normal(seed, -50, 25);
      $display("normal(-50, 25) = %0d, seed = %0d", v, seed);
    end
    seed = 31;
    repeat (3) begin
      v = $dist_exponential(seed, 1000);
      $display("exponential(1000) = %0d, seed = %0d", v, seed);
    end
  end
endmodule

/*
:name: test_dist_poisson_counts_products_above_exp
:description: $dist_poisson returns how many times the running product of uniform samples stays above exp(-mean) before it falls to or below it, unchanged, so each call takes one draw more than the value it returns (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_poisson_counts_products_above_exp.expected
*/
// IEEE 1800-2023 §N.1: $dist_poisson computes what rtl_dist_poisson of N.2
// computes. N.2: for a positive mean the internal poisson routine sets a
// count to 0, p to exp(-mean) and q to one uniform sample between 0 and 1;
// while p is less than q it increments the count and multiplies q by a new
// sample, and then returns the count, which rtl_dist_poisson returns as it
// is. So a result n always takes n + 1 draws, each of which advances the seed
// once by 69069 * s + 1; the design counts these steps. The seed and the
// arguments are 32-bit integers (20.14.1, 20.14.2), so the C long is taken as
// 32 bits.
//
// Six seeds are used with the means 1, 4 and 20. For instance, from the seed
// 2026 with the mean 4, p is 0.0183, the first sample is 0.0326, above p, and
// the product with the second sample, 0.328, is 0.0107, below p, so the
// result is 1 after two draws. Counting from 1, using a new sample in place
// of the product, or stopping when the product equals or exceeds p changes
// the results and the number of draws. The values were computed with the C
// code of N.2.

module test_dist_poisson_counts_products_above_exp;
  integer seed, v;
  integer starts [6] = '{1, 12345, 2026, -77, 424242, 31337};
  integer means [3] = '{1, 4, 20};

  function automatic int draws(integer from, integer to);
    integer s = from;
    for (int n = 0; n <= 60; n++) begin
      if (s == to) return n;
      s = s * 69069 + 1;
    end
    return -1;
  endfunction

  initial begin
    foreach (starts[i])
      foreach (means[j]) begin
        seed = starts[i];
        v = $dist_poisson(seed, means[j]);
        $display("poisson(%0d) from %0d = %0d, seed %0d, draws %0d", means[j], starts[i], v,
                 seed, draws(starts[i], seed));
      end
  end
endmodule

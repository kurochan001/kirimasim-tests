/*
:name: test_dist_uniform_full_range_and_seeded_random
:description: $random with a seed and $dist_uniform over the whole 32-bit range both compute the full-range branch of rtl_dist_uniform, so they give the same values and seeds, those of Annex N (IEEE 1800-2023 Section N.1, N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.1 20.14.2 N.1 N.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_uniform_full_range_and_seeded_random.expected
*/
// IEEE 1800-2023 §N.1: $random(seed) is rtl_dist_uniform of N.2 with the
// smallest and the largest long as its bounds, and $dist_uniform is
// rtl_dist_uniform. $random returns a 32-bit signed number (20.14.1) and the
// arguments are integer values (20.14.2), so the C long is taken as 32 bits:
// the bounds are -2147483648 and 2147483647. N.2: for these bounds the real
// sample is shifted up by 2**31, divided by 2**32 - 1, multiplied by 2**32 and
// shifted down by 2**31, and is then truncated when it is not negative, or
// truncated after 1 is subtracted when it is negative.
//
// For each of four starting seeds, $random and $dist_uniform with the bounds
// -2147483648 and 2147483647 are called three times with two copies of the
// seed. Both give the same values and the same new seeds, which are those of
// the C code of N.2; a negative result truncated without the subtraction of 1
// would be one greater. None of the draws has all 23 top bits of the new seed
// set, for which the scaled sample would not fit in 32 bits.
//
// In Verilator 5.052, $random(seed) uses its own generator and gives other
// values and seeds, so only Icarus Verilog 13.0 is named in :oracle:.

module test_dist_uniform_full_range_and_seeded_random;
  integer seed_r, seed_u, r, u;
  integer starts [4] = '{5, -1, 123456789, 2026};

  initial begin
    foreach (starts[i]) begin
      seed_r = starts[i];
      seed_u = starts[i];
      repeat (3) begin
        r = $random(seed_r);
        u = $dist_uniform(seed_u, -2147483648, 2147483647);
        $display("from %0d: $random = %0d, seed %0d; $dist_uniform = %0d, seed %0d", starts[i],
                 r, seed_r, u, seed_u);
      end
    end
  end
endmodule

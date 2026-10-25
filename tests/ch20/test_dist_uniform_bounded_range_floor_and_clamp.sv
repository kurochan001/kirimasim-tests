/*
:name: test_dist_uniform_bounded_range_floor_and_clamp
:description: $dist_uniform with an end below the largest integer draws over the end plus one, rounds a negative sample down by truncating it minus one, and clamps a sample at the end plus one back to the end (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_uniform_bounded_range_floor_and_clamp.expected
*/
// IEEE 1800-2023 §N.1: $dist_uniform computes what rtl_dist_uniform of N.2
// computes. N.2: when the end is not the largest integer, the end is first
// incremented and a real sample r is drawn between the start and that
// incremented end; a sample that is not negative is truncated, a negative one
// is truncated after 1 is subtracted, and the result is then clamped to the
// start and to the incremented end minus 1. The seed and the arguments are
// 32-bit integers (20.14.1, 20.14.2), so the C long is taken as 32 bits.
//
// Eight calls with the bounds -10 and 10 from the seed 12345 include samples
// between -6 and -5, -5 and -4, ... and -1 and 0 (-0.27), which give -6, -5,
// -3, -2 and -1, where plain truncation would give one more. From the seed
// -77 the sample is 10.97, so the end 10 itself is returned. The seed
// 648451823 advances to 100, whose top 23 bits are 0, which gives the
// smallest sample, -9.9999975, and so -10. The seed -1271221770 advances to
// -1, whose top 23 bits are all 1: the corrected sample is then a little
// above the incremented end (10.0000012 for the bounds 0 and 9, -9.9999988
// for -20 and -11), and the clamp gives the end, 9 and -11. A sample can
// never fall below the start, so the clamp to the start does not act here.
// The values were computed with the C code of N.2.

module test_dist_uniform_bounded_range_floor_and_clamp;
  integer seed, v;

  initial begin
    seed = 12345;
    repeat (8) begin
      v = $dist_uniform(seed, -10, 10);
      $display("uniform(-10, 10) = %0d, seed %0d", v, seed);
    end
    seed = -77;
    v = $dist_uniform(seed, -10, 10);
    $display("from -77: uniform(-10, 10) = %0d, seed %0d", v, seed);
    seed = 648451823;
    v = $dist_uniform(seed, -10, 10);
    $display("from 648451823: uniform(-10, 10) = %0d, seed %0d", v, seed);
    seed = -1271221770;
    v = $dist_uniform(seed, 0, 9);
    $display("from -1271221770: uniform(0, 9) = %0d, seed %0d", v, seed);
    seed = -1271221770;
    v = $dist_uniform(seed, -20, -11);
    $display("from -1271221770: uniform(-20, -11) = %0d, seed %0d", v, seed);
  end
endmodule

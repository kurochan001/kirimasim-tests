/*
:name: test_dist_zero_seed_replaced_before_update
:description: A seed of 0 is replaced by 259341593 before the generator of Annex N advances it, whether the user sets it to 0 or a call leaves it at 0, and for $dist_uniform, $dist_exponential and $dist_normal alike (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_zero_seed_replaced_before_update.expected
*/
// IEEE 1800-2023 §N.1: the distribution functions of 20.14.2 compute what the
// C code of N.2 computes. N.2: every draw goes through one internal routine
// that, when the seed is 0, first sets it to 259341593, and then replaces the
// seed s by 69069 * s + 1. The seed and the arguments are 32-bit integers
// (20.14.1, 20.14.2), so the C long is taken as 32 bits and the update wraps
// modulo 2**32.
//
// So a call with seed 0 gives the same value and the same new seed as a call
// with seed 259341593, whose new seed is -1844104698; without the
// replacement the new seed would be 69069 * 0 + 1 = 1 and $dist_uniform
// would give 0. The seed 1511872763 is chosen so that its new seed is 0; the
// next call then starts again from 259341593. $dist_exponential and
// $dist_normal (two draws) from seed 0 show that the replacement is in the
// routine that all of them share. The values were computed with the C code of
// N.2.

module test_dist_zero_seed_replaced_before_update;
  integer seed, v;

  initial begin
    seed = 0;
    v = $dist_uniform(seed, 0, 999);
    $display("uniform(0, 999) from seed 0: %0d, new seed %0d", v, seed);
    seed = 259341593;
    v = $dist_uniform(seed, 0, 999);
    $display("uniform(0, 999) from seed 259341593: %0d, new seed %0d", v, seed);
    seed = 1511872763;
    v = $dist_uniform(seed, 0, 999);
    $display("uniform(0, 999) from seed 1511872763: %0d, new seed %0d", v, seed);
    v = $dist_uniform(seed, 0, 999);
    $display("uniform(0, 999) again: %0d, new seed %0d", v, seed);
    seed = 0;
    v = $dist_exponential(seed, 1000);
    $display("exponential(1000) from seed 0: %0d, new seed %0d", v, seed);
    seed = 0;
    v = $dist_normal(seed, 0, 1000);
    $display("normal(0, 1000) from seed 0: %0d, new seed %0d", v, seed);
    seed = 259341593;
    v = $dist_normal(seed, 0, 1000);
    $display("normal(0, 1000) from seed 259341593: %0d, new seed %0d", v, seed);
  end
endmodule

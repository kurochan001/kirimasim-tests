/*
:name: test_dist_uniform_start_not_below_end_keeps_seed
:description: $dist_uniform with a start that is not below the end returns the start and leaves the seed unchanged, even a seed of 0, while a start below the end draws and advances the seed (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_uniform_start_not_below_end_keeps_seed.expected
*/
// IEEE 1800-2023 §N.1: $dist_uniform computes what rtl_dist_uniform of N.2
// computes. N.2: rtl_dist_uniform first returns its start argument when the
// start is greater than or equal to the end, before it draws anything, so the
// seed is not changed; in particular a seed of 0 stays 0, because the
// replacement of 0 by 259341593 happens only in the drawing routine. The seed
// and the arguments are 32-bit integers (20.14.1, 20.14.2), so the C long is
// taken as 32 bits.
//
// From the seed 12345, the calls with equal bounds, with the end below the
// start and with the largest start and the smallest end return the start and
// print the seed 12345 each time. The call with bounds 7 and 8 then draws and
// gives the new seed 69069 * 12345 + 1 = 852656806. From the seed 0, the call
// with bounds 5 and 5 leaves 0, and the next call with bounds 5 and 6 draws
// from 259341593 and gives -1844104698. The values were computed with the C
// code of N.2.

module test_dist_uniform_start_not_below_end_keeps_seed;
  integer seed, v;

  initial begin
    seed = 12345;
    v = $dist_uniform(seed, 7, 7);
    $display("uniform(7, 7) = %0d, seed %0d", v, seed);
    v = $dist_uniform(seed, 10, -3);
    $display("uniform(10, -3) = %0d, seed %0d", v, seed);
    v = $dist_uniform(seed, 2147483647, -2147483648);
    $display("uniform(2147483647, -2147483648) = %0d, seed %0d", v, seed);
    v = $dist_uniform(seed, 7, 8);
    $display("uniform(7, 8) = %0d, seed %0d", v, seed);
    seed = 0;
    v = $dist_uniform(seed, 5, 5);
    $display("uniform(5, 5) from seed 0 = %0d, seed %0d", v, seed);
    v = $dist_uniform(seed, 5, 6);
    $display("uniform(5, 6) = %0d, seed %0d", v, seed);
  end
endmodule

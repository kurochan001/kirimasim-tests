/*
:name: test_dist_exponential_one_draw_log_rounding
:description: $dist_exponential takes one uniform sample n between 0 and 1, returns -log(n) times the mean rounded half away from zero, and so can return a negative value when the corrected sample is just above 1 (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_exponential_one_draw_log_rounding.expected
*/
// IEEE 1800-2023 §N.1: $dist_exponential computes what rtl_dist_exponential of
// N.2 computes. N.2: for a positive mean the internal exponential routine draws
// one uniform sample n between 0 and 1 and returns -log(n) * mean when n is
// not 0; rtl_dist_exponential then rounds: a value that is not negative is
// truncated after 0.5 is added, a negative one is negated, rounded the same
// way and negated back. The seed and the arguments are 32-bit integers
// (20.14.1, 20.14.2), so the C long is taken as 32 bits.
//
// Every call advances the seed by one step, which the design counts. The
// unrounded values 1616.84, 1.955, 1.694 and 6.85 give 1617, 2, 2 and 7, where
// truncation would give one less. The seed 648451823 advances to 100, whose
// top 23 bits are 0, so n is 2**-23, the smallest sample, and the mean 10
// gives 159.4. The seed -1271221770 advances to -1, whose top 23 bits are
// all 1: the corrected sample is then 1 + 2**-23 - 2**-46, a little above 1,
// so -log(n) is about -1.19e-7. With the mean 1000 this rounds to 0, and with
// the mean 2147483647 it is -255.99995, which rounds to -256, where adding
// 0.5 without regard to the sign would give -255. No sample is exactly 0, so
// the branch for n equal to 0 is not reached. The values were computed with
// the C code of N.2.

module test_dist_exponential_one_draw_log_rounding;
  integer seed, v;

  function automatic int draws(integer from, integer to);
    integer s = from;
    for (int n = 0; n <= 20; n++) begin
      if (s == to) return n;
      s = s * 69069 + 1;
    end
    return -1;
  endfunction

  task automatic check(integer from, integer mean);
    seed = from;
    v = $dist_exponential(seed, mean);
    $display("exponential(%0d) from %0d = %0d, seed %0d, draws %0d", mean, from, v, seed,
             draws(from, seed));
  endtask

  initial begin
    check(1, 10);
    check(1, 1000);
    check(12345, 1000);
    check(2026, 10);
    check(-77, 10);
    check(-77, 1000);
    check(424242, 10);
    check(987654321, 10);
    check(31337, 10);
    check(31337, 1000);
    check(648451823, 10);
    check(-1271221770, 1000);
    check(-1271221770, 2147483647);
  end
endmodule

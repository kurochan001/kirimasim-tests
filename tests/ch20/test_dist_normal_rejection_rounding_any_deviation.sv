/*
:name: test_dist_normal_rejection_rounding_any_deviation
:description: $dist_normal draws pairs of uniform samples until one falls strictly inside the unit circle, scales the first sample of that pair by the deviation and adds the mean, and rounds half away from zero, also for a zero or negative deviation (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_normal_rejection_rounding_any_deviation.expected
*/
// IEEE 1800-2023 §N.1: $dist_normal computes what rtl_dist_normal of N.2
// computes. N.2: the internal normal routine draws two uniform samples v1 and
// v2 between -1 and 1, in that order, and draws a new pair while
// s = v1 * v1 + v2 * v2 is not strictly between 0 and 1; it then returns
// v1 * sqrt(-2 * log(s) / s) * deviation + mean. rtl_dist_normal checks
// neither argument and rounds the result: a value that is not negative is
// truncated after 0.5 is added, a negative one is negated, rounded the same
// way and negated back. Each draw advances the seed once by 69069 * s + 1, so
// the number of draws is the number of such steps from the old seed to the
// new one, which the design counts. The seed and the arguments are 32-bit
// integers (20.14.1, 20.14.2), so the C long is taken as 32 bits.
//
// With the mean 0 and the deviation 10 the unrounded results are 2.96, -5.59,
// -4.95, 15.62, -7.45, -0.77 and -0.44: so 3, -6, -5, 16, -7, -1 and 0, where
// truncation would give 2, -5, -4, 15, -7, 0 and 0, and adding 0.5 without
// regard to the sign would give -5 for -5.59 and -4 for -4.95. The seeds
// 3025058, 2652865, 47514 and 498897 have their first one, two or three pairs
// outside the circle, so they take 8, 6, 4 and 4 draws instead of 2. The
// deviation 0 still draws the same eight samples and gives the mean 25; the
// deviation -10 gives the opposite of the result for 10; the mean -100 and
// the mean 1000 with the deviation 300 shift and scale the same samples. A
// value of s equal to 0 cannot occur, as no draw gives exactly 0. The values
// were computed with the C code of N.2.

module test_dist_normal_rejection_rounding_any_deviation;
  integer seed, start, v;

  function automatic int draws(integer from, integer to);
    integer s = from;
    for (int n = 0; n <= 20; n++) begin
      if (s == to) return n;
      s = s * 69069 + 1;
    end
    return -1;
  endfunction

  task automatic check(integer from, integer mean, integer deviation);
    seed = from;
    v = $dist_normal(seed, mean, deviation);
    $display("normal(%0d, %0d) from %0d = %0d, seed %0d, draws %0d", mean, deviation, from, v,
             seed, draws(from, seed));
  endtask

  initial begin
    check(104729, 0, 10);
    check(1256748, 0, 10);
    check(3025058, 0, 10);
    check(2652865, 0, 10);
    check(47514, 0, 10);
    check(4189160, 0, 10);
    check(498897, 0, 10);
    check(3025058, 25, 0);
    check(1256748, 0, -10);
    check(2652865, -100, 10);
    check(104729, 1000, 300);
  end
endmodule

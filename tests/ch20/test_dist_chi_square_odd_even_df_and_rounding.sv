/*
:name: test_dist_chi_square_odd_even_df_and_rounding
:description: $dist_chi_square starts from a squared standard-normal draw for an odd degree of freedom or from zero for an even one, adds one doubled unit exponential sample per pair up to the degree of freedom, and rounds to the nearest integer (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_chi_square_odd_even_df_and_rounding.expected
*/
// IEEE 1800-2023 §N.1 and §20.14.2: $dist_chi_square computes what
// rtl_dist_chi_square of N.2 computes. N.2: the chi-square helper starts with
// the square of one standard-normal sample when the degree of freedom is odd
// and with zero when it is even, then adds 2 * exponential(seed, 1) once for
// each even step from 2 up to the degree of freedom; rtl_dist_chi_square then
// rounds the sum to the nearest integer, truncating after 0.5 is added when
// the sum is not negative.
//
// A standard-normal sample is a pair of uniform draws, repeated while the pair
// is on or outside the unit circle, and exponential(seed, 1) is one uniform
// draw. Each draw advances the seed once by 69069 * seed + 1, so the design
// counts those steps: an odd degree of freedom takes an even count for the
// normal sample plus one per pair, an even one only one per pair. The seed and
// the arguments are 32-bit integers (20.14.1, 20.14.2), so the C long is taken
// as 32 bits.
//
// The degrees 1, 3, 5 and 7 put the normal square first: the seed 45 with 1
// gives 6.75, which rounds to 7, and the seed 4 with 1 gives 2.81, which
// rounds to 3, while starting from zero would give 0. The even degrees 2, 4, 8
// and 10 put no normal draw first: the seed 2 with 2 gives 20.69 from one
// draw, and the seed 1 with 10 gives 30.65 from five, while a normal square
// first would add an even number of draws and a larger value. One, two, three
// and five doubled exponential samples are added for the degrees 2, 4, 7 and
// 10; a loop that stopped before the degree of freedom or ran once more would
// change the count and the value. Rounding down appears at 17.47, which gives
// 17. The values were computed with the C code of N.2.

module test_dist_chi_square_odd_even_df_and_rounding;
  integer seed, v;

  function automatic int draws(integer from, integer to);
    integer s = from;
    for (int n = 0; n <= 20; n++) begin
      if (s == to) return n;
      s = s * 69069 + 1;
    end
    return -1;
  endfunction

  task automatic check(integer from, integer df);
    seed = from;
    v = $dist_chi_square(seed, df);
    $display("chi_square(%0d) from %0d = %0d, seed %0d, draws %0d", df, from, v, seed,
             draws(from, seed));
  endtask

  initial begin
    check(4, 1);
    check(15, 1);
    check(45, 1);
    check(2, 2);
    check(10, 2);
    check(11, 3);
    check(12, 3);
    check(2, 4);
    check(10, 4);
    check(41, 5);
    check(4, 7);
    check(15, 8);
    check(1, 10);
  end
endmodule

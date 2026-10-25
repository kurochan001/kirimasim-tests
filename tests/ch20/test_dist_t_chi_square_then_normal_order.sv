/*
:name: test_dist_t_chi_square_then_normal_order
:description: $dist_t draws a chi-square sample for its degree of freedom, divides by the degree of freedom, takes the square root, then divides one standard-normal sample by that root and rounds half away from zero, so negative quotients round down (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_t_chi_square_then_normal_order.expected
*/
// IEEE 1800-2023 §N.1 and §20.14.2: $dist_t computes what rtl_dist_t of N.2
// computes. N.2: the t helper first draws a chi-square sample for the degree
// of freedom, divides it by the degree of freedom and takes the square root,
// then draws one standard-normal sample and divides it by that root;
// rtl_dist_t rounds the quotient to the nearest integer, truncating after 0.5
// is added when the quotient is not negative, and otherwise negating it,
// truncating after 0.5 is added and negating the result.
//
// The order is observable because each helper takes its draws from the shared
// seed: the chi-square sample is drawn first, and its draws include a normal
// pair for an odd degree and one uniform draw per pair for the doubled unit
// exponential samples. The design counts those advances of the seed by
// 69069 * seed + 1. The seed and the arguments are 32-bit integers
// (20.14.1, 20.14.2), so the C long is taken as 32 bits.
//
// From the seed 14 with the degree 1 the chi-square sample is 2.0754 from four
// draws, its root is 1.4406, and the normal sample -0.9680 from two more draws
// gives -0.6719, which rounds to -1: plain truncation or adding 0.5 without
// regard to the sign would give 0. The seed 25 with 1 gives -4.7347, which
// rounds to -5, where the same mistakes give -4. From the seed 8 with 1 the
// quotient is 3.8703, which rounds to 4 after ten draws, six of them for the
// final normal sample. The seed 6 with 3 takes seven draws for its chi-square
// sample of 0.2769 and four for its normal sample of 0.2850, giving 0.9381 and
// so 1; drawing the normal first would give another quotient. The seed 11 with
// the degree 1 gives -0.4021, which rounds to 0, and the seed 28 with 1 gives
// -1.1845, which rounds to -1; rounding towards minus infinity would give -1
// for the first and -2 for the second. The seed 35 with the degrees 1, 2, 3, 4
// and 10 gives -2, -1, -1, 0 and 0, so the division by the degree and the
// square root are visible, and the quotient 0.2587 with the degree 4 rounds
// down to 0. The values were computed with the C code of N.2.

module test_dist_t_chi_square_then_normal_order;
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
    v = $dist_t(seed, df);
    $display("t(%0d) from %0d = %0d, seed %0d, draws %0d", df, from, v, seed,
             draws(from, seed));
  endtask

  initial begin
    check(14, 1);
    check(25, 1);
    check(8, 1);
    check(11, 1);
    check(28, 1);
    check(35, 1);
    check(6, 2);
    check(42, 2);
    check(35, 2);
    check(35, 3);
    check(6, 3);
    check(2, 4);
    check(4, 4);
    check(35, 4);
    check(41, 10);
    check(9, 10);
  end
endmodule

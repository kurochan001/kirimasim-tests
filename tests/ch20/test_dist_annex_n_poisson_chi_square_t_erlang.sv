/*
:name: test_dist_annex_n_poisson_chi_square_t_erlang
:description: $dist_poisson, $dist_chi_square with an odd and an even degree of freedom, $dist_t and $dist_erlang give the values and the new seeds of the algorithm that the standard defines in Annex N, so the random sets are the same in every implementation (IEEE 1800-2023 Section 20.14)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_annex_n_poisson_chi_square_t_erlang.expected
*/
// IEEE 1800-2023 §20.14: the algorithm that generates the values of the $dist_
// functions is part of the standard, given as C code in Annex N, so that the
// random sets are the same in different implementations. N.1: $dist_poisson,
// $dist_chi_square, $dist_t and $dist_erlang are rtl_dist_poisson,
// rtl_dist_chi_square, rtl_dist_t and rtl_dist_erlang of N.2. There, poisson
// counts the uniform draws after the first that it takes for their product to
// fall to exp(-mean); chi_square adds the square of a normal draw for an odd
// degree of freedom and twice an exponential draw for each pair of degrees; t
// divides a normal draw by the root of a chi_square draw over its degree;
// erlang takes the logarithm of the product of k uniform draws. The result is
// rounded half away from zero, and each draw advances the seed.
//
// The seed is a 32-bit int and the C long is taken as 32 bits, the width of
// $random (20.14.1). The expected values were computed with the C code of
// N.2 under that reading. The test draws two or three values in a row for
// $dist_poisson with mean 20, $dist_chi_square with 1 and 4 degrees of
// freedom, $dist_t with 1 and 6, and $dist_erlang with k 3 and mean 100, and
// prints each value and the seed. No real result is within 0.05 of a point
// halfway between two integers, where N.2 rounds. Icarus Verilog 13.0 and
// the 5.054 release of Verilator print the expected output.

module test_dist_annex_n_poisson_chi_square_t_erlang;
  int seed, v;

  initial begin
    seed = 5;
    repeat (3) begin
      v = $dist_poisson(seed, 20);
      $display("poisson(20) = %0d, seed = %0d", v, seed);
    end
    seed = 28;
    repeat (2) begin
      v = $dist_chi_square(seed, 1);
      $display("chi_square(1) = %0d, seed = %0d", v, seed);
    end
    seed = 78;
    repeat (2) begin
      v = $dist_chi_square(seed, 4);
      $display("chi_square(4) = %0d, seed = %0d", v, seed);
    end
    seed = 3;
    repeat (2) begin
      v = $dist_t(seed, 1);
      $display("t(1) = %0d, seed = %0d", v, seed);
    end
    seed = 24;
    repeat (2) begin
      v = $dist_t(seed, 6);
      $display("t(6) = %0d, seed = %0d", v, seed);
    end
    seed = 1001;
    repeat (3) begin
      v = $dist_erlang(seed, 3, 100);
      $display("erlang(3, 100) = %0d, seed = %0d", v, seed);
    end
  end
endmodule

/*
:name: test_dist_erlang_stage_count_and_product_rounding
:description: $dist_erlang multiplies exactly k uniform samples between 0 and 1 from one, returns minus the mean times the logarithm of that product divided by k, and rounds half away from zero, so a product just above 1 gives a small negative value (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_erlang_stage_count_and_product_rounding.expected
*/
// IEEE 1800-2023 §N.1 and §20.14.2: $dist_erlang computes what
// rtl_dist_erlang of N.2 computes. N.2: the erlang helper starts a product at
// one, multiplies it by exactly k uniform samples between 0 and 1, and returns
// minus the mean times the logarithm of the product divided by k;
// rtl_dist_erlang then rounds the result to the nearest integer, truncating
// after 0.5 is added when the result is not negative, and otherwise negating
// it, truncating after 0.5 is added and negating the result.
//
// Each uniform sample advances the seed once by 69069 * seed + 1, so the
// design counts those steps: a call takes exactly k of them, whatever the mean
// or the value. The seed and the arguments are 32-bit integers (20.14.1,
// 20.14.2), so the C long is taken as 32 bits.
//
// From the seed 1 with one stage the sample gives 1103.71, which rounds to
// 1104, and with the mean 200 the same sample gives 2207.42, which rounds to
// 2207, so both the mean factor and rounding down are visible. With two, three
// and four stages from the seeds 1 and 3 the results are 661.88, 457.74 and
// 380.57, which round to 662, 458 and 381 after exactly two, three and four
// draws; leaving out the division by k or one factor of the product changes
// these values. Five stages with the mean 50 from the seed 3 give 190.71,
// which rounds to 191 after five draws. The seed -1271221770 advances to -1,
// whose top 23 bits are all ones, so the corrected sample is a little above 1:
// with one stage and the mean 2147483647 the helper returns about -255.99995,
// which rounds to -256, where adding 0.5 without regard to the sign gives
// -255; with the mean 1000000000 it returns about -119.2093, which rounds to
// -119, where rounding towards minus infinity gives -120. The values were
// computed with the C code of N.2.

module test_dist_erlang_stage_count_and_product_rounding;
  integer seed, v;

  function automatic int draws(integer from, integer to);
    integer s = from;
    for (int n = 0; n <= 20; n++) begin
      if (s == to) return n;
      s = s * 69069 + 1;
    end
    return -1;
  endfunction

  task automatic check(integer from, integer k, integer mean);
    seed = from;
    v = $dist_erlang(seed, k, mean);
    $display("erlang(%0d, %0d) from %0d = %0d, seed %0d, draws %0d", k, mean, from, v, seed,
             draws(from, seed));
  endtask

  initial begin
    check(1, 1, 100);
    check(1, 1, 200);
    check(1, 2, 100);
    check(5, 2, 100);
    check(3, 3, 100);
    check(8, 3, 100);
    check(1, 4, 100);
    check(4, 4, 100);
    check(3, 5, 50);
    check(23, 3, 30);
    check(1, 2, 1000);
    check(1, 4, 1000);
    check(-1271221770, 1, 2147483647);
    check(-1271221770, 1, 1000000000);
  end
endmodule

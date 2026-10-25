/*
:name: test_dist_uniform_end_at_largest_integer
:description: $dist_uniform with the end 2147483647 and a start above the smallest integer decrements the start, draws, adds one and converts the sample by its sign, without overflowing the end (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_uniform_end_at_largest_integer.expected
*/
// IEEE 1800-2023 §N.1: $dist_uniform computes what rtl_dist_uniform of N.2
// computes. N.2: when the end is the largest integer and the start is not the
// smallest, the end cannot be incremented; instead the start is decremented,
// a real sample is drawn between the decremented start and the end, and 1 is
// added to it. The sum is truncated when it is not negative and truncated
// after 1 is subtracted when it is negative, and then kept above the
// decremented start and at most the end. The seed and the arguments are
// 32-bit integers (20.14.1, 20.14.2), so the C long is taken as 32 bits and
// the largest integer is 2147483647.
//
// Each start, 1000, -5, 2147483000 and -2147483647, is used for three calls
// from the seed 4242, so the same three draws are scaled to each range. A
// start that is not decremented, or a sum without the added 1, changes most
// results by one; an end that is incremented anyway wraps to the smallest
// integer and gives values unrelated to the start. With the start
// -2147483647 two of the results are negative. The two clamps can only act
// on a sum that does not fit in 32 bits, which these draws do not produce.
// The values were computed with the C code of N.2.

module test_dist_uniform_end_at_largest_integer;
  integer seed, v;
  integer starts [4] = '{1000, -5, 2147483000, -2147483647};

  initial begin
    foreach (starts[i]) begin
      seed = 4242;
      repeat (3) begin
        v = $dist_uniform(seed, starts[i], 2147483647);
        $display("uniform(%0d, 2147483647) = %0d, seed %0d", starts[i], v, seed);
      end
    end
  end
endmodule

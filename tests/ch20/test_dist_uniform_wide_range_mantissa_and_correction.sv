/*
:name: test_dist_uniform_wide_range_mantissa_and_correction
:description: $dist_uniform over ranges of a billion and two billion shows how the sample is built: the top 23 bits of the unsigned new seed become the mantissa of a float in [1, 2), the float is corrected by its product with 2**-23, and the range is scaled in double precision (IEEE 1800-2023 Section N.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2 N.2 N.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_uniform_wide_range_mantissa_and_correction.expected
*/
// IEEE 1800-2023 §N.1: $dist_uniform computes what rtl_dist_uniform of N.2
// computes. N.2: each draw replaces the seed s by 69069 * s + 1, takes the new
// seed as an unsigned 32-bit word, shifts it right by 9 and sets the exponent
// bits 0x3f800000, so that, read as an IEEE single-precision float, it is a
// value c in [1, 2) whose mantissa is the top 23 bits of the seed. In double
// precision c is then increased by c * 2**-23 (the constant
// 0.00000011920928955078125), and the sample is (b - a) * (c - 1) + a for the
// bounds a and b, b being the end plus 1. The seed and the arguments are 32-bit
// integers (20.14.1, 20.14.2), so the C long is taken as 32 bits.
//
// Over a range of a billion, one step of the mantissa is about 119, so the
// result shows each part of the computation: from the seed 1 the new seed
// 69070 has the top bits 134, and the corrected sample is 16093.25, so the
// result is 16093, where c without the correction would give 15974. Sums in
// single precision change most of the results by tens, and taking a negative
// new seed as signed fills the exponent bits and gives no number in [1, 2).
// Three starting seeds give four draws each over 0 to 1000000000, and the
// seed 1 also over -1000000000 to 1000000000. The values were computed with
// the C code of N.2.

module test_dist_uniform_wide_range_mantissa_and_correction;
  integer seed, v;
  integer starts [3] = '{1, -123456789, 987654321};

  initial begin
    foreach (starts[i]) begin
      seed = starts[i];
      repeat (4) begin
        v = $dist_uniform(seed, 0, 1000000000);
        $display("from %0d: uniform(0, 1000000000) = %0d, seed %0d", starts[i], v, seed);
      end
    end
    seed = 1;
    repeat (4) begin
      v = $dist_uniform(seed, -1000000000, 1000000000);
      $display("from 1: uniform(-1000000000, 1000000000) = %0d, seed %0d", v, seed);
    end
  end
endmodule

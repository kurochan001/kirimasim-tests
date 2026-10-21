/*
:name: test_urandom_range_bounds
:description: $urandom_range() returns a value between its two bounds, takes 0 as the lower bound when only one is given, swaps bounds given in the wrong order, and returns the bound itself when both are equal (IEEE 1800-2023 Section 18.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.13.2 18.13.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_urandom_range_bounds.expected
*/
// IEEE 1800-2023 §18.13.2: $urandom_range(maxval, minval) returns an unsigned
// value from minval to maxval; without minval the range starts at 0, and when
// maxval is below minval the two are reversed. The test only counts results
// outside the range, which the clause rules out, and prints the value of a
// range of one value.

module test_urandom_range_bounds;
  int unsigned v;
  int out_two = 0, out_one = 0, out_swapped = 0, out_equal = 0;

  initial begin
    repeat (200) begin
      v = $urandom_range(12, 5);
      if (v < 5 || v > 12) out_two++;
      v = $urandom_range(3);
      if (v > 3) out_one++;
      v = $urandom_range(5, 12);
      if (v < 5 || v > 12) out_swapped++;
      v = $urandom_range(7, 7);
      if (v != 7) out_equal++;
    end
    $display("outside the range: two=%0d one=%0d swapped=%0d equal=%0d",
             out_two, out_one, out_swapped, out_equal);
    $display("range of one value: %0d", $urandom_range(9, 9));
  end
endmodule

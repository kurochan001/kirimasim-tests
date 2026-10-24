/*
:name: test_array_reduction_result_type_and_with_width
:description: a reduction method returns a value of the element type without a with clause and of the with expression type with one, so the reduction wraps at the element width even when assigned to a wider variable, and a cast in the with clause widens every operand first (IEEE 1800-2023 Section 7.12.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_reduction_result_type_and_with_width.expected
*/
// IEEE 1800-2023 §7.12.3: the reduction methods take an iterator argument
// whose name defaults to item and return a single value of the element type,
// or, with a with clause, of the type of the with expression; the width of the
// result is the width of the with expression. A cast in the with clause thus
// extends each element before the reduction.
// Each result is assigned to the int y, which does not widen the reduction
// itself: the sums of byte, bit [7:0] and bit elements wrap at 8, 8 and 1
// bits, a negative byte sum is extended with its sign as a byte value, and
// item[3:0] makes a 4-bit sum. With int'(item) or e + 0 (an int expression)
// the same elements add up at 32 bits. $bits shows each result width.
// Icarus Verilog 13.0 does not support reduction methods on these arrays.
// The release Verilator 5.052 sums item[3:0] and the bit elements at 8 and 32
// bits (29 and 3) and gives 8 for $bits of the sum with int'(v).

module test_array_reduction_result_type_and_with_width;
  byte b [] = '{100, 100, 100};
  byte n [] = '{-1, -2};
  byte p [] = '{16, 16, 2};
  bit [7:0] u [] = '{200, 100};
  bit [7:0] lo [] = '{8'h0f, 8'h0e};
  bit ba [4] = '{1, 1, 1, 0};
  int y, z;

  initial begin
    y = b.sum();
    z = b.sum(v) with (int'(v));
    $display("byte sum: %0d, with int'(v): %0d, bits %0d and %0d", y, z, $bits(b.sum()),
             $bits(b.sum(v) with (int'(v))));
    y = n.sum;
    $display("negative byte sum: %0d", y);
    y = p.product();
    z = p.product with (int'(item));
    $display("byte product: %0d, with int'(item): %0d", y, z);
    y = u.sum();
    z = u.sum(e) with (e + 0);
    $display("bit [7:0] sum: %0d, with e + 0: %0d", y, z);
    y = lo.sum with (item[3:0]);
    $display("sum with item[3:0]: %0d, bits %0d", y, $bits(lo.sum with (item[3:0])));
    y = ba.sum();
    z = ba.sum with (int'(item));
    $display("bit sum: %0d, with int'(item): %0d, bits %0d", y, z, $bits(ba.sum()));
  end
endmodule

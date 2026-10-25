/*
:name: test_illegal_slice_of_two_dimensions
:description: a slice can apply to only one dimension of an array, while the other dimensions can have single indices (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the expression a[1:2][0:1] slices two dimensions of the array a
:expected_stderr_regex: test_illegal_slice_of_two_dimensions\.sv:37:
*/
// IEEE 1800-2023 §7.4.5: slices of an array can apply to only one dimension,
// and the other dimensions can have single index values in the expression.
// The two-dimensional array a holds 4 * i + j in a[i][j]. The expression
// a[1][2:3] has a single index for the first dimension and a slice of the
// second, and a[1:2] slices the first dimension only; the legal design prints
// the elements they copy: 6 7 4 11. The last statement takes a[1:2][0:1], with
// slices of both dimensions.
// Icarus Verilog 13.0 does not support slices of unpacked arrays and reports
// errors on the legal ones, which do not count. The 5.052 release takes the
// last expression as a slice of the slice a[1:2] and reports that its
// dimensions differ from those of b2, which does not count as the rule on
// slices.

module test_illegal_slice_of_two_dimensions;
  int a [4][4];
  int row [2];
  int rows [2][4];
  int b2 [2][2];
  initial begin
    foreach (a[i, j]) a[i][j] = 4 * i + j;
    row = a[1][2:3];
    rows = a[1:2];
    $display("%0d %0d %0d %0d", row[0], row[1], rows[0][0], rows[1][3]);
    b2 = a[1:2][0:1];   // illegal: slices of two dimensions
  end
endmodule

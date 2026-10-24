/*
:name: test_illegal_array_inner_dimension_size_mismatch
:description: array assignment may change the kind of the slowest dimension, but the faster dimensions have to be equivalent; elements of 4 ints cannot go to elements of 3 (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array e, whose faster dimension has 4 elements, is assigned to d, whose faster dimension has 3
:expected_stderr_regex: test_illegal_array_inner_dimension_size_mismatch\.sv:36:
*/
// IEEE 1800-2023 §7.6: the relaxed compatibility of unpacked arrays applies
// to the slowest-varying dimension only, whose kind (fixed-size, dynamic,
// queue) may differ; the faster dimensions shall meet the rules of type
// equivalence. b takes a with other bounds, and the dynamic array row takes
// the fixed-size array r; the legal design prints their sizes. The last
// assignment copies e, made of 4-int elements, to the dynamic array d,
// whose elements are 3-int arrays.
// Icarus Verilog 13.0 does not support some assignments of whole unpacked
// arrays: it reports errors on them or stops with a failed internal
// assertion, also on the legal ones here.

module test_illegal_array_inner_dimension_size_mismatch;
  int a [2][3];
  int b [1:2][0:2];
  int r [3];
  int row [];
  int d [][3];
  int e [2][4];
  initial begin
    b = a;
    row = r;
    $display("%0d %0d", $size(b, 2), row.size());
    d = e;   // illegal: faster dimension of 4 elements for one of 3
  end
endmodule

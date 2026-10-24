/*
:name: test_illegal_array_unpacked_dimension_count_mismatch
:description: arrays are assignment compatible only if they have the same number of unpacked dimensions, even when the element counts would fit (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the two-dimensional array a is assigned to the one-dimensional dynamic array f
:expected_stderr_regex: test_illegal_array_unpacked_dimension_count_mismatch\.sv:31:
*/
// IEEE 1800-2023 §7.6: the elements of an array are those of its slowest
// dimension, so two arrays are assignment compatible only if, among other
// conditions, they have the same number of unpacked dimensions. The dynamic
// array f takes the one-dimensional array six, and the legal design prints
// its size; the last assignment gives f the array a of two dimensions,
// which also holds six ints.
// Icarus Verilog 13.0 does not support some assignments of whole unpacked
// arrays: it reports errors on them or stops with a failed internal
// assertion, also on the legal ones here.

module test_illegal_array_unpacked_dimension_count_mismatch;
  int a [2][3];
  int six [6];
  int f [];
  initial begin
    f = six;
    $display("%0d", f.size());
    f = a;   // illegal: two unpacked dimensions for one
  end
endmodule

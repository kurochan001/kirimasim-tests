/*
:name: test_illegal_assoc_array_rsort
:description: the ordering method rsort() cannot be applied to an associative array (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering method rsort() is called on the associative array m
:expected_stderr_regex: test_illegal_assoc_array_rsort\.sv:31:
*/
// IEEE 1800-2023 §7.12.2: the array ordering methods reorder the elements of
// any unpacked array, fixed-size or dynamically sized, except associative
// arrays. rsort() puts the elements in descending order.
// The fixed-size array a is reordered with rsort(), and the legal design prints
// the elements: 7 3 2 1. The last statement calls rsort() on the associative
// array m.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.

module test_illegal_assoc_array_rsort;
  int a [4] = '{3, 1, 2, 7};
  int m [int];
  initial begin
    m[1] = 4;
    m[5] = 2;
    a.rsort;
    $display("%0d %0d %0d %0d", a[0], a[1], a[2], a[3]);
    m.rsort;   // illegal: rsort() on an associative array
  end
endmodule

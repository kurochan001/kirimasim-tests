/*
:name: test_illegal_assoc_array_shuffle
:description: the ordering method shuffle() cannot be applied to an associative array (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering method shuffle() is called on the associative array m
:expected_stderr_regex: test_illegal_assoc_array_shuffle\.sv:31:
*/
// IEEE 1800-2023 §7.12.2: the array ordering methods reorder the elements of
// any unpacked array, fixed-size or dynamically sized, except associative
// arrays. shuffle() puts the elements in a random order.
// The fixed-size array a is reordered with shuffle(), and the legal design
// prints the size and the sum of the elements, which a shuffle does not change:
// 4 13. The last statement calls shuffle() on the associative array m.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.

module test_illegal_assoc_array_shuffle;
  int a [4] = '{3, 1, 2, 7};
  int m [int];
  initial begin
    m[1] = 4;
    m[5] = 2;
    a.shuffle;
    $display("%0d %0d", $size(a), a.sum());
    m.shuffle;   // illegal: shuffle() on an associative array
  end
endmodule

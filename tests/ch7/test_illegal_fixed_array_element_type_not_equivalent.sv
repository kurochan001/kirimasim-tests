/*
:name: test_illegal_fixed_array_element_type_not_equivalent
:description: unpacked arrays are assignment compatible only if their element types are equivalent; byte elements cannot go to an int array (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array b of byte elements is assigned to the array a of int elements
:expected_stderr_regex: test_illegal_fixed_array_element_type_not_equivalent\.sv:33:
*/
// IEEE 1800-2023 §7.6: a fixed-size, dynamic or queue array is assignment
// compatible with another only if their element types are equivalent.
// bit signed [31:0] is equivalent to int (6.22.2), so s is copied to the
// int arrays a and d, and the legal design prints elements of both; the
// last assignment gives a the array b of byte elements, which are not
// equivalent to int although each byte value fits in an int.
// Icarus Verilog 13.0 does not support some assignments of whole unpacked
// arrays: it reports errors on them or stops with a failed internal
// assertion, also on the legal ones here.

module test_illegal_fixed_array_element_type_not_equivalent;
  int a [3];
  int d [];
  bit signed [31:0] s [3] = '{-1, 2, 3};
  byte b [3] = '{1, 2, 3};
  initial begin
    a = s;
    d = s;
    $display("%0d %0d %0d", a[0], d.size(), d[2]);
    a = b;   // illegal: byte elements for an int array
  end
endmodule

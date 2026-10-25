/*
:name: test_illegal_slice_element_type_not_equivalent
:description: a slice of a fixed-size array is assignment compatible with another array only if their element types are equivalent (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array b of two byte elements is assigned to the slice a[1:2] of the int array a
:expected_stderr_regex: test_illegal_slice_element_type_not_equivalent\.sv:37:
*/
// IEEE 1800-2023 §7.6: a fixed-size array, dynamic array or queue, or a
// slice of such an array, is assignment compatible with another such array
// or slice only if the element types of source and target are equivalent
// and, for a fixed-size or slice target, the numbers of elements are equal.
// bit signed [31:0] is equivalent to int (6.22.2): the array s of two such
// elements is copied to the slice a[1:2], and the slice a[0:1] to the
// fixed-size array c; the legal design prints a and c. The last assignment
// gives the slice a[1:2] the array b, whose two byte elements are not
// equivalent to int.
// Icarus Verilog 13.0 does not support slices of unpacked arrays and
// reports errors on the legal ones. The 5.052 release rejects the last
// assignment with a message about an unexpected extension in an unpacked
// array assignment, not about the element types, which does not count.

module test_illegal_slice_element_type_not_equivalent;
  int a [4] = '{1, 2, 3, 4};
  int c [2];
  bit signed [31:0] s [2] = '{-5, 6};
  byte b [2] = '{7, 8};
  initial begin
    a[1:2] = s;
    c = a[0:1];
    $display("%0d %0d %0d %0d %0d %0d", a[0], a[1], a[2], a[3], c[0], c[1]);
    a[1:2] = b;   // illegal: byte elements for a slice of int elements
  end
endmodule

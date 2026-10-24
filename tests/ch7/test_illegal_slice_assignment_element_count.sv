/*
:name: test_illegal_slice_assignment_element_count
:description: an assignment to a slice of an unpacked array needs a source with the same number of elements as the slice (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6 7.4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fixed-size array two of 2 elements is assigned to the slice a[3:1] of 3 elements
:expected_stderr_regex: test_illegal_slice_assignment_element_count\.sv:30:
*/
// IEEE 1800-2023 §7.6: an array is assignment compatible with a fixed-size
// array or slice target only if the source has the same number of elements
// as the target. The slice a[3:1] takes the three elements of three and the
// legal design prints the elements of a it writes; the last assignment
// gives the same slice the two elements of two.
// Icarus Verilog 13.0 does not support some assignments of whole unpacked
// arrays: it reports errors on them or stops with a failed internal
// assertion, also on the legal ones here.

module test_illegal_slice_assignment_element_count;
  int a [6:1];
  int three [3] = '{7, 8, 9};
  int two [2] = '{4, 5};
  initial begin
    a[3:1] = three;
    $display("%0d %0d %0d", a[3], a[2], a[1]);
    a[3:1] = two;   // illegal: 2 elements for a slice of 3
  end
endmodule

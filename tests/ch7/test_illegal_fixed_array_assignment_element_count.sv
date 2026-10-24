/*
:name: test_illegal_fixed_array_assignment_element_count
:description: an assignment to a fixed-size unpacked array needs a source with the same number of elements (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fixed-size array c of 24 elements is assigned to the fixed-size array a of 10 elements
:expected_stderr_regex: test_illegal_fixed_array_assignment_element_count\.sv:33:
*/
// IEEE 1800-2023 §7.6: an array is assignment compatible with a fixed-size
// target only if the source has the same number of elements as the target;
// the ranges themselves may differ. a and b both have 10 elements, with
// other bounds, and a dynamic array takes any number of elements; the
// legal design prints the sizes after the copies. The last assignment
// copies 24 elements into the 10 of a.
// Icarus Verilog 13.0 does not support some assignments of whole unpacked
// arrays: it reports errors on them or stops with a failed internal
// assertion, also on the legal ones here.

module test_illegal_fixed_array_assignment_element_count;
  int a [10:1];
  int b [0:9];
  int c [24:1];
  int d [];
  initial begin
    a = b;
    d = c;
    $display("%0d %0d", $size(a), d.size());
    a = c;   // illegal: 24 elements for a target of 10
  end
endmodule

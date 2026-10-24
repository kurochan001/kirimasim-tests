/*
:name: test_illegal_dynamic_new_to_fixed_array
:description: the dynamic array new constructor can be assigned only to a dynamic array, not to a fixed-size array (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: new[3] is assigned to the fixed-size array f, which is not a dynamic array
:expected_stderr_regex: test_illegal_dynamic_new_to_fixed_array\.sv:30:
*/
// IEEE 1800-2023 §7.5.1: the new constructor may appear in place of the
// right-hand side of a variable declaration assignment or of a blocking
// procedural assignment when the left-hand side is a dynamic array. The
// declaration of d and the blocking assignment to the dynamic array e use
// it legally, and the legal design prints the sizes; the last assignment
// gives new[3] to the fixed-size array f.
// Icarus Verilog 13.0 stops with a failed internal assertion on this
// design instead of reporting an error.

module test_illegal_dynamic_new_to_fixed_array;
  int d [] = new[2];
  int e [];
  int f [3];
  initial begin
    e = new[4];
    $display("%0d %0d", d.size(), e.size());
    f = new[3];   // illegal: f is not a dynamic array
  end
endmodule

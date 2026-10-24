/*
:name: test_illegal_dynamic_new_to_slice
:description: the target of a dynamic array new constructor is a dynamic array named without a range select; a slice of dynamic arrays is not allowed (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: new[2] is assigned to the slice f[0:1], a range select of two dynamic arrays, not a nonrange_variable_lvalue that is a dynamic array
:expected_stderr_regex: test_illegal_dynamic_new_to_slice\.sv:32:
*/
// IEEE 1800-2023 §7.5.1 (Syntax 7-3): new[] can take the place of the
// right-hand side of a blocking assignment when the left-hand side is a
// dynamic array, and the grammar gives that form a nonrange_variable_lvalue,
// a target that may have single index selects but no range select. The
// elements of the fixed-size array f are dynamic arrays: f[0] and f[2],
// selected by single indices, are sized with new[], and the legal design
// prints the three sizes 2 0 4. The last statement gives new[2] to the
// slice f[0:1], which is a range of the fixed-size array, not a dynamic
// array.
// Icarus Verilog 13.0 does not support fixed-size arrays of dynamic arrays
// and reports errors on the legal lines.

module test_illegal_dynamic_new_to_slice;
  int f [3][];
  initial begin
    f[0] = new[2];
    f[2] = new[4];
    $display("%0d %0d %0d", f[0].size(), f[1].size(), f[2].size());
    f[0:1] = new[2];   // illegal: a slice as the target of new[]
  end
endmodule

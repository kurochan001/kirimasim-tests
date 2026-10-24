/*
:name: test_illegal_dynamic_array_from_assoc
:description: an associative array cannot be assigned to an array of another kind, such as a dynamic array (IEEE 1800-2023 Section 7.9.9)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array s is assigned to the dynamic array d
:expected_stderr_regex: test_illegal_dynamic_array_from_assoc\.sv:34:
*/
// IEEE 1800-2023 §7.9.9: an associative array can be assigned only to another
// associative array of a compatible type with the same index type; associative
// arrays cannot be assigned to other kinds of arrays, fixed-size or dynamic.
// The associative array s, indexed by int, is copied to t, which has the same
// element and index types; t already has an entry, which the assignment clears,
// and the legal design prints the number of entries and an entry of t: 2 6. The
// last statement assigns s to the dynamic array d of int elements.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.

module test_illegal_dynamic_array_from_assoc;
  int s [int];
  int t [int];
  int d [];
  initial begin
    s[1] = 5;
    s[2] = 6;
    t[9] = 0;
    t = s;
    $display("%0d %0d", t.num(), t[2]);
    d = s;   // illegal: associative array assigned to a dynamic array
  end
endmodule

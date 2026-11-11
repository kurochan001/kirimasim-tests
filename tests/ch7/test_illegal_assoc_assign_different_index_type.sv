/*
:name: test_illegal_assoc_assign_different_index_type
:description: an associative array can be assigned only to an associative array with the same index type; a string-indexed source for an int-indexed target is an error (IEEE 1800-2023 Section 7.9.9)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array w, indexed by string, is assigned to the associative array t, indexed by int
:expected_stderr_regex: test_illegal_assoc_assign_different_index_type\.sv:37:
*/
// IEEE 1800-2023 §7.9.9: an associative array can be assigned only to another
// associative array of a compatible type with the same index type, and the
// assignment clears the target before it copies each entry of the source.
// The associative array s, indexed by int, is copied to t, which has the same
// element and index types; t already has an entry, which the assignment clears,
// and the legal design prints the number of entries and an entry of t: 2 6. The
// last statement assigns w, indexed by string, to t.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design and fails only when it compiles
// the C++ code that it generates, which does not count.

module test_illegal_assoc_assign_different_index_type;
  int s [int];
  int t [int];
  int w [string];
  initial begin
    s[1] = 5;
    s[2] = 6;
    t[9] = 0;
    w["x"] = 1;
    t = s;
    $display("%0d %0d", t.num(), t[2]);
    t = w;   // illegal: different index types
  end
endmodule

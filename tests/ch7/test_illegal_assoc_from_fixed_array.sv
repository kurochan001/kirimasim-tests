/*
:name: test_illegal_assoc_from_fixed_array
:description: an array of another kind, such as a fixed-size array, cannot be assigned to an associative array (IEEE 1800-2023 Section 7.9.9)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fixed-size array f is assigned to the associative array t
:expected_stderr_regex: test_illegal_assoc_from_fixed_array\.sv:34:
*/
// IEEE 1800-2023 §7.9.9: an associative array can be assigned only from another
// associative array of a compatible type with the same index type; other kinds
// of arrays cannot be assigned to an associative array.
// The associative array s, indexed by int, is copied to t, which has the same
// element and index types; t already has an entry, which the assignment clears,
// and the legal design prints the number of entries and an entry of t: 2 6. The
// last statement assigns the fixed-size array f of two int elements to t.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.

module test_illegal_assoc_from_fixed_array;
  int s [int];
  int t [int];
  int f [2] = '{5, 6};
  initial begin
    s[1] = 5;
    s[2] = 6;
    t[9] = 0;
    t = s;
    $display("%0d %0d", t.num(), t[2]);
    t = f;   // illegal: fixed-size array assigned to an associative array
  end
endmodule

/*
:name: test_illegal_assoc_to_dynamic_array_argument
:description: an associative array cannot be passed to a formal argument that is an array of another kind, such as a dynamic array (IEEE 1800-2023 Section 7.9.10)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array s is passed to the formal argument a of total, a dynamic array
:expected_stderr_regex: test_illegal_assoc_to_dynamic_array_argument\.sv:35:
*/
// IEEE 1800-2023 §7.9.10: associative arrays cannot be passed to subroutines
// that take other kinds of arrays as arguments.
// The function total has a formal argument that is a dynamic array of int, and
// the call total(d) with the dynamic array d is legal; the legal design prints
// the sum it returns: 11. The last call passes the associative array s of int
// elements.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design and fails only when it compiles
// the C++ code that it generates, which does not count.

module test_illegal_assoc_to_dynamic_array_argument;
  int s [int];
  int d [] = '{5, 6};
  function automatic int total(int a []);
    return a.sum();
  endfunction
  initial begin
    s[1] = 5;
    s[2] = 6;
    $display("%0d", total(d));
    $display("%0d", total(s));   // illegal: associative array for a dynamic formal
  end
endmodule

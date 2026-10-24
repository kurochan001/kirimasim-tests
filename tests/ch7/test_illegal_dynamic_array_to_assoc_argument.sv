/*
:name: test_illegal_dynamic_array_to_assoc_argument
:description: an array of another kind, such as a dynamic array, cannot be passed to a formal argument that is an associative array (IEEE 1800-2023 Section 7.9.10)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the dynamic array d is passed to the formal argument a of count, an associative array
:expected_stderr_regex: test_illegal_dynamic_array_to_assoc_argument\.sv:35:
*/
// IEEE 1800-2023 §7.9.10: other kinds of arrays, fixed-size or dynamic, cannot
// be passed to subroutines that take an associative array as an argument.
// The function count has a formal argument that is an associative array of int
// indexed by int, and the call count(s) with the array s of the same type is
// legal; the legal design prints the number of entries it returns: 2. The last
// call passes the dynamic array d of int elements.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design and fails only when it compiles
// the C++ code that it generates, which does not count.

module test_illegal_dynamic_array_to_assoc_argument;
  int s [int];
  int d [] = '{5, 6};
  function automatic int count(int a [int]);
    return a.num();
  endfunction
  initial begin
    s[1] = 5;
    s[2] = 6;
    $display("%0d", count(s));
    $display("%0d", count(d));   // illegal: dynamic array for an associative formal
  end
endmodule

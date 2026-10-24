/*
:name: test_illegal_assoc_argument_different_index_type
:description: an associative array can be passed only to a formal argument that is an associative array with the same index type (IEEE 1800-2023 Section 7.9.10)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the string-indexed associative array w is passed to the formal argument a of count, an associative array indexed by int
:expected_stderr_regex: test_illegal_assoc_argument_different_index_type\.sv:36:
*/
// IEEE 1800-2023 §7.9.10: associative arrays can be passed as arguments only to
// associative arrays of a compatible type with the same index type.
// The function count has a formal argument that is an associative array of int
// indexed by int, and the call count(s) with the array s of the same type is
// legal; the legal design prints the number of entries it returns: 2. The last
// call passes w, indexed by string.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design and fails only when it compiles
// the C++ code that it generates, which does not count.

module test_illegal_assoc_argument_different_index_type;
  int s [int];
  int w [string];
  function automatic int count(int a [int]);
    return a.num();
  endfunction
  initial begin
    s[1] = 5;
    s[2] = 6;
    w["x"] = 1;
    $display("%0d", count(s));
    $display("%0d", count(w));   // illegal: different index type
  end
endmodule

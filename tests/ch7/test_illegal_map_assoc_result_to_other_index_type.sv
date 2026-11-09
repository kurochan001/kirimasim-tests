/*
:name: test_illegal_map_assoc_result_to_other_index_type
:description: map() of an associative array returns an associative array with the same index type, so its result cannot be assigned to an associative array with another index type (IEEE 1800-2023 Sections 7.12.5, 7.9.9)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.5 7.9.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of m.map() has the string index type of m, and it is assigned to k, an associative array indexed by int
:expected_stderr_regex: test_illegal_map_assoc_result_to_other_index_type\.sv:34:
*/
// IEEE 1800-2023 §7.12.5: for an associative array, map() returns an array
// with the same set of indices, and its index type matches that of the
// source. §7.9.9: an associative array can be assigned only to an
// associative array with the same index type. m is indexed by string; the
// first result is assigned to m2, also indexed by string, and the legal
// design prints its elements: 8 18. The last result is assigned to k, which
// is indexed by int.
// Icarus Verilog 13.0 does not support the with clause of array methods and
// reports syntax errors on both calls; the 5.052 release of Verilator
// accepts the design and then fails to compile the C++ code it generates.

module test_illegal_map_assoc_result_to_other_index_type;
  int m[string];
  int m2[string];
  int k[int];
  initial begin
    m["x"] = 4;
    m["y"] = 9;
    m2 = m.map() with (item * 2);
    $display("%0d %0d", m2["x"], m2["y"]);
    k = m.map() with (item * 2);   // illegal: string index type for an array indexed by int
  end
endmodule

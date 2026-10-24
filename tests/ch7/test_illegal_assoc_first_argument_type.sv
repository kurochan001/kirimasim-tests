/*
:name: test_illegal_assoc_first_argument_type
:description: the argument of the associative array traversal method first() has to be assignment compatible with the index type of the array; a real variable for a string index is an error (IEEE 1800-2023 Sections 7.9.4, 7.9.8)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.4 7.9.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: first() of the string-indexed array m is called with the real variable r, which is not assignment compatible with string
:expected_stderr_regex: test_illegal_assoc_first_argument_type\.sv:38:
*/
// IEEE 1800-2023 §7.9.4: first() takes, by reference, an index of the
// appropriate type for the array. §7.9.8: the argument of first(), last(),
// next() and prev() shall be assignment compatible with the index type of
// the array. The array m is indexed by strings and has the entries "b" and
// "d".
// The legal call m.first(s) with the string s sets s to the smallest index
// and returns 1, and the legal design prints 1 b 1.
// The last call passes the real variable r, which is not assignment
// compatible with string (a cast is needed both ways).
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declarations and uses. The 5.052
// release rejects the last call as an unsupported non-variable argument of
// first(), not for its type, which does not count.

module test_illegal_assoc_first_argument_type;
  int m [string];
  string s;
  real r = 1.0;
  int st;
  initial begin
    m["b"] = 1;
    m["d"] = 2;
    st = m.first(s);
    $display("%0d %s %0d", st, s, m[s]);
    st = m.first(r);   // illegal: real argument for a string index
  end
endmodule

/*
:name: test_illegal_string_index_with_int
:description: an associative array with a string index takes strings and string literals as indices; an int index is a type check error (IEEE 1800-2023 Section 7.8.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the string-indexed associative array m is indexed by the int variable k
:expected_stderr_regex: test_illegal_string_index_with_int\.sv:35:
*/
// IEEE 1800-2023 §7.8.2: the indices of an associative array with a string
// index can be strings or string literals of any length, the empty string
// included; any other type is illegal and is a type check error.
// The array m is written through a string literal, a longer string literal, the
// empty string and the string variable s, which names the same entry as "ab";
// the legal design prints the number of entries and two of them: 3 2 30. The
// last statement indexes m with the int variable k.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design.

module test_illegal_string_index_with_int;
  int m [string];
  string s = "ab";
  int k = 1;
  initial begin
    m["ab"] = 1;
    m["a much longer string literal index"] = 2;
    m[""] = 30;
    m[s] = m[s] + 1;
    $display("%0d %0d %0d", m.num(), m["ab"], m[""]);
    m[k] = 4;   // illegal: an int index for a string index
  end
endmodule

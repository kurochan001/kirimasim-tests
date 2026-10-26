/*
:name: test_illegal_writemem_assoc_string_index
:description: $writememh writes an associative array whose index type is not integral (IEEE 1800-2023 Section 21.5.3)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array m passed to $writememh has string indices
:expected_stderr_regex: test_illegal_writemem_assoc_string_index\.sv:22:
*/
// An associative array shall have integral indices to be a legal
// argument of $writememh, because the write emits the index as an
// address word. The index type of m is string.

module test_illegal_writemem_assoc_string_index;
  int m[string];
  initial begin
    m["a"] = 1;
    $writememh("words.txt", m);   // illegal: string index type
  end
endmodule

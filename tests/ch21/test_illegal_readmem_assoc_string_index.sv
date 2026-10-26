/*
:name: test_illegal_readmem_assoc_string_index
:description: $readmemh loads an associative array whose index type is not integral (IEEE 1800-2023 Section 21.4.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array m passed to $readmemh has string indices
:expected_stderr_regex: test_illegal_readmem_assoc_string_index\.sv:20:
*/
// When an associative array is loaded, its indices shall be of integral
// types. The associative array m here is indexed by string.

module test_illegal_readmem_assoc_string_index;
  int m[string];
  initial begin
    $readmemh("words.txt", m);   // illegal: string index type
  end
endmodule

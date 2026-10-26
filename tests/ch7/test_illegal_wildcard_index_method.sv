/*
:name: test_illegal_wildcard_index_method
:description: the iterator index method cannot be used with a wildcard-index associative array
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.4 7.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: item.index is used on a wildcard-index associative array
:expected_stderr_regex: test_illegal_wildcard_index_method\.sv:25:
*/
// IEEE 1800-2023 7.12.4: the index method of an iterator returns the index of
// the specified dimension, and associative arrays that specify a wildcard
// index type shall not be allowed. The marked with expression calls item.index
// on a wildcard array, which a tool has to reject.

module test_illegal_wildcard_index_method;
  int a[*];
  int found[$];

  initial begin
    a[1] = 1;
    found = a.find with (item.index > 0); // illegal: index method on wildcard
  end
endmodule

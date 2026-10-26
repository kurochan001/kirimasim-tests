/*
:name: test_illegal_wildcard_find_index
:description: a wildcard associative array cannot use an array method that returns index values
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.1 7.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: find_index returns indices of a wildcard-index associative array
:expected_stderr_regex: test_illegal_wildcard_find_index\.sv:25:
*/
// IEEE 1800-2023 7.8.1: an associative array with a wildcard index type shall
// not be used with an array manipulation method that returns an index value or
// an array of values. The marked find_index call returns the indices of such an
// array, which a tool has to reject.

module test_illegal_wildcard_find_index;
  int a[*];
  int idx[$];

  initial begin
    a[1] = 1;
    idx = a.find_index(); // illegal: index-returning method on a wildcard array
  end
endmodule

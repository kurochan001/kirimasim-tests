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
:expected_stderr_regex: test_illegal_wildcard_index_method\.sv:31:
*/
// IEEE 1800-2023 7.12.4: the index method of an iterator returns the index of
// the specified dimension, and associative arrays that specify a wildcard
// index type shall not be allowed. The marked with expression calls item.index
// on a wildcard array, which a tool has to reject. The method that iterates is
// the reduction sum(), which 7.8.1 allows on a wildcard array since it returns
// one value, not an index or an array of values; with a locator such as find()
// the line would have a second error.
// Icarus Verilog 13.0 does not support wildcard associative arrays or with
// clauses and reports syntax errors, also on the marked line, which do not
// count.

module test_illegal_wildcard_index_method;
  int a[*];
  int total;

  initial begin
    a[1] = 1;
    total = a.sum with (item.index > 0 ? item : 0); // illegal: index method on wildcard
  end
endmodule

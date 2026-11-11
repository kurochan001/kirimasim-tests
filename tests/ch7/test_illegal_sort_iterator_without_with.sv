/*
:name: test_illegal_sort_iterator_without_with
:description: an array method iterator argument requires a with clause
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sort is given the iterator x but no with clause
:expected_stderr_regex: test_illegal_sort_iterator_without_with\.sv:24:
*/
// IEEE 1800-2023 7.12: the optional iterator argument of an array
// manipulation method names the variable used in the with expression, so
// specifying an iterator without a with clause is illegal. The marked call
// names x without a with clause, which a tool has to reject.

module test_illegal_sort_iterator_without_with;
  int a[3];

  initial begin
    a = '{3, 1, 2};
    a.sort(x); // illegal: iterator argument without a with clause
  end
endmodule

// Oracle check: Icarus Verilog 13.0 reports an unknown task a.sort on line
// 24, as it does for the legal a.sort(), so its error does not count.

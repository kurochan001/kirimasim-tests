/*
:name: test_illegal_find_first_without_with
:description: the with clause of the array locator method find_first() is mandatory (IEEE 1800-2023 Section 7.12.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the locator method find_first() is called without a with clause
:expected_stderr_regex: test_illegal_find_first_without_with\.sv:30:
*/
// IEEE 1800-2023 §7.12.1: for the locator methods find(), find_index(),
// find_first(), find_first_index(), find_last() and find_last_index() the
// with clause is mandatory, and its expression is evaluated as a Boolean
// value. The first call below has a with clause whose expression is the
// int item & 4, true for the elements 5 and 7; the legal design prints
// the queue that find_first() returns: 5. The last call has no with
// clause.
// Icarus Verilog 13.0 does not support the with clause of array methods
// and reports a syntax error on the legal call.

module test_illegal_find_first_without_with;
  int a [4] = '{1, 5, 2, 7};
  int q [$];
  initial begin
    q = a.find_first with (item & 4);
    foreach (q[i]) $display("%0d", q[i]);
    q = a.find_first;   // illegal: no with clause
  end
endmodule

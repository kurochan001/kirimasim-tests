/*
:name: test_illegal_map_without_with
:description: the array method map() needs a with clause that gives the value of each element of its result (IEEE 1800-2023 Section 7.12.5)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array method map() is called without a with clause
:expected_stderr_regex: test_illegal_map_without_with\.sv:28:
*/
// IEEE 1800-2023 §7.12.5: map() returns an array whose elements are the
// values of its with expression for the elements of the array, so the with
// clause is required. The first call of map() has a with clause, and the
// legal design prints the elements it returns, copied to a queue
// (2 10 4 14); the last call has none.
// Icarus Verilog 13.0 does not support the with clause of array methods
// and reports a syntax error on the legal call.

module test_illegal_map_without_with;
  int a [4] = '{1, 5, 2, 7};
  int q [$];
  initial begin
    q = a.map(x) with (x * 2);
    $display("%0d %0d %0d %0d", q[0], q[1], q[2], q[3]);
    q = a.map;   // illegal: no with clause
  end
endmodule

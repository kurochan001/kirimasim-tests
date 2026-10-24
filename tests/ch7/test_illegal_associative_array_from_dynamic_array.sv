/*
:name: test_illegal_associative_array_from_dynamic_array
:description: an associative array is assignment compatible only with associative arrays; a dynamic array cannot be assigned to it (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the dynamic array d is assigned to the associative array m
:expected_stderr_regex: test_illegal_associative_array_from_dynamic_array\.sv:33:
*/
// IEEE 1800-2023 §7.6: associative arrays are assignment compatible only
// with associative arrays (7.9.9). The associative array n is copied to the
// associative array m, and the dynamic array d to the queue q, which the
// legal design shows by printing their sizes; the last assignment copies
// the dynamic array d to the associative array m.
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declarations and uses, the line of the
// assignment included; those errors do not count.

module test_illegal_associative_array_from_dynamic_array;
  int m [int];
  int n [int];
  int d [] = '{1, 2, 3};
  int q [$];
  initial begin
    n[4] = 9;
    m = n;
    q = d;
    $display("%0d %0d %0d", m.num(), m[4], q.size());
    m = d;   // illegal: dynamic array assigned to an associative array
  end
endmodule

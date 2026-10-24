/*
:name: test_illegal_fixed_array_from_associative_array
:description: an associative array is assignment compatible only with associative arrays; it cannot be assigned to a fixed-size array (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array m is assigned to the fixed-size array f
:expected_stderr_regex: test_illegal_fixed_array_from_associative_array\.sv:32:
*/
// IEEE 1800-2023 §7.6: associative arrays are assignment compatible only
// with associative arrays (7.9.9). The associative array m is copied to the
// associative array n, which the legal design shows by printing the number
// of elements and one element of n; the last assignment copies m to the
// fixed-size array f, which has as many elements as m.
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declarations and uses, the line of the
// assignment included; those errors do not count.

module test_illegal_fixed_array_from_associative_array;
  int m [int];
  int n [int];
  int f [2];
  initial begin
    m[0] = 5;
    m[1] = 6;
    n = m;
    $display("%0d %0d", n.num(), n[1]);
    f = m;   // illegal: associative array assigned to a fixed-size array
  end
endmodule

/*
:name: test_illegal_associative_array_slice
:description: an associative array cannot be sliced, while it can be read, written and compared as a whole and by element (IEEE 1800-2023 Section 7.4.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative array m is sliced as m[1:2]
:expected_stderr_regex: test_illegal_associative_array_slice\.sv:34:
*/
// IEEE 1800-2023 §7.4.6: associative arrays cannot be sliced, but reading,
// writing and equality operations can be done on such arrays as a whole or
// on single elements. The legal design copies m to n as a whole, reads and
// writes elements, compares the two arrays with == and != and prints the
// results; the last statement takes the slice m[1:2].
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declarations and uses, the slice
// included; those errors do not count.

module test_illegal_associative_array_slice;
  int m [int];
  int n [int];
  int b [2];
  initial begin
    m[1] = 2;
    m[2] = 3;
    n = m;
    $display("%0d %0d", n == m, n != m);
    n[5] = m[2];
    $display("%0d %0d %0d", n.num(), n[5], n == m);
    b = m[1:2];   // illegal: slice of an associative array
  end
endmodule

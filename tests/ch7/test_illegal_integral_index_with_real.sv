/*
:name: test_illegal_integral_index_with_real
:description: the index expression of an associative array with an integral index is cast to the index type, but an implicit cast from real is illegal (IEEE 1800-2023 Section 7.8.4)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the int-indexed associative array m is indexed by the real variable r
:expected_stderr_regex: test_illegal_integral_index_with_real\.sv:36:
*/
// IEEE 1800-2023 §7.8.4: the index expression of an associative array with an
// integral index type is evaluated as if cast to the index type, except that an
// implicit cast from real or shortreal is illegal.
// The int-indexed array m is written through the 8-bit index 8'd3, the int 3,
// which names the same entry after the cast, the byte -1 and the integer 5; the
// legal design prints the number of entries and two of them: 3 2 9. The last
// statement indexes m with the real variable r.
// Icarus Verilog 13.0 does not support associative arrays with an index type
// and reports errors on their declarations and uses, which do not count.
// The 5.052 release accepts the design.

module test_illegal_integral_index_with_real;
  int m [int];
  byte nb = -1;
  integer i5 = 5;
  real r = 2.0;
  initial begin
    m[8'd3] = 1;
    m[3] = m[3] + 1;
    m[nb] = 9;
    m[i5] = 7;
    $display("%0d %0d %0d", m.num(), m[3], m[-1]);
    m[r] = 4;   // illegal: a real index for an int index
  end
endmodule

/*
:name: test_assoc_narrow_prev_next_overflow
:description: Next and prev report truncation when a discovered key does not fit their narrow output index (IEEE 1800-2023 Section 7.9.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.8 7.9.6 7.9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_narrow_prev_next_overflow.expected
*/
// IEEE 1800-2023 7.9.8: Unlike a no-match return, a truncation return is -1 and
// still copies the low key bits; both directions are exercised.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_assoc_narrow_prev_next_overflow;
  int a[int];
  bit [7:0] k;
  int status;
  initial begin
    a[-300] = 1; a[600] = 2;
    k = 0; status = a.next(k);
    $display("next=%0d key=%0d", status, k);
    k = 0; status = a.prev(k);
    $display("prev=%0d key=%0d", status, k);
  end
endmodule

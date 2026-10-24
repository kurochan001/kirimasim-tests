/*
:name: test_illegal_slice_variable_width
:description: the size of a slice of an unpacked array has to be constant (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the slice a[0 +: w] of the unpacked array a has the variable size w
:expected_stderr_regex: test_illegal_slice_variable_width\.sv:31:
*/
// IEEE 1800-2023 §7.4.5: the size of a part-select or slice shall be
// constant, but its position can be variable. The slices a[2:4] and
// a[5 -: 3] of the unpacked array a have constant sizes, and the legal
// design prints the elements they copy; the last slice has the variable
// size w.
// Icarus Verilog 13.0 does not support slices of unpacked arrays and
// reports an error on each of them, the legal ones included.

module test_illegal_slice_variable_width;
  int a [8] = '{10, 11, 12, 13, 14, 15, 16, 17};
  int b [3];
  int w = 3;
  initial begin
    b = a[2:4];
    $display("%0d %0d %0d", b[0], b[1], b[2]);
    b = a[5 -: 3];
    $display("%0d %0d %0d", b[0], b[1], b[2]);
    b = a[0 +: w];   // illegal: variable slice size
  end
endmodule

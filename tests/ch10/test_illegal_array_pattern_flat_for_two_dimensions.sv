/*
:name: test_illegal_array_pattern_flat_for_two_dimensions
:description: the braces of an array assignment pattern have to match the dimensions of the array, so a flat list cannot fill a two-dimensional array (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment pattern for the array m of 2 by 2 elements is one flat list of four values
:expected_stderr_regex: test_illegal_array_pattern_flat_for_two_dimensions\.sv:24:
*/
// IEEE 1800-2023 §10.9.1: the braces of an array assignment pattern shall
// match the array dimensions, with one level of braces per dimension. The
// pattern with an inner pattern for each row of m is legal; the flat pattern
// of four values for the 2 by 2 array is not.

module test_illegal_array_pattern_flat_for_two_dimensions;
  int m [2][2];

  initial begin
    m = '{'{1, 2}, '{3, 4}};
    m = '{1, 2, 3, 4};   // illegal: one level of braces for two dimensions
    $display("%p", m);
  end
endmodule

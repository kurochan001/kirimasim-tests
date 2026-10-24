/*
:name: test_illegal_foreach_more_loop_variables_than_dimensions
:description: a foreach-loop cannot have more loop variables than the array has dimensions (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the foreach-loop names three loop variables for the two-dimensional array m
:expected_stderr_regex: test_illegal_foreach_more_loop_variables_than_dimensions\.sv:27:
*/
// IEEE 1800-2023 §12.7.3: the number of loop variables of a foreach-loop shall
// not be greater than the number of dimensions of the array. m has two
// dimensions, one unpacked and one packed. The first loop names both, the
// second omits the first one, which skips that dimension, and the third omits
// the last one with its comma; these are legal. The fourth names three loop
// variables.

module test_illegal_foreach_more_loop_variables_than_dimensions;
  logic [1:0] m [2];
  initial begin
    foreach (m[i, j]) m[i][j] = 1'b1;
    foreach (m[, j]) $display("j=%0d", j);
    foreach (m[i]) $display("i=%0d", i);
    foreach (m[i, j, k]) $display("%0d %0d %0d", i, j, k);   // illegal
  end
endmodule

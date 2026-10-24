/*
:name: test_illegal_foreach_loop_variable_named_as_array
:description: a foreach loop variable cannot have the identifier of the array (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second loop variable of the foreach-loop over arr is named arr
:expected_stderr_regex: test_illegal_foreach_loop_variable_named_as_array\.sv:26:
*/
// IEEE 1800-2023 §12.7.3: it shall be an error for a loop variable of a
// foreach-loop to have the same identifier as the array. The first loop names
// its loop variables i and j; the second names its second loop variable arr,
// the identifier of the array it iterates over.
// Icarus Verilog 13.0 and Verilator 5.052 reject the line, but with a message
// that the loop variables are more than the dimensions of the array, so the
// rejection is not listed as following the rule.

module test_illegal_foreach_loop_variable_named_as_array;
  int arr [2][3];
  initial begin
    foreach (arr[i, j]) arr[i][j] = i + j;
    foreach (arr[i, arr]) $display("%0d", i);   // illegal
  end
endmodule

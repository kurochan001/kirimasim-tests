/*
:name: test_illegal_array_query_variable_dimension
:description: An array query function with a dimension number cannot name a variable-sized dimension after the first (IEEE 1800-2023 Section 20.7.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.7.1 20.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $size names the second dimension of grid, which is a queue
:expected_stderr_regex: test_illegal_array_query_variable_dimension\.sv:20:
*/
// IEEE 1800-2023 §20.7.1: calling an array query function with (v, n), n
// greater than 1, is an error when dimension n of v is variable-sized. The
// second dimension of grid is a queue.

module test_illegal_array_query_variable_dimension;
  int grid [3][$];
  initial $display("%0d", $size(grid, 2));   // illegal: dimension 2 is a queue
endmodule

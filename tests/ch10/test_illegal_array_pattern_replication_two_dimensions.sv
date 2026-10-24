/*
:name: test_illegal_array_pattern_replication_two_dimensions
:description: a replication in an array assignment pattern stands for exactly one dimension, so one replication cannot fill a two-dimensional array (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the replication '{6{y}} is used for both dimensions of the array n of 2 by 3 elements
:expected_stderr_regex: test_illegal_array_pattern_replication_two_dimensions\.sv:29:
*/
// IEEE 1800-2023 §10.9.1: a replication can be used in an array assignment
// pattern, and each replication shall represent an entire single dimension.
// n has 2 by 3 elements: one replication per dimension, and a replication
// for an inner dimension next to a positional subpattern, are legal; one
// replication of 6 for both dimensions is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal replications, so
// its error does not count.

module test_illegal_array_pattern_replication_two_dimensions;
  int n [2][3];
  int y = 5;

  initial begin
    n = '{2{'{3{y}}}};
    n = '{'{y, y, y}, '{3{y}}};
    n = '{6{y}};   // illegal: one replication for two dimensions
    $display("%p", n);
  end
endmodule

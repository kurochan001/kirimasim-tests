/*
:name: test_illegal_part_select_variable_msb_of_net
:description: the first bound of a non-indexed part-select of a net has to be a constant expression (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first bound of the non-indexed part-select w[m:0] in a continuous assignment is the variable m
:expected_stderr_regex: test_illegal_part_select_variable_msb_of_net\.sv:27:
*/
// IEEE 1800-2023 §11.5.1: both bounds of a non-indexed part-select
// [msb_expr:lsb_expr] shall be constant integer expressions. In continuous
// assignments, w[M:0] has the parameter M as its first bound, which is
// legal; w[m:0] has the variable m there, which is not a constant
// expression. The second bound is a constant in both selects.

module test_illegal_part_select_variable_msb_of_net;
  parameter int M = 3;
  wire [7:0] w = 8'ha5;
  int m = 3;
  wire [3:0] a, b;

  assign a = w[M:0];
  assign b = w[m:0];   // illegal: the first bound is not a constant expression
endmodule

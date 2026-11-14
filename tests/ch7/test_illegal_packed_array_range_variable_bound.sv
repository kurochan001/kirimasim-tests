/*
:name: test_illegal_packed_array_range_variable_bound
:description: a bound of a packed dimension of a packed array has to be a constant expression; a variable is illegal (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left bound of the second packed dimension of bad is the variable width, which is not a constant expression
:expected_stderr_regex: test_illegal_packed_array_range_variable_bound\.sv:38:
*/
// IEEE 1800-2023 §7.4.1: each packed dimension of a packed array is a range
// of two constant expressions. Each bound may be any integer value,
// positive, negative or zero, without x or z bits, and the first bound may
// be greater than, equal to or less than the second. The legal arrays have
// two packed dimensions each: bounds that descend through a negative value,
// an ascending negative range, a single-element range at zero, and equal
// bounds. The legal design prints their widths and the bounds of both
// dimensions of each (10 4 3, then 3 -1 0 1, -2 1 0 0, 2 2 -3 -1).
// The left bound of the second packed dimension of bad is a variable.

module test_illegal_packed_array_range_variable_bound;
  int width = 3;
  bit [3:-1][0:1] down_up;
  logic [-2:1][0:0] neg_zero;
  bit [2:2][-3:-1] equal_neg;
  initial begin
    $display("%0d %0d %0d", $bits(down_up), $bits(neg_zero), $bits(equal_neg));
    $display("%0d %0d %0d %0d", $left(down_up, 1), $right(down_up, 1), $left(down_up, 2),
             $right(down_up, 2));
    $display("%0d %0d %0d %0d", $left(neg_zero, 1), $right(neg_zero, 1), $left(neg_zero, 2),
             $right(neg_zero, 2));
    $display("%0d %0d %0d %0d", $left(equal_neg, 1), $right(equal_neg, 1), $left(equal_neg, 2),
             $right(equal_neg, 2));
  end
  bit [1:0][width:0] bad;   // illegal: a variable as a bound
endmodule

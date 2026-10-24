/*
:name: test_illegal_array_pattern_element_count_differs
:description: the expressions of a positional array assignment pattern have to match the array element for element (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the positional assignment pattern for the array a3 of three elements has two expressions
:expected_stderr_regex: test_illegal_array_pattern_element_count_differs\.sv:27:
*/
// IEEE 1800-2023 §10.9.1: the expressions of an array assignment pattern shall
// match the elements one for one, and each one is evaluated as an assignment
// to the element type, so int values for bit elements and 1'b1 for int
// elements need no size match. The patterns for ub and a3 with one value per
// element are legal; the pattern with two values for three elements is not.

module test_illegal_array_pattern_element_count_differs;
  bit ub [2];
  int a3 [3];

  initial begin
    ub = '{1, 1};
    a3 = '{1'b1, 2, 3};
    a3 = '{4, 5};   // illegal: two expressions for three elements
    $display("%p %p", ub, a3);
  end
endmodule

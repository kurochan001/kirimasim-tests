/*
:name: test_illegal_assertion_expression_unpacked_array
:description: the expression of a concurrent assertion has to be cast compatible with an integral type, though its subexpressions need not (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the whole expression of p_bad is the unpacked array arr, which is not cast compatible with an integral type
:expected_stderr_regex: test_illegal_assertion_expression_unpacked_array\.sv:28:
*/
// IEEE 1800-2023 §16.6: an expression in a concurrent assertion shall have a
// type cast compatible with an integral type; its subexpressions need not,
// as long as the whole expression is. In p_eq the unpacked arrays arr and
// arr2 are operands of an equality whose result is one bit, and in p_el an
// element of arr is compared; both are legal. The whole expression of p_bad
// is the unpacked array arr itself.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 fails when it compiles the C++ code it generates, which does not count.

module test_illegal_assertion_expression_unpacked_array;
  logic clk = 0;
  int arr [2], arr2 [2];
  p_eq: assert property (@(posedge clk) arr == arr2);
  p_el: assert property (@(posedge clk) arr[0] == 0);
  p_bad: assert property (@(posedge clk) arr);   // illegal
endmodule

/*
:name: test_illegal_cycle_delay_range_variable_bound
:description: the bounds of a cycle delay range have to be constant expressions (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the upper bound of the cycle delay range of p_bad is the variable n, which is not a constant expression
:expected_stderr_regex: test_illegal_cycle_delay_range_variable_bound\.sv:28:
*/
// IEEE 1800-2023 §16.7: the constant_primary of a cycle delay is a constant
// expression computed at compile time, which shall result in an integer
// value, and it and the bounds of a cycle delay range shall be 0 or
// greater. In p_ok the upper bound of the range is the parameter M and in
// p_u it is $; in p_bad it is the module variable n.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_cycle_delay_range_variable_bound;
  logic clk = 0, a = 0, b = 0;
  int n = 3;
  localparam int M = 3;
  p_ok: assert property (@(posedge clk) a |-> ##[1:M] b);
  p_u: assert property (@(posedge clk) a |-> ##[1:$] b);
  p_bad: assert property (@(posedge clk) a |-> ##[1:n] b);   // illegal
endmodule

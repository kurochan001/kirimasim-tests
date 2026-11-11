/*
:name: test_illegal_cycle_delay_mintypmax
:description: the constant_primary of a cycle delay cannot be a min:typ:max expression (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cycle delay of p_bad is the min:typ:max expression (1:2:3)
:expected_stderr_regex: test_illegal_cycle_delay_mintypmax\.sv:25:
*/
// IEEE 1800-2023 §16.7: in a cycle_delay_range, the constant_primary shall
// not contain a constant_mintypmax_expression that is not also a
// constant_expression. In p_ok the delay is the parenthesized constant
// expression (2); in p_bad it is (1:2:3).
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 reports a syntax error on this line, although the grammar allows a
// parenthesized min:typ:max expression there; neither counts.

module test_illegal_cycle_delay_mintypmax;
  logic clk = 0, a = 0, b = 0;
  p_ok: assert property (@(posedge clk) a |-> ##(2) b);
  p_bad: assert property (@(posedge clk) a |-> ##(1:2:3) b);   // illegal
endmodule

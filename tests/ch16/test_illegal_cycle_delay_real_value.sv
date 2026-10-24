/*
:name: test_illegal_cycle_delay_real_value
:description: a cycle delay has to result in an integer value (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cycle delay of p_bad is the real constant 1.5, which is not an integer value
:expected_stderr_regex: test_illegal_cycle_delay_real_value\.sv:27:
*/
// IEEE 1800-2023 §16.7: the constant_primary of a cycle delay is a constant
// expression computed at compile time, which shall result in an integer
// value, and it and the bounds of a cycle delay range shall be 0 or
// greater.
// In p_ok the delay is the integer constant (1 + 1); in p_bad it is the real
// constant 1.5.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 reports this line as exceeding an implementation limit; neither
// counts.

module test_illegal_cycle_delay_real_value;
  logic clk = 0, a = 0, b = 0;
  p_ok: assert property (@(posedge clk) a |-> ##(1 + 1) b);
  p_bad: assert property (@(posedge clk) a |-> ##(1.5) b);   // illegal
endmodule

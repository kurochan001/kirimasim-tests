/*
:name: test_illegal_cycle_delay_negative_range_bound
:description: the bounds of a cycle delay range cannot be negative (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the lower bound of the cycle delay range of p_bad is the parameter N, whose value is -1
:expected_stderr_regex: test_illegal_cycle_delay_negative_range_bound\.sv:27:
*/
// IEEE 1800-2023 §16.7: the constant_primary of a cycle delay is a constant
// expression computed at compile time, which shall result in an integer
// value, and it and the bounds of a cycle delay range shall be 0 or
// greater.
// In p_ok the range is ##[0:2]; in p_bad its lower bound is the parameter N,
// whose value is -1.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_cycle_delay_negative_range_bound;
  logic clk = 0, a = 0, b = 0;
  localparam int N = -1;
  p_ok: assert property (@(posedge clk) a |-> ##[0:2] b);
  p_bad: assert property (@(posedge clk) a |-> ##[N:2] b);   // illegal
endmodule

/*
:name: test_illegal_cycle_delay_range_reversed
:description: the second bound of a cycle delay range cannot be less than the first (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cycle delay range of p_bad is ##[3:1], whose second bound is less than the first
:expected_stderr_regex: test_illegal_cycle_delay_range_reversed\.sv:24:
*/
// IEEE 1800-2023 §16.7: when a cycle delay range has two expressions, the
// second shall be greater than or equal to the first. p_ok uses ##[1:3]
// and p_eq ##[2:2], whose bounds are equal; p_bad uses ##[3:1].
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_cycle_delay_range_reversed;
  logic clk = 0, a = 0, b = 0;
  p_ok: assert property (@(posedge clk) a |-> ##[1:3] b);
  p_eq: assert property (@(posedge clk) a |-> ##[2:2] b);
  p_bad: assert property (@(posedge clk) a |-> ##[3:1] b);   // illegal
endmodule

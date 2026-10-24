/*
:name: test_illegal_repetition_range_reversed
:description: the minimum of a repetition range cannot be greater than its maximum (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the consecutive repetition range of p_bad is [*3:1], whose minimum is greater than its maximum
:expected_stderr_regex: test_illegal_repetition_range_reversed\.sv:25:
*/
// IEEE 1800-2023 §16.9.2: when both the minimum and the maximum of a
// repetition range are constant expressions, the minimum shall be less than
// or equal to the maximum. p_ok uses [*1:3] and p_eq [*2:2]; p_bad uses
// [*3:1].
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_repetition_range_reversed;
  logic clk = 0, a = 0, b = 0;
  p_ok: assert property (@(posedge clk) a |-> b[*1:3]);
  p_eq: assert property (@(posedge clk) a |-> b[*2:2]);
  p_bad: assert property (@(posedge clk) a |-> b[*3:1]);   // illegal
endmodule

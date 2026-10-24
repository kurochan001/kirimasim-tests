/*
:name: test_illegal_repetition_lower_bound_negative
:description: the minimum of a repetition range cannot be negative (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the minimum of the consecutive repetition range in p_bad is the parameter N, whose value is -1
:expected_stderr_regex: test_illegal_repetition_lower_bound_negative\.sv:26:
*/
// IEEE 1800-2023 §16.9.2: the exact count of a repetition and the minimum
// of a repetition range are non-negative integer constant expressions, and
// the maximum of a range is one too or $. p_ok uses the range [*0:2], whose
// minimum 0 is the smallest legal value; p_bad uses the minimum N, whose
// value is -1.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_repetition_lower_bound_negative;
  logic clk = 0, a = 0, b = 0;
  localparam int N = -1;
  p_ok: assert property (@(posedge clk) a |-> ##1 b[*0:2] ##1 a);
  p_bad: assert property (@(posedge clk) a |-> ##1 b[*N:2] ##1 a);   // illegal
endmodule

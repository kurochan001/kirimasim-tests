/*
:name: test_illegal_repetition_count_negative
:description: the count of a repetition cannot be negative (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the exact count of the consecutive repetition in p_bad is the parameter N, whose value is -1
:expected_stderr_regex: test_illegal_repetition_count_negative\.sv:26:
*/
// IEEE 1800-2023 §16.9.2: the exact count of a repetition and the minimum
// of a repetition range are non-negative integer constant expressions, and
// the maximum of a range is one too or $.
// p_ok repeats b exactly [*2] times; p_bad uses the count N, whose value
// is -1.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_repetition_count_negative;
  logic clk = 0, a = 0, b = 0;
  localparam int N = -1;
  p_ok: assert property (@(posedge clk) a |-> b[*2]);
  p_bad: assert property (@(posedge clk) a |-> b[*N]);   // illegal
endmodule

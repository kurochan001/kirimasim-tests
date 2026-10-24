/*
:name: test_illegal_repetition_count_variable
:description: the count of a repetition has to be a constant expression (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the exact count of the goto repetition in p_bad is the variable n, which is not a constant expression
:expected_stderr_regex: test_illegal_repetition_count_variable\.sv:27:
*/
// IEEE 1800-2023 §16.9.2: the exact count of a repetition and the minimum
// of a repetition range are non-negative integer constant expressions, and
// the maximum of a range is one too or $.
// p_ok uses the parameter C as the count of a goto repetition; p_bad uses the
// module variable n.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_repetition_count_variable;
  logic clk = 0, a = 0, b = 0;
  int n = 2;
  localparam int C = 2;
  p_ok: assert property (@(posedge clk) a |-> b[->C]);
  p_bad: assert property (@(posedge clk) a |-> b[->n]);   // illegal
endmodule

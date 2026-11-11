/*
:name: test_illegal_sequence_untyped_repetition_actual_variable
:description: an untyped sequence formal used as a repetition count needs an elaboration-time constant actual (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_r in p_bad passes the variable n to the formal k, which s_r uses as a repetition count
:expected_stderr_regex: test_illegal_sequence_untyped_repetition_actual_variable\.sv:(29|32):
*/
// IEEE 1800-2023 §16.8: the actual of an untyped formal is substituted for
// its references, and the result has to be a legal sequence; a reference to
// an untyped formal may therefore be the count of a repetition only if the
// actual is an elaboration-time constant. s_r uses its formal k as the count
// of a consecutive repetition. p_ok passes the parameter C; p_bad passes the
// module variable n. A tool can report the error at the instance or in s_r.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 rejects the use of k as a count in s_r even when every actual is a
// constant; neither error counts.

module test_illegal_sequence_untyped_repetition_actual_variable;
  logic clk = 0, a = 0, b = 0;
  int n = 2;
  localparam int C = 2;
  sequence s_r(x, k);
    x[*k];
  endsequence
  p_ok: assert property (@(posedge clk) a |-> s_r(b, C));
  p_bad: assert property (@(posedge clk) a |-> s_r(b, n));   // illegal
endmodule

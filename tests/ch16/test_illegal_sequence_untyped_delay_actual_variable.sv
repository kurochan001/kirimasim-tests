/*
:name: test_illegal_sequence_untyped_delay_actual_variable
:description: an untyped sequence formal used as a cycle delay needs an elaboration-time constant actual (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_d in p_bad passes the variable n to the formal d, which s_d uses as a cycle delay
:expected_stderr_regex: test_illegal_sequence_untyped_delay_actual_variable\.sv:(29|33):
*/
// IEEE 1800-2023 §16.8: the actual of an untyped formal is substituted for
// its references, and the result has to be a legal sequence; a reference to
// an untyped formal may therefore be a cycle delay only if the actual is an
// elaboration-time constant. s_d uses its formal d as the delay. p_ok passes
// the parameter D and p_lit the literal 1; p_bad passes the module variable
// n. A tool can report the error at the instance or in s_d.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 rejects the use of d as a delay in s_d even when every actual is a
// constant; neither error counts.

module test_illegal_sequence_untyped_delay_actual_variable;
  logic clk = 0, a = 0, b = 0;
  int n = 2;
  localparam int D = 2;
  sequence s_d(x, y, d);
    x ##d y;
  endsequence
  p_ok: assert property (@(posedge clk) s_d(a, b, D));
  p_lit: assert property (@(posedge clk) s_d(a, b, 1));
  p_bad: assert property (@(posedge clk) s_d(a, b, n));   // illegal
endmodule

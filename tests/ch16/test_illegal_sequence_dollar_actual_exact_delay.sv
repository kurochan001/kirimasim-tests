/*
:name: test_illegal_sequence_dollar_actual_exact_delay
:description: a $ actual is allowed only for an untyped formal used as the upper bound of a delay range or as an actual itself (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_d in p_bad passes $ to the formal d, which s_d uses as an exact cycle delay
:expected_stderr_regex: test_illegal_sequence_dollar_actual_exact_delay\.sv:(32|36):
*/
// IEEE 1800-2023 §16.8: if $ is the actual of a formal, the formal shall be
// untyped and each of its references shall be the upper bound of a cycle
// delay range or an actual in an instance of a named sequence. s_up uses m as
// such an upper bound, and s_pass passes m on to s_up, so p_up and p_pass
// are legal; s_d uses d as an exact delay, ##d, and p_bad passes $ to it.
// A tool can report the error at the instance or in s_d.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 also rejects the legal upper bound m of s_up; neither error counts.

module test_illegal_sequence_dollar_actual_exact_delay;
  logic clk = 0, a = 0, b = 0;
  sequence s_up(x, y, m);
    x ##[1:m] y;
  endsequence
  sequence s_pass(x, y, m);
    s_up(x, y, m);
  endsequence
  sequence s_d(x, y, d);
    x ##d y;
  endsequence
  p_up: assert property (@(posedge clk) a |-> s_up(a, b, $));
  p_pass: assert property (@(posedge clk) a |-> s_pass(a, b, $));
  p_bad: assert property (@(posedge clk) a |-> s_d(a, b, $));   // illegal
endmodule

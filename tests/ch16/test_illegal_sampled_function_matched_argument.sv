/*
:name: test_illegal_sampled_function_matched_argument
:description: the argument of a sampled value function cannot use the sequence method matched (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument of $rose in a_bad is s.matched
:expected_stderr_regex: test_illegal_sampled_function_matched_argument\.sv:27:
*/
// IEEE 1800-2023 §16.9.3: local variables (16.10) and the sequence method
// matched are not allowed in the argument expressions of sampled value
// functions. a_ok uses s.matched as an operand of the sequence and $rose(a)
// with a variable; a_bad passes s.matched to $rose.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support the method matched; neither error counts.

module test_illegal_sampled_function_matched_argument;
  logic clk = 0, a = 0, b = 0, c = 0;
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  a_ok: assert property (@(posedge clk) c ##1 s.matched |-> $rose(a));
  a_bad: assert property (@(posedge clk) c |-> $rose(s.matched));   // illegal
endmodule

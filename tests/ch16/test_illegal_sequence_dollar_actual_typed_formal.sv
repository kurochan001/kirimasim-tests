/*
:name: test_illegal_sequence_dollar_actual_typed_formal
:description: a $ actual is allowed only for an untyped formal (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_t in p_bad passes $ to the formal m, which is typed int
:expected_stderr_regex: test_illegal_sequence_dollar_actual_typed_formal\.sv:(28|33):
*/
// IEEE 1800-2023 §16.8: if $ is the actual of a formal, the formal shall be
// untyped and each of its references shall be the upper bound of a cycle
// delay range or an actual in an instance of a named sequence. s_up and s_t
// use m only as such an upper bound; m of s_up is untyped, so p_up is legal,
// while m of s_t has the type int, and p_bad passes $ to it. A tool can
// report the error at the instance or at the formal.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 also rejects the legal upper bound m of s_up; neither error counts.

module test_illegal_sequence_dollar_actual_typed_formal;
  logic clk = 0, a = 0, b = 0;
  sequence s_up(x, y, m);
    x ##[1:m] y;
  endsequence
  sequence s_t(x, y, int m);
    x ##[1:m] y;
  endsequence
  p_up: assert property (@(posedge clk) a |-> s_up(a, b, $));
  p_t: assert property (@(posedge clk) a |-> s_t(a, b, 3));
  p_bad: assert property (@(posedge clk) a |-> s_t(a, b, $));   // illegal
endmodule

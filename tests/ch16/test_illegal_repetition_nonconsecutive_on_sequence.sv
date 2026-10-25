/*
:name: test_illegal_repetition_nonconsecutive_on_sequence
:description: nonconsecutive repetition can be applied only to a Boolean expression (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nonconsecutive repetition in p_bad is applied to the sequence (a ##1 b)
:expected_stderr_regex: test_illegal_repetition_nonconsecutive_on_sequence\.sv:29:
*/
// IEEE 1800-2023 §16.9.2: consecutive repetition can be applied to any
// sequence expression, but goto and nonconsecutive repetition only to a
// Boolean expression, and not to one with an attached sequence match
// item.
// p_ok applies consecutive repetition to the sequence (a ##1 b) and p_n
// nonconsecutive repetition to the Boolean expression (a && b); p_bad applies
// nonconsecutive repetition to the sequence (a ##1 b).
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 reports this line as a cycle delay used as an intra-assignment delay;
// neither counts.

module test_illegal_repetition_nonconsecutive_on_sequence;
  logic clk = 0, a = 0, b = 0, c = 0;
  p_ok: assert property (@(posedge clk) c |-> (a ##1 b)[*2]);
  p_n: assert property (@(posedge clk) c |-> (a && b)[=2]);
  p_bad: assert property (@(posedge clk) c |-> (a ##1 b)[=2]);   // illegal
endmodule

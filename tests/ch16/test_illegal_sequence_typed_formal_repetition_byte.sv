/*
:name: test_illegal_sequence_typed_formal_repetition_byte
:description: a typed sequence formal used as a repetition count has to be shortint, int or longint (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the formal k of s_bad, used as a repetition count, has the type byte
:expected_stderr_regex: test_illegal_sequence_typed_formal_repetition_byte\.sv:(30|33):
*/
// IEEE 1800-2023 §16.8.1: if a typed formal of a named sequence is
// referenced in a cycle delay, a consecutive, goto or nonconsecutive
// repetition, its type shall be shortint, int or longint.
// s_l uses a formal of type longint as the count of a consecutive
// repetition, which is legal; s_bad uses a formal of type byte. A tool can
// report the error in s_bad or at its instance.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 also rejects the count given by the legal longint formal; neither
// error counts.

module test_illegal_sequence_typed_formal_repetition_byte;
  logic clk = 0, a = 0, b = 0;
  sequence s_l(x, longint k);
    x[*k];
  endsequence
  sequence s_bad(x, byte k);
    x[*k];   // illegal
  endsequence
  p_l: assert property (@(posedge clk) a |-> s_l(b, 2));
  p_bad: assert property (@(posedge clk) a |-> s_bad(b, 2));
endmodule

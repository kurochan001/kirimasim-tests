/*
:name: test_illegal_sequence_typed_formal_delay_bit_vector
:description: a typed sequence formal used as a cycle delay has to be shortint, int or longint (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the formal d of s_bad, used as a cycle delay, has the type bit [7:0]
:expected_stderr_regex: test_illegal_sequence_typed_formal_delay_bit_vector\.sv:(33|37):
*/
// IEEE 1800-2023 §16.8.1: if a typed formal of a named sequence is
// referenced in a cycle delay, a consecutive, goto or nonconsecutive
// repetition, its type shall be shortint, int or longint.
// s_i and s_s use formals of type int and shortint as the delay, which is
// legal; s_bad uses a formal of type bit [7:0]. A tool can report the
// error in s_bad or at its instance.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 also rejects the delays given by the legal int and shortint formals;
// neither error counts.

module test_illegal_sequence_typed_formal_delay_bit_vector;
  logic clk = 0, a = 0, b = 0;
  sequence s_i(x, y, int d);
    x ##d y;
  endsequence
  sequence s_s(x, y, shortint d);
    x ##d y;
  endsequence
  sequence s_bad(x, y, bit [7:0] d);
    x ##d y;   // illegal
  endsequence
  p_i: assert property (@(posedge clk) s_i(a, b, 2));
  p_s: assert property (@(posedge clk) s_s(a, b, 2));
  p_bad: assert property (@(posedge clk) s_bad(a, b, 2));
endmodule

/*
:name: test_illegal_sequence_formal_chandle_type
:description: the type of a typed sequence formal has to be sequence or a type allowed for operands of assertion expressions, which excludes chandle (IEEE 1800-2023 Sections 16.8 and 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the formal h of s_ch has the type chandle, which is not allowed in assertion expressions
:expected_stderr_regex: test_illegal_sequence_formal_chandle_type\.sv:31:
*/
// IEEE 1800-2023 §16.8 and §16.8.1: a typed formal of a named sequence shall
// have the type sequence or a type allowed for operands of assertion
// expressions (16.6), and 16.6 excludes chandle. The formals of s_ok have
// the types sequence, bit and int, and that of s_un is untyped, which is
// legal; the formal h of s_ch has the type chandle. s_ch is not instantiated,
// so its declaration is the only place of the error.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support the typed formals of s_ok; neither error counts.

module test_illegal_sequence_formal_chandle_type;
  logic clk = 0, a = 0, b = 0;
  sequence s_ok(sequence q, bit e, int k);
    q ##1 (e && k > 0);
  endsequence
  sequence s_un(x);
    x ##1 b;
  endsequence
  sequence s_ch(chandle h);   // illegal
    a ##1 b;
  endsequence
  p_ok: assert property (@(posedge clk) s_ok(a, b, 1));
  p_un: assert property (@(posedge clk) s_un(a));
endmodule

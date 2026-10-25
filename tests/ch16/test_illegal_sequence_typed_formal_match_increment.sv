/*
:name: test_illegal_sequence_typed_formal_match_increment
:description: a typed sequence formal that is not a local variable argument cannot be incremented in a match item (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the match item of s_bad increments its typed formal x, which is not a local variable argument
:expected_stderr_regex: test_illegal_sequence_typed_formal_match_increment\.sv:28:
*/
// IEEE 1800-2023 §16.8.1: a reference to a typed formal in a sequence
// match item shall not be the variable_lvalue of an assignment or of an
// increment or decrement, unless the formal is a local variable argument
// (16.8.2). s_loc assigns and increments its local input formal y, which
// is legal; s_bad increments its typed formal x.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support local variable arguments; neither error counts.

module test_illegal_sequence_typed_formal_match_increment;
  logic clk = 0, a = 0, b = 0;
  sequence s_loc(local input int y);
    (a, y = 1) ##1 (b, y++);
  endsequence
  sequence s_bad(int x);
    (a, x++) ##1 b;   // illegal
  endsequence
endmodule

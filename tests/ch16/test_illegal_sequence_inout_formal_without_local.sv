/*
:name: test_illegal_sequence_inout_formal_without_local
:description: A sequence formal that gives the direction inout has to be declared local as well (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port item gives the direction inout without the keyword local
:expected_stderr_regex: test_illegal_sequence_inout_formal_without_local\.sv:27:
*/
// IEEE 1800-2023 §16.8.2: a formal of a named sequence may give one of the
// directions input, inout or output only together with the keyword local,
// which makes it a local variable formal. The formal x of s_dir gives
// inout without local. Without the direction, x would be an ordinary
// typed formal and the design would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not parse a direction in the port list of a sequence, so the
// syntax errors they report on that line do not count.

module test_illegal_sequence_inout_formal_without_local;
  logic clk, a, b, c;
  int d;

  sequence s_dir(inout logic x);   // illegal: inout without local
    a ##1 x;
  endsequence

  c_dir: cover sequence (@(posedge clk) s_dir(b));
endmodule

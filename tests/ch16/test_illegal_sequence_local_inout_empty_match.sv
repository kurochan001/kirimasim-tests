/*
:name: test_illegal_sequence_local_inout_empty_match
:description: An instance of a sequence with a local inout formal cannot admit an empty match (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_e, which has a local inout formal, admits an empty match
:expected_stderr_regex: test_illegal_sequence_local_inout_empty_match\.sv:(29|34):
*/
// IEEE 1800-2023 §16.8.2: an instance of a named sequence that has a local
// inout or output formal shall not admit an empty match. The body of s_e
// repeats its subsequence zero or one time, so the instance s_e(y) can
// match without any tick. The local inout formal is initialized from y,
// and the match item is attached to a, which cannot match empty. A tool
// can report the error at the body or at the instance.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_inout_empty_match;
  logic clk, clk2, a, b, c;
  int d;

  sequence s_e(local inout int v);
    (a, v += 1)[*0:1];   // illegal: admits an empty match
  endsequence

  sequence use_e;
    int y = 0;
    b ##1 s_e(y) ##1 c;   // illegal: instance with a local inout formal
  endsequence

  c_e: cover sequence (@(posedge clk) use_e);
endmodule

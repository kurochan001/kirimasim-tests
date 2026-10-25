/*
:name: test_illegal_sequence_local_output_unassigned
:description: Every match of a sequence has to assign its local output formal (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the match of s_maybe through b completes with the local output formal v unassigned
:expected_stderr_regex: test_illegal_sequence_local_output_unassigned\.sv:(29|34):
*/
// IEEE 1800-2023 §16.8.2: a local output formal starts each attempt
// unassigned, and it is an error if some match of the named sequence
// completes with an inout or output local formal unassigned. s_maybe
// assigns v only in the operand (a, v = d) of or; a match through b leaves
// v unassigned. The caller does not read y. A tool can report the error
// at the body or at the instance.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_output_unassigned;
  logic clk, clk2, a, b, c;
  int d;

  sequence s_maybe(local output int v);
    (a, v = d) or b;   // illegal: a match through b leaves v unassigned
  endsequence

  sequence use_m;
    int y;
    s_maybe(y) ##1 c;   // illegal: instance of s_maybe
  endsequence

  c_m: cover sequence (@(posedge clk) use_m);
endmodule

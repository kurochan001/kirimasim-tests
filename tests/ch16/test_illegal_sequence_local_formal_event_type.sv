/*
:name: test_illegal_sequence_local_formal_event_type
:description: A local variable formal of a sequence cannot have the type event, which assertion expressions do not allow (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local formal e has the type event, which is not a type allowed by 16.6
:expected_stderr_regex: test_illegal_sequence_local_formal_event_type\.sv:26:
*/
// IEEE 1800-2023 §16.8.2: the type of a local variable formal has to be one
// that §16.6 allows in assertion expressions, that is, one cast compatible
// with an integral type; event is not. The sequence is not instantiated, so
// no actual argument is involved; the declaration alone is the error.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_formal_event_type;
  logic clk, a, b, c;
  int d;

  sequence s_ev(local event e);   // illegal: event local formal
    a ##1 b;
  endsequence
endmodule

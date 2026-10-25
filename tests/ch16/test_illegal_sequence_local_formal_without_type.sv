/*
:name: test_illegal_sequence_local_formal_without_type
:description: A local variable formal of a sequence has to give its type in its own port item (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local formal x has no explicit type
:expected_stderr_regex: test_illegal_sequence_local_formal_without_type\.sv:26:
*/
// IEEE 1800-2023 §16.8.2: a port item with the keyword local has to give the
// type of the formal explicitly; it is not taken from an earlier item and
// there is no implicit type. The formal x of s_t is local without a type.
// With a type such as int the design would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_formal_without_type;
  logic clk, a, b, c;
  int d;

  sequence s_t(local x);   // illegal: local formal without a type
    a ##1 (b == x);
  endsequence

  c_t: cover sequence (@(posedge clk) s_t(d));
endmodule

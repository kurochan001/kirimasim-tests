/*
:name: test_illegal_sequence_local_inout_default
:description: A local inout formal of a sequence cannot have a default actual argument (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local inout formal v declares a default actual argument
:expected_stderr_regex: test_illegal_sequence_local_inout_default\.sv:27:
*/
// IEEE 1800-2023 §16.8.2: only a local formal of direction input may have a
// default actual argument; a local inout or output formal may not have
// one. s_def declares the local inout formal v with the default 0.
// The instance gives a local variable as the actual, so the design would
// be legal without the default.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_inout_default;
  logic clk, a, b, c;
  int d;

  sequence s_def(local inout int v = 0);   // illegal: default for inout
    (a, v += 1);
  endsequence

  sequence use_def;
    int y = 1;
    s_def(y) ##1 b;
  endsequence

  c_def: cover sequence (@(posedge clk) use_def);
endmodule

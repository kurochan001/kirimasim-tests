/*
:name: test_illegal_sequence_local_input_actual_unassigned
:description: The actual of a local formal, which is input when no direction is given, cannot be a local variable that is unassigned there (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual y of the local input formal v is unassigned at the instance
:expected_stderr_regex: test_illegal_sequence_local_input_actual_unassigned\.sv:34:
*/
// IEEE 1800-2023 §16.8.2: a local formal without a direction has the
// direction input, and it is an error if the actual of a local input or
// inout formal references a local variable that is unassigned at that
// point of the instantiating sequence. The local variable y of use_in has
// no initial value and is not assigned before s_in(y). For a local output
// formal the same actual would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_input_actual_unassigned;
  logic clk, clk2, a, b, c;
  int d;

  sequence s_in(local int v);
    a ##1 (b && v > 0);
  endsequence

  sequence use_in;
    int y;
    c ##1 s_in(y);   // illegal: y is unassigned here
  endsequence

  c_in: cover sequence (@(posedge clk) use_in);
endmodule

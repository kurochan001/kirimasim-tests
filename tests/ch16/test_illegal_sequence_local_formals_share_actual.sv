/*
:name: test_illegal_sequence_local_formals_share_actual
:description: One local variable cannot be the actual of two local inout or output formals of the same instance (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the local variable y is bound to both the local inout formal p and the local output formal q
:expected_stderr_regex: test_illegal_sequence_local_formals_share_actual\.sv:32:
*/
// IEEE 1800-2023 §16.8.2: it is an error to bind references to the same local
// variable to two or more local formals of direction inout or output. The
// instance s_two(y, y) binds y to the inout formal p and the output formal
// q. With two different local variables the design would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_sequence_local_formals_share_actual;
  logic clk, clk2, a, b, c;
  int d;

  sequence s_two(local inout int p, local output int q);
    (a, p += 1, q = d);
  endsequence

  sequence use_two;
    int y = 0;
    s_two(y, y) ##1 b;   // illegal: y bound to two inout/output formals
  endsequence

  c_two: cover sequence (@(posedge clk) use_two);
endmodule

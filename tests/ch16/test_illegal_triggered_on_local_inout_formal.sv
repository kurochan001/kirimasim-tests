/*
:name: test_illegal_triggered_on_local_inout_formal
:description: triggered cannot be applied to an instance of a sequence that has a local inout formal (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: triggered is applied to an instance of s_t, which has the local inout formal v
:expected_stderr_regex: test_illegal_triggered_on_local_inout_formal\.sv:33:
*/
// IEEE 1800-2023 §16.8.2: the sequence methods triggered and matched shall
// not be applied to an instance of a named sequence with a local input or
// inout formal. s_t has the local inout formal v; use_t passes its local
// variable y, which is assigned before, and applies triggered to the
// instance. s_t assigns v before reading it.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_triggered_on_local_inout_formal;
  logic clk, clk2, a, b, c;
  int d;

  sequence s_t(local inout int v);
    @(posedge clk) (a, v = 3) ##1 (b && v == 3);
  endsequence

  sequence use_t;
    int y = 0;
    c ##1 s_t(y).triggered;   // illegal: triggered with a local inout formal
  endsequence

  c_t: cover sequence (@(posedge clk) use_t);
endmodule

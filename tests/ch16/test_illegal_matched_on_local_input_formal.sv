/*
:name: test_illegal_matched_on_local_input_formal
:description: matched cannot be applied to an instance of a sequence that has a local input formal (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: matched is applied to an instance of s_m, which has the local input formal v
:expected_stderr_regex: test_illegal_matched_on_local_input_formal\.sv:30:
*/
// IEEE 1800-2023 §16.8.2: the sequence methods triggered and matched shall
// not be applied to an instance of a named sequence with a local input or
// inout formal. s_m, clocked by clk, has the local input formal v; the
// cover, clocked by clk2, applies matched (§16.13.5) to an instance of it.
// Icarus Verilog 13.0 does not support concurrent assertions and Verilator
// 5.052 does not support local formal arguments of sequences, so the
// errors they report here do not count.

module test_illegal_matched_on_local_input_formal;
  logic clk, clk2, a, b, c;
  int d;

  sequence s_m(local input int v);
    @(posedge clk) a ##1 (b && v > 0);
  endsequence

  c_m: cover property (@(posedge clk2) c ##1 s_m(d).matched);   // illegal: matched
endmodule

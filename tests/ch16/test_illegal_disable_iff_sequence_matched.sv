/*
:name: test_illegal_disable_iff_sequence_matched
:description: a disable condition cannot use the sequence method matched, though it may use triggered (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition of a_bad uses s.matched
:expected_stderr_regex: test_illegal_disable_iff_sequence_matched\.sv:29:
*/
// IEEE 1800-2023 §16.6: the expression of a disable condition is evaluated
// with the current values of variables and may use the sequence method
// triggered, but it shall not reference local variables or the method
// matched. a_trig uses s.triggered and a_rst the variable rst in their
// disable conditions, which is legal; a_bad uses s.matched.
// Icarus Verilog 13.0 does not support these assertions, and Verilator 5.052
// does not support the sequence methods; their errors do not count.

module test_illegal_disable_iff_sequence_matched;
  logic clk = 0, rst = 0, a = 0, b = 0;
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  a_trig: assert property (@(posedge clk) disable iff (s.triggered) a |=> b);
  a_rst: assert property (@(posedge clk) disable iff (rst) a |=> b);
  a_bad: assert property (@(posedge clk) disable iff (s.matched) a |=> b);   // illegal
endmodule

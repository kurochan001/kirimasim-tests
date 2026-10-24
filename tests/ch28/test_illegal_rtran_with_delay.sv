/*
:name: test_illegal_rtran_with_delay
:description: An rtran switch does not accept a delay specification, while an rtranif0 switch accepts one (IEEE 1800-2023 Section 28.8)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the rtran switch r1 has the delay #(1, 2)
:expected_stderr_regex: test_illegal_rtran_with_delay\.sv:26:
*/
// IEEE 1800-2023 §28.8: tran and rtran devices shall not accept delay
// specifications, since pass switches have no delay through their
// bidirectional terminals; the switches with a control input may have one or
// two control delays. rs1 is an rtranif0 with #5, which is legal; r1 is an
// rtran with two delays.
// The 5.052 release of Verilator does not support rtran and rtranif0
// ("Unsupported: Verilog 1995 gate primitive"), which does not count.

module test_illegal_rtran_with_delay;
  logic en = 1'b0;
  wire a, b, c, d;
  rtranif0 #5 rs1 (a, b, en);
  rtran #(1, 2) r1 (c, d);   // illegal: rtran accepts no delay
  initial #1 $display("built");
endmodule

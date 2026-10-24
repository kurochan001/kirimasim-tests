/*
:name: test_illegal_tran_with_delay
:description: A tran switch does not accept a delay specification, while a tranif1 switch accepts one (IEEE 1800-2023 Section 28.8)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the tran switch t1 has the delay #3
:expected_stderr_regex: test_illegal_tran_with_delay\.sv:26:
*/
// IEEE 1800-2023 §28.8: bidirectional pass switches have no propagation delay
// through their bidirectional terminals, and tran and rtran devices shall not
// accept delay specifications. tranif0, tranif1, rtranif0 and rtranif1 may
// have one or two delays, which apply to their control input: ts1 has #(2, 4),
// which is legal. t1 is a tran with a delay.
// The 5.052 release of Verilator does not support tran and tranif1
// ("Unsupported: Verilog 1995 gate primitive"), which does not count.

module test_illegal_tran_with_delay;
  logic en = 1'b1;
  wire a, b, c, d;
  tranif1 #(2, 4) ts1 (a, b, en);
  tran #3 t1 (c, d);   // illegal: tran accepts no delay
  initial #1 $display("built");
endmodule

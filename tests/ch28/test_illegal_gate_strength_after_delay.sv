/*
:name: test_illegal_gate_strength_after_delay
:description: The drive strength specification of a gate follows the gate type keyword and precedes the delay, so a strength written after the delay is illegal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the drive strength of the nand gate g2 comes after its delay #2
:expected_stderr_regex: test_illegal_gate_strength_after_delay\.sv:24:
*/
// IEEE 1800-2023 §28.3.2: the strength specification shall follow the gate
// type keyword and precede any delay specification. g1 writes the strength
// and then the delay, which is legal; g2 writes the delay first.

`timescale 1ns/1ns

module test_illegal_gate_strength_after_delay;
  logic a = 1'b1, b = 1'b0;
  wire y1, y2;
  nand (strong0, pull1) #2 g1 (y1, a, b);
  nand #2 (strong0, pull1) g2 (y2, a, b);   // illegal: strength after the delay
  initial #3 $display("%v", y1);
endmodule

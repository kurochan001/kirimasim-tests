/*
:name: test_drive_strength_sets_resolution
:description: Each of the eight drive strength keywords supply0, strong0, pull0, weak0, supply1, strong1, pull1 and weak1 names a strength of its value, and a net with two drivers takes the value of the stronger strength in the order supply, strong, pull, weak (IEEE 1800-2023 Sections 28.3.2 and 28.12, A.2.2.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.2 28.12 A.2.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_drive_strength_sets_resolution.expected
*/
// IEEE 1800-2023 A.2.2.2: strength0 is supply0, strong0, pull0 or weak0;
// strength1 is supply1, strong1, pull1 or weak1; a charge strength is small,
// medium or large in parentheses. A drive strength is a pair (strength0,
// strength1), and §28.3.2 gives its meaning on a continuous assignment.
//
// Four nets have two drivers whose strengths differ by one step. r1 has a
// supply1 driver and a strong0 driver, r2 a strong1 and a pull0 driver, r3 a
// pull1 and a weak0 driver, and r4 a weak1 and a supply0 driver. §28.12
// resolves a net to the value of the stronger driver, so the four values are
// 1, 1, 1 and 0, printed as 1110. The eight keywords appear among these
// driver pairs; a tool that mapped a keyword to the wrong strength would
// print a different bit. The charge strength tokens apply only to a trireg
// net, which neither release implements, so they are not part of this
// stimulus.

`timescale 1ns/1ns

module test_drive_strength_sets_resolution;
  wire r1, r2, r3, r4;

  assign (supply1, supply0) r1 = 1'b1;
  assign (strong1, strong0) r1 = 1'b0;

  assign (strong1, strong0) r2 = 1'b1;
  assign (pull1, pull0) r2 = 1'b0;

  assign (pull1, pull0) r3 = 1'b1;
  assign (weak1, weak0) r3 = 1'b0;

  assign (weak1, weak0) r4 = 1'b1;
  assign (supply0, supply1) r4 = 1'b0;

  initial #1 $display("r=%b%b%b%b", r1, r2, r3, r4);
endmodule

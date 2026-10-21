/*
:name: test_illegal_nochange_edge_control
:description: The reference event of $nochange cannot use an edge-control specifier (IEEE 1800-2023 Section 31.4.6)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.4.6 31.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the reference event of $nochange uses an edge-control specifier
:expected_stderr_regex: test_illegal_nochange_edge_control\.sv:24:
*/
// IEEE 1800-2023 §31.4.6: the reference event of $nochange can be given with
// posedge or negedge, but edge-control specifiers (31.5) cannot be used.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design
// (docs/simulator-differences.md).

`timescale 1ns/1ns

module timing_nochange_edge_control(input clk, input d);
  reg n = 0;
  specify
    $nochange(edge [01] clk, d, 0, 0, n);   // illegal: edge-control specifier
  endspecify
endmodule

module test_illegal_nochange_edge_control;
  reg clk = 0, d = 0;
  timing_nochange_edge_control u(clk, d);
  initial #10 clk = 1;
endmodule

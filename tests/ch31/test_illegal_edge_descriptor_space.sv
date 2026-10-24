/*
:name: test_illegal_edge_descriptor_space
:description: An edge descriptor of an edge-control specifier cannot contain a space between its two characters (IEEE 1800-2023 Section 31.5)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the edge descriptor 0 1 contains an embedded space
:expected_stderr_regex: test_illegal_edge_descriptor_space\.sv:25:
*/
// IEEE 1800-2023 §31.5, Syntax 31-15 and its footnote: an edge descriptor
// such as 01 is written without embedded spaces, so edge[0 1] is not an
// edge-control specifier. The same check with edge[01] would be legal.
// Icarus Verilog 13.0 reports a syntax error on that line. Verilator 5.052
// stops there with an error of its lexer, which accepts edge[01].

`timescale 1ns/1ns

module timing_edge_space(input clk, input d);
  reg n = 0;
  specify
    $hold(edge[0 1] clk, d, 2, n);   // illegal: space inside the descriptor
  endspecify
endmodule

module test_illegal_edge_descriptor_space;
  reg clk = 0, d = 0;
  timing_edge_space u(clk, d);
  initial #10 clk = 1;
endmodule

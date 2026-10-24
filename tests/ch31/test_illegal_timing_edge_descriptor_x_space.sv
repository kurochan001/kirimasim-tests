/*
:name: test_illegal_timing_edge_descriptor_x_space
:description: An edge descriptor of a timing check event cannot contain an embedded space, here 1 x in an edge-control specifier of $period, while 01 and x1 written without spaces are legal (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the edge-control specifier of the $period check on clk2 has the edge descriptor 1 x with an embedded space
:expected_stderr_regex: test_illegal_timing_edge_descriptor_x_space\.sv:27:
*/
// IEEE 1800-2023 §31.2, Syntax 31-2 and its footnote 38: an edge descriptor
// is 01, 10, or a zero_or_one and a z_or_x character in either order, and
// embedded spaces are illegal. The $period check on clk1 uses
// edge [01, x1], which is legal; the check on clk2 writes the descriptor 1x
// with a space between its characters.
// The 5.052 release of Verilator stops on that line with an internal error
// of its lexer ("Missing verilog.l rule"), which does not count.

`timescale 1ns/1ns

module tes_cell(input wire clk1, input wire clk2);
  specify
    $period(edge [01, x1] clk1, 10);
    $period(edge [1 x] clk2, 10);   // illegal: space inside the edge descriptor
  endspecify
endmodule

module test_illegal_timing_edge_descriptor_x_space;
  logic clk1 = 1'b0, clk2 = 1'b0;
  tes_cell u (.clk1(clk1), .clk2(clk2));
  initial #1 $display("built");
endmodule

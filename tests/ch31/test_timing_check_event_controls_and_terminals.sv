/*
:name: test_timing_check_event_controls_and_terminals
:description: A timing check event is an optional event control, a specify terminal descriptor that may be an input or an output port, and an optional &&& condition; the controls are posedge, negedge, edge and the explicit edge[descriptor,...] list, whose descriptors may use X or x (IEEE 1800-2023 Sections 31.5 and 31.7, and A.7.5.3, A and A.10)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.5 31.7 A.7.5.3 A
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_check_event_controls_and_terminals.expected
*/
// IEEE 1800-2023 A (the introduction to the formal syntax): the syntax of a
// source file derives from source_text, a vertical bar separates
// alternatives, square brackets enclose optional items, braces enclose items
// repeated zero or more times, and a superscript refers to the clarification
// in A.10. A.7.5.3, Syntax 31-2: a timing_check_event is an optional
// timing_check_event_control, a specify_terminal_descriptor and an optional
// &&& timing_check_condition. The controls are the literal keywords posedge,
// negedge and edge, or an edge_control_specifier: the keyword edge followed by
// a bracketed, nonempty, comma-separated list of edge descriptors. A.10
// clarification 38 makes embedded spaces in an edge descriptor illegal, so a
// descriptor is written as one token. The keywords are literal (bold in the
// formal syntax), while the terminal descriptors are identifiers that name
// ports. §31.5: posedge stands for the transitions 0 to x, x to 1 and 0 to 1,
// negedge for 1 to x, x to 0 and 1 to 0, edge for any transition, and
// edge[01] for exactly 0 to 1. §31.7: the check is evaluated only when the
// condition after &&& is true.
//
// The cell te_any has $setup(d, clk, 3, n) without an event control, so every
// transition of clk is a reference event; its data changes 2 before a rise
// and 2 before a fall both violate. The cell te_pos takes only a rise, and
// te_neg uses $hold on a falling edge. The cell te_edge takes any edge. The
// cell te_list takes edge[01,10,X1,1X]: a rise, a fall and the transitions x
// to 1 and 1 to x are reference events, while 0 to x is not. The cell te_out
// gives the output port q as the data event of $setup and the input clk as
// its reference event. Each notifier starts at 0, and the test prints all of
// them at each change, which happens only at the same edge that the check
// takes.

`timescale 1ns/1ns

module te_any (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $setup(d, clk, 3, n);
  endspecify
endmodule

module te_pos (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $setup(d, posedge clk, 3, n);
  endspecify
endmodule

module te_neg (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $hold(negedge clk, d, 2, n);
  endspecify
endmodule

module te_edge (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $setup(d, edge clk, 3, n);
  endspecify
endmodule

module te_list (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $setup(d, edge[01,10,X1,1X] clk, 3, n);
  endspecify
endmodule

module te_out (input wire clk, input wire d, output wire q);
  assign q = d;
  reg n = 1'b0;
  specify
    $setup(q, posedge clk, 3, n);
  endspecify
endmodule

module test_timing_check_event_controls_and_terminals;
  reg c_any = 1'b0, d_any = 1'b0;
  reg c_pos = 1'b0, d_pos = 1'b0;
  reg c_neg = 1'b1, d_neg = 1'b0;
  reg c_edge = 1'b0, d_edge = 1'b0;
  reg c_list = 1'b0, d_list = 1'b0;
  reg c_out = 1'b0, d_out = 1'b0;
  wire q_out;

  te_any u_any (c_any, d_any);
  te_pos u_pos (c_pos, d_pos);
  te_neg u_neg (c_neg, d_neg);
  te_edge u_edge (c_edge, d_edge);
  te_list u_list (c_list, d_list);
  te_out u_out (c_out, d_out, q_out);

  always @(u_any.n or u_pos.n or u_neg.n or u_edge.n or u_list.n or u_out.n)
    if ($time > 0)
      $display("%0d: none=%b pos=%b neg=%b edge=%b list=%b out=%b",
               $time, u_any.n, u_pos.n, u_neg.n, u_edge.n, u_list.n, u_out.n);

  initial begin
    #8  d_any = 1'b1;
    #2  c_any = 1'b1;
    #8  d_any = 1'b0;
    #2  c_any = 1'b0;
  end

  initial begin
    #13 d_pos = 1'b1;
    #2  c_pos = 1'b1;
    #2  c_pos = 1'b0;
    #6  d_pos = 1'b0;
    #10 d_pos = 1'b1;
    #2  c_pos = 1'b1;
  end

  initial begin
    #22 c_neg = 1'b0;
    #1  d_neg = 1'b1;
    #7  c_neg = 1'b1;
    #12 c_neg = 1'b0;
    #1  d_neg = 1'b0;
  end

  initial begin
    #24 d_edge = 1'b1;
    #2  c_edge = 1'b1;
    #8  d_edge = 1'b0;
    #2  c_edge = 1'b0;
  end

  initial begin
    #28 d_list = 1'b1;
    #2  c_list = 1'b1;
    #8  d_list = 1'b0;
    #2  c_list = 1'b0;
    #8  d_list = 1'b1;
    #2  c_list = 1'bx;
    #8  d_list = 1'b0;
    #2  c_list = 1'b1;
    #8  d_list = 1'b1;
    #2  c_list = 1'bx;
  end

  initial begin
    #43 d_out = 1'b1;
    #2  c_out = 1'b1;
    #2  c_out = 1'b0;
    #6  d_out = 1'b0;
    #2  c_out = 1'b1;
  end
endmodule

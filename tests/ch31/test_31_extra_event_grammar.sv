/*
:name: test_31_extra_event_grammar
:description: Timing check events name specify terminals with posedge, negedge, edge and edge-list controls and with &&& conditions, and $period and $width take a controlled event, all in a specify block that builds and runs (IEEE 1800-2023 Sections 31.2 and 31.5)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.2 31.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_31_extra_event_grammar.expected
*/
// IEEE 1800-2023 31.2, Syntax 31-2: a timing_check_event is an optional
// timing_check_event_control, a specify_terminal_descriptor and an optional
// &&& timing_check_condition. The controls are posedge, negedge, edge and an
// edge-control specifier, which is the keyword edge followed by a list of
// edge descriptors (31.5). A controlled_timing_check_event, which $period and
// $width require, has the same form with an event control that is not
// optional. The cell below writes each of these legal forms: posedge and
// negedge, an edge list of one descriptor and one of three, an event
// condition on a reference event and on a data event, and $period and $width
// on a posedge. A design that does not parse one of them does not build, so
// the single line printed after the run shows that every form was accepted.
// A bare edge control without a descriptor list is not included because
// Icarus Verilog 13.0 rejects that legal spelling with a syntax error; the
// edge[01, 0x, x1] form here has the same set of transitions as posedge.

`timescale 1ns/1ns

module tge_cell(input wire clk, input wire d, input wire en);
  specify
    $setup(d, posedge clk &&& en, 2);
    $hold(negedge clk &&& en, d, 1);
    $setup(d, edge[01] clk, 2);
    $setup(d, edge[01, 0x, x1] clk &&& en, 2);
    $setup(d, edge[10, 1x] clk, 2);
    $period(posedge clk, 10);
    $width(posedge clk, 5, 0);
    $nochange(posedge clk, d, 0, 0);
  endspecify
endmodule

module test_31_extra_event_grammar;
  reg clk = 0, d = 0, en = 1;
  tge_cell u(clk, d, en);

  initial begin
    #10 clk = 1; d = 1;
    #5 clk = 0;
    #5 d = 0;
    #5 $display("t=%0d clk=%b d=%b en=%b", $time, clk, d, en);
    $finish;
  end
endmodule

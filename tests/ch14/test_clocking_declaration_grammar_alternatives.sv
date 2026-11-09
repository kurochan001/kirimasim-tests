/*
:name: test_clocking_declaration_grammar_alternatives
:description: a clocking declaration may be an unnamed default clocking block or a named block closed with its name, and its items may be a default skew for inputs only, an input with an expression, an input and output direction with two skews and an inout, each of which takes effect (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 14.5 14.12 14.16 A.6.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_declaration_grammar_alternatives.expected
*/
// IEEE 1800-2023 §14.3, A.6.11: a clocking declaration is [default] clocking
// [name] event ; items endclocking [ : name ]; only a default clocking block
// may be unnamed. An item is a default skew (input, output or both), or a
// direction with a list of signals, each optionally = an expression (14.5).
// A direction is input [skew], output [skew], input [skew] output [skew], or
// inout. test_clocking_declaration_items_and_skews covers a default skew with
// both directions, single directions with their own skews and global
// clocking; this test covers the other forms. §14.4: an input is sampled its
// skew before the event, and an output is driven its skew after it. §14.12:
// a cycle delay uses the unnamed default clocking block.
//
// The posedges are at 5, 15, 25. cb has the default input skew #2 and no
// default output skew, so the output skew of s is 0. a and b are set at 12
// and a changes again at 14; r and s also change at 12 and at 14. At the
// event at 15, sum = a + b was sampled at 13 (3), r with its own input skew
// #1 at 14 (7) and s at 13 (4). The drives at 15 change s at 15 and r at 18
// (output skew #3), and cb.s keeps its sample 4 after s is driven. A
// simulator that ignores a skew, or lets the drive of an inout change its
// input, prints other values; one that rejects a form does not compile the
// test.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns

module test_clocking_declaration_grammar_alternatives;
  logic clk = 0;
  logic [3:0] a = 0, b = 0;
  logic [3:0] r = 0, s = 0;

  always #5 clk = ~clk;

  default clocking @(posedge clk);
  endclocking

  clocking cb @(posedge clk);
    default input #2;
    input sum = a + b;
    input #1 output #3 r;
    inout s;
  endclocking : cb

  initial begin
    #12 a = 1; b = 2; r = 6; s = 4;
    #2 a = 5; r = 7; s = 8;
  end

  initial begin
    ##1;
    $display("t=%0t after ##1 of the unnamed default clocking", $time);
    #5 @(cb);
    $display("t=%0t cb.sum=%0d cb.r=%0d cb.s=%0d", $time, cb.sum, cb.r, cb.s);
    cb.r <= 4'd3;
    cb.s <= 4'd2;
    #1 $display("t=%0t r=%0d s=%0d", $time, r, s);
    #3 $display("t=%0t r=%0d s=%0d cb.s=%0d", $time, r, s, cb.s);
    $finish;
  end
endmodule

/*
:name: test_clocking_declaration_items_and_skews
:description: A named clocking block reads an input clockvar with the default input skew, drives an output clockvar with the default output skew of two time units, a second clocking block gives a per-item input skew and an output skew of three, and a module also declares a default clocking block and a global clocking block without items (IEEE 1800-2023 Sections 14.3, 14.4 and 14.11, A.6.11)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 14.11 14.12 A.6.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_declaration_items_and_skews.expected
*/
// IEEE 1800-2023 A.6.11: a clocking declaration is [default] clocking
// [name] clocking_event ; clocking_item endclocking [ : name ], and a
// global clocking declaration has the same header and end with no items. The
// items are a default skew declaration, a direction with a list of clocking
// declarations, and an attributed assertion item declaration. A default skew
// is input skew, output skew, or both; a direction may also give its own
// skews; a skew is an edge identifier with an optional delay or a delay.
//
// cb has the default input skew #1step and output skew #2; its input d is
// read at a clocking event and its output q is driven. cb2 gives its input
// the skew #2 and its output the skew #3. dcb is the default clocking block
// and gclk the global one, with no items. The test drives d one unit after
// time 3 and raises clk at time 5 and again at 25. At the second event cb.d
// is the value just before the edge, 1. A drive of cb.q and cb2.q2 at time
// 25 reaches q at 27 and q2 at 28, so both are 0 at time 26 and both are 1
// at time 30. A simulator that applies the skew to the wrong side of the
// event, or that ignores the per-item skew, prints a different pair.

`timescale 1ns/1ns

module wA_clk_cell(input logic clk);
  logic d = 1'b0;
  logic q = 1'b0;
  logic q2 = 1'b0;

  global clocking gclk @(posedge clk); endclocking
  default clocking dcb @(posedge clk); endclocking

  clocking cb @(posedge clk);
    default input #1step output #2;
    input d;
    output q;
  endclocking

  clocking cb2 @(posedge clk);
    input #2 d;
    output #3 q2;
  endclocking

  initial begin
    @(posedge clk);
    @(posedge clk);
    $display("sample cb.d=%b", cb.d);
    cb.q <= 1'b1;
    cb2.q2 <= 1'b1;
    #1 $display("t=%0t q=%b q2=%b", $time, q, q2);
    #4 $display("t=%0t q=%b q2=%b", $time, q, q2);
    $finish;
  end
endmodule

module test_clocking_declaration_items_and_skews;
  logic clk = 1'b0;
  wA_clk_cell u(clk);

  initial begin
    #4 u.d = 1'b1;
    #1 clk = 1'b1;
    #10 clk = 1'b0;
    #10 clk = 1'b1;
  end
endmodule

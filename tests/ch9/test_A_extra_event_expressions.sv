/*
:name: test_A_extra_event_expressions
:description: An event expression has an optional edge with an expression and an optional iff condition, a sequence instance with an iff condition, or and comma compositions and parentheses, and each form resumes its process at its own event (IEEE 1800-2023 Sections 9.4.2.4, 9.4.3 and 16.8, A.6.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 9.4.3 16.8 A.6.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_event_expressions.expected
*/
// IEEE 1800-2023 A.6.5, event_expression: an event expression is an optional
// edge_identifier, an expression and an optional "iff expression", a
// sequence_instance and an optional iff, two event expressions joined by or or
// by a comma, or a parenthesized event expression. §9.4.2.4 makes an event
// control on a sequence instance resume at the end of a match.
//
// Six processes wait on the six forms. oa and ca rise at 2 and 4, the clock
// rises at 5 while en is 1, pa rises at 6, sa and sb give the first sequence
// match at 25 and sc and sd the second at 45. Each process prints its own
// line at its own time, so the output has a fixed order.
//
// Icarus Verilog 13.0 has no sequence declaration, so the expected output is
// recorded with the 5.052 release of Verilator.

`timescale 1ns/1ns
module test_A_extra_event_expressions;
  logic clk = 0, en = 1;
  logic sa = 0, sb = 0, sc = 0, sd = 0;
  logic oa = 0, ob = 0, ca = 0, cb = 0, pa = 0;

  always #5 clk = ~clk;

  sequence sq1;
    @(posedge clk) sa ##1 sb;
  endsequence

  sequence sq2;
    @(posedge clk) sc ##1 sd;
  endsequence

  initial begin
    @(oa or ob);
    $display("or %0t", $time);
  end

  initial begin
    @(ca, cb);
    $display("comma %0t", $time);
  end

  initial begin
    @(pa);
    $display("paren %0t", $time);
  end

  initial begin
    @(posedge clk iff en);
    $display("edge_iff %0t", $time);
  end

  initial begin
    @(sq1);
    $display("seq %0t", $time);
  end

  initial begin
    @(sq2 iff en);
    $display("seq_iff %0t", $time);
  end

  initial begin
    #2 oa = 1;
    #2 ca = 1;
    #2 pa = 1;
    #1 sa = 1;
    #10 sb = 1;
    #10 sc = 1;
    #10 sd = 1;
  end

  initial #60 $finish;
endmodule

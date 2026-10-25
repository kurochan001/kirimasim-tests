/*
:name: test_syntax_timing_control_and_event_expressions
:description: Delay, event and repeated event controls of A.6.5 precede a statement, and the event expression forms with edges, iff, or, comma, parentheses and a package or hierarchical identifier each wake at their own event (IEEE 1800-2023 Sections 9.4.1 to 9.4.3, A.6.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4 9.4.1 9.4.2 9.4.3 A.6.5 A.6.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_timing_control_and_event_expressions.expected
*/
// IEEE 1800-2023 A.6.5: a procedural timing control statement is a delay
// control, an event control or a cycle delay before a statement or null
// statement. A delay control is "# delay_value" or "# ( mintypmax_expression
// )"; an event control is a clocking event, "@*" or "@(*)"; a clocking event
// is "@ ps_identifier", "@ hierarchical_identifier" or "@ ( event_expression
// )". An event expression may have an edge and an iff condition, may be two
// event expressions joined by "or" or by a comma, and may be parenthesized.
// §9.4.2: an event control blocks until its event, and repeat (n) before an
// event control waits for n events.
//
// Each form has its own signals so that one print at each time comes from one
// form: the events at 2, 3, 4, 5, 6, 10, 15 and 25 time units are the "or",
// comma, named event, edge clock, parenthesized, negative edge, iff and
// repeated controls; the package signal and the event in a named block print
// at 35 and 36; the two delay controls print at 41 (after "#1" and "#2") and
// 43 (after "# (2:2:2)"). The two star event controls have their own test.
//
// Icarus Verilog 13.0 does not support an iff condition or a package
// variable in an event control, so the expected output follows the standard;
// the 5.052 release of the other simulator produces it.

`timescale 1ns/1ns

package ev_pkg;
  logic p = 0;
endpackage

module test_syntax_timing_control_and_event_expressions;
  import ev_pkg::*;

  logic clk = 1'b0;
  logic e_a = 1'b0, e_b = 1'b0, e_c = 1'b0, e_d = 1'b0;
  logic e_x = 1'b0, e_y = 1'b0;
  logic en = 1'b0;
  event named;

  always #5 clk = ~clk;

  initial begin : holder
    event he;
    #36 -> he;
  end

  initial #2 e_a = 1;
  initial #3 e_c = 1;
  initial #4 -> named;
  initial #6 e_x = 1;
  initial #7 en = 1;
  initial #35 ev_pkg::p = 1;

  initial begin
    @(e_a or e_b);
    $display("%0t: or", $time);
  end

  initial begin
    @(e_c, e_d);
    $display("%0t: comma", $time);
  end

  initial begin
    @(named);
    $display("%0t: named event", $time);
  end

  initial begin
    @(edge clk);
    $display("%0t: edge clock", $time);
  end

  initial begin
    @((e_x) or e_y);
    $display("%0t: parenthesized", $time);
  end

  initial begin
    @(negedge clk);
    $display("%0t: negedge", $time);
  end

  initial begin
    @(posedge clk iff en);
    $display("%0t: iff", $time);
  end

  initial begin
    repeat (3) @(posedge clk);
    $display("%0t: repeat", $time);
  end

  initial begin
    @holder.he;
    $display("%0t: hierarchical event", $time);
  end

  initial begin
    @ev_pkg::p;
    $display("%0t: package signal", $time);
  end

  initial begin
    #40;
    #1 $display("%0t: delay", $time);
    #(2:2:2) $display("%0t: mintypmax delay", $time);
    #1 $finish;
  end
endmodule

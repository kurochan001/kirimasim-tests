/*
:name: test_syntax_clocking_drive_forms
:description: A clocking drive assigns to a clockvar with no cycle delay or with ## followed by an integer, an identifier or a parenthesized expression, and each drive matures that many clocking events later (IEEE 1800-2023 Sections 14.16 and A.6.11, A.6.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.16.1 A.6.4 A.6.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_clocking_drive_forms.expected
*/
// IEEE 1800-2023 A.6.11: a clocking drive is "clockvar_expression <= [
// cycle_delay ] expression", and a cycle delay is "## integral_number", "##
// identifier" or "## ( expression )". A.6.4 lists "clocking_drive ;" as a
// statement item. §14.16: a drive without a cycle delay applies at the
// current clocking event, and a drive with a cycle delay of n applies n
// clocking events after it.
//
// The clocking event is every 40 units, so the rising edges are at 20, 60,
// 100, 140 and so on. At the edge at 20, ##1 sets d to 2 at 60, ##(2) sets 3
// at 100, ##N with N = 3 sets 4 at 140 and ##(N+1) sets 5 at 180. Ten more
// clocking events after the first one reach 420, where a drive without a
// cycle delay sets 1. Each value is printed one unit after its edge, and d is
// still 0 at 21.

`timescale 1ns/1ns

module test_syntax_clocking_drive_forms;
  logic clk = 1'b0;
  logic d = 1'b0;
  localparam int N = 3;

  always #20 clk = ~clk;

  default clocking cb @(posedge clk);
    output d;
  endclocking

  initial begin
    @(cb);
    cb.d <= ##1 2;
    cb.d <= ##(2) 3;
    cb.d <= ##N 4;
    cb.d <= ##(N + 1) 5;
    repeat (10) @(cb);
    cb.d <= 1'b1;
  end

  initial begin
    #21 $display("%0t d=%0d", $time, d);
    #40 $display("%0t d=%0d", $time, d);
    #40 $display("%0t d=%0d", $time, d);
    #40 $display("%0t d=%0d", $time, d);
    #40 $display("%0t d=%0d", $time, d);
    #240 $display("%0t d=%0d", $time, d);
    $finish;
  end
endmodule

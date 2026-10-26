/*
:name: test_checker_triggered_assignment
:description: The right-hand side of a checker variable assignment may contain the sequence method triggered, and an always_ff procedure of the checker counts the end points of the sequence (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.1 16.13.6 17.7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_triggered_assignment.expected
*/
// IEEE 1800-2023 §17.7.1: the right-hand side of a checker variable
// assignment may contain the sequence method triggered. §17.7.3: checker
// procedures run in the Reactive region and their nonblocking assignments in
// the Re-NBA region, so an always_ff on the clock edge at which a sequence
// ends reads the triggered value that the Observed region set in the same
// time step. The sequence s is a ##1 b at the rising clock. a is 1 at the
// clock at 5 and b is 1 at the clock at 15, which ends the first match; a is
// 1 at the clock at 25 and b is still 1 at the clock at 35, which ends the
// second. The checker adds s.triggered to its count at every rising clock and
// drives the count out, so the design prints 2 end points. Icarus Verilog
// 13.0 has no checkers and Verilator 5.052 does not resolve sequence.triggered
// in a checker, so the expected output follows the clauses alone.

`timescale 1ns/1ns

checker cb_triggered (logic clk, logic a, logic b, output int ends);
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  int n = 0;

  always_ff @(posedge clk) n <= n + s.triggered;
  assign ends = n;
endchecker : cb_triggered

module test_checker_triggered_assignment;
  logic clk = 1'b0;
  logic a = 1'b0;
  logic b = 1'b0;
  int ends;

  cb_triggered u_cb (clk, a, b, ends);

  always #5 clk = ~clk;

  initial begin
    #1 a = 1'b1;
    #11 b = 1'b1; a = 1'b0;     // 12
    #8 a = 1'b1;                // 20
    #8 a = 1'b0;                // 28
    #13 $display("end points: %0d", ends);
    $finish;
  end
endmodule

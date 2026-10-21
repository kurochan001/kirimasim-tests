/*
:name: test_vpi_assertion_procedural_callbacks
:description: A concurrent assertion in an always procedure starts an attempt only when the procedure reaches it, and its callbacks report those starts and their nonvacuous success or failure (IEEE 1800-2023 Sections 16.14.6 and 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 16.14.6 39.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_procedural_callbacks.c
:expected_stdout: @test_vpi_assertion_procedural_callbacks.expected
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion in an always procedure is
// queued when the procedure reaches the statement, and its attempt starts in
// the Observed region of that time step; when the procedure does not reach it,
// no attempt starts. §39.4.2: cbAssertionStart reports the start of every
// attempt, and cbAssertionSuccess and cbAssertionFailure the nonvacuous end of
// it. The procedure runs at every rising edge (5, 15, ...) but reaches the
// assertion only while en is 1: attempts start at 5, 15, 45, 55 and 65. The
// attempt started at 15 succeeds at 25, after en has fallen. The attempt
// started at 45, where a is 0, fails in the same time step; the attempt
// started at 55 fails at 65. The callbacks of one time step can come in any
// order, so the application sorts them by the callback time and the attempt
// start time before it prints them.

`timescale 1ns/1ns

module test_vpi_assertion_procedural_callbacks;
  logic clk = 0, en = 0, a = 0, b = 0;
  int passes = 0, fails = 0;

  always #5 clk = ~clk;

  always @(posedge clk)
    if (en) begin
      a1: assert property (a ##1 b) passes++; else fails++;
    end

  initial begin
    $vt_watch;
    #1 en = 1; a = 1; b = 0;
    #10 b = 1;              // 11
    #5 en = 0;              // 16
    #20 en = 1; a = 0;      // 36
    #10 a = 1;              // 46
    #10 b = 0;              // 56
    #14 $vt_report;         // 70
    $display("pass actions: %0d, fail actions: %0d", passes, fails);
    $finish;
  end
endmodule

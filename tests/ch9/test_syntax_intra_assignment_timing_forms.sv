/*
:name: test_syntax_intra_assignment_timing_forms
:description: blocking assignments with an intra-assignment #delay, #(expression), event control, repeat event control and named-event control, and nonblocking assignments without and with each kind of control (IEEE 1800-2023 Section 9.4.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.5 10.4.1 10.4.2 A.6.2 A.6.4 A.6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_intra_assignment_timing_forms.expected
*/
// IEEE 1800-2023 A.6.2: a blocking assignment can be variable = delay or
// event control, then the expression; a nonblocking assignment is variable
// <= an optional delay or event control, then the expression. A.6.5: the
// control is # value, #(expression), @ name, @(event expression) or
// repeat (count) followed by an event control. §9.4.5: the right-hand side
// is evaluated when the statement is reached and assigned after the control;
// a blocking assignment waits there, a nonblocking one does not (10.4.2).
//
// The process "chg" changes a between the evaluation and the assignment of
// each blocking form, so every target gets the old value of a at the time
// shown. The nonblocking forms are reached at t=41, before a = 7 in the same
// process, and their targets change at t=41, 45, 50 (next posedge) and 60
// (second posedge). The clock rises at 10, 20, ..., 60.

`timescale 1ns/1ns

module test_syntax_intra_assignment_timing_forms;
  logic clk;
  int a, b, c, d, e, f;
  int n1, n2, n3, n4;
  event ev;

  initial begin
    clk = 0;
    #10;
    repeat (6) begin
      clk = 1;
      #5 clk = 0;
      #5;
    end
  end

  initial begin : chg
    #1 a = 2;
    #3 a = 3;      // t=4
    #3 a = 4;      // t=7
    #8 a = 5;      // t=15
    #20 a = 6;     // t=35
    -> ev;
  end

  initial begin
    a = 1;
    b = #3 a;
    $display("t=%0t b=%0d", $time, b);
    c = #(1 + 1) a;
    $display("t=%0t c=%0d", $time, c);
    d = @(posedge clk) a;
    $display("t=%0t d=%0d", $time, d);
    e = repeat (2) @(posedge clk) a;
    $display("t=%0t e=%0d", $time, e);
    f = @ev a;
    $display("t=%0t f=%0d", $time, f);
  end

  initial begin
    #41;
    n1 <= a;
    n2 <= #4 a;
    n3 <= @(posedge clk) a;
    n4 <= repeat (2) @(posedge clk) a;
    a = 7;
    $display("t=%0t n=%0d %0d %0d %0d", $time, n1, n2, n3, n4);
    #1 $display("t=%0t n=%0d %0d %0d %0d", $time, n1, n2, n3, n4);
    #4 $display("t=%0t n=%0d %0d %0d %0d", $time, n1, n2, n3, n4);
    #5 $display("t=%0t n=%0d %0d %0d %0d", $time, n1, n2, n3, n4);
    #10 $display("t=%0t n=%0d %0d %0d %0d", $time, n1, n2, n3, n4);
  end
endmodule

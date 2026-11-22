/*
:name: test_sequence_method_call_and_match_item_forms
:description: a sequence match item may be an operator assignment, an increment or a subroutine call on a local variable, and s.triggered calls a method of a sequence instance (IEEE 1800-2023 Section A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10 16.11 16.13.6 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_method_call_and_match_item_forms.expected
*/
// IEEE 1800-2023 §A.2.10: a sequence method call is a sequence instance
// followed by a dot and a method name, and a sequence match item is an
// operator assignment, an increment or decrement expression, or a subroutine
// call. §16.10: a local variable of a sequence is assigned by the match items
// that follow an expression, in order, when that expression matches. §16.11:
// a subroutine call in a match item is made when the expression matches, with
// the values of the local variables at that point. §16.13.6: triggered of a
// sequence instance is true in the time step in which the sequence reaches
// its end point, and wait can use it.
//
// The posedges of clk are at 5, 15, 25 and 35. a is 1 at the posedge at 15
// only and b at the posedge at 25 only. The sequence s_items assigns 1 to its
// local variable v, increments it with v++, adds 2 with v += 2 and calls
// report(v) when a matches, so report gets 4, the order 1, 2, 4 of the three
// items; it then reaches its end point at 25, when b holds. wait
// (s_items.triggered) is released at 25. The values are printed at 40.
// Icarus Verilog 13.0 does not support sequence declarations, and Verilator
// 5.054 does not support the local variable of a sequence.

`timescale 1ns/1ns

module test_sequence_method_call_and_match_item_forms;
  logic clk = 1'b0, a = 1'b0, b = 1'b0;
  int seen_v = -1, calls = 0, trig_at = -1;

  always #5 clk = ~clk;

  function automatic void report(int x);
    seen_v = x;
    calls++;
  endfunction

  sequence s_items;
    int v;
    @(posedge clk) (a, v = 1, v++, v += 2, report(v)) ##1 b;
  endsequence

  initial begin
    #12 a = 1'b1;
    #10 a = 1'b0;
    b = 1'b1;
    #10 b = 1'b0;
  end

  initial begin
    wait (s_items.triggered);
    trig_at = $time;
  end

  initial begin
    #40;
    $display("report(v) got %0d in %0d call, s_items.triggered at %0d", seen_v, calls, trig_at);
    $finish;
  end
endmodule

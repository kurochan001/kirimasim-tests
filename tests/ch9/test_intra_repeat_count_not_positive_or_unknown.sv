/*
:name: test_intra_repeat_count_not_positive_or_unknown
:description: an intra-assignment repeat event control whose count is zero, negative, x or z assigns at once without waiting for any event, while positive counts wait that many events (IEEE 1800-2023 Section 9.4.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_intra_repeat_count_not_positive_or_unknown.expected
*/
// IEEE 1800-2023 §9.4.5: the count of a repeat event control is evaluated
// once, when the assignment is reached. If it is less than or equal to zero,
// unknown or high impedance then, the assignment happens as if there were no
// repeat construct, so no event is waited for. A positive count waits for
// that many occurrences of the event. Whether a value is negative depends on
// the signedness of the count expression: the 2-bit unsigned value 2'b11 is
// 3, the 2-bit signed one is -1.
//
// clk has a posedge at times 5, 15, 25 and so on. Each blocking assignment
// below is reached at time 2 (or right after the previous one finished) and
// prints the time at which it completed and the value it assigned. A
// watchdog ends a run that waits too long, so that a simulator that keeps
// waiting for an x or z count stops instead of running the clock forever.
//
// Icarus Verilog 13.0 waits for posedges at the assignment whose count is x
// (and at the one whose count is z) and is still waiting when the watchdog
// ends the run, which the standard does not allow; it handles the other
// counts as described.

`timescale 1ns/1ns
module test_intra_repeat_count_not_positive_or_unknown;
  logic clk = 0;
  int a, b = 0;
  int zero = 0, neg = -2, two = 2;
  logic [3:0] cx = 4'bxxxx, cz = 4'bzzzz;
  logic [1:0] u3 = 2'b11;
  logic signed [1:0] sm1 = 2'b11;

  always #5 clk = ~clk;
  initial #1000 $finish;

  initial begin
    #2;
    b = 10; a = repeat (zero) @(posedge clk) b;
    $display("count 0:     t=%0t a=%0d", $time, a);
    b = 11; a = repeat (neg) @(posedge clk) b;
    $display("count -2:    t=%0t a=%0d", $time, a);
    b = 12; a = repeat (cx) @(posedge clk) b;
    $display("count x:     t=%0t a=%0d", $time, a);
    b = 13; a = repeat (cz) @(posedge clk) b;
    $display("count z:     t=%0t a=%0d", $time, a);
    b = 14; a = repeat (sm1) @(posedge clk) b;
    $display("signed -1:   t=%0t a=%0d", $time, a);
    b = 15; a = repeat (two) @(posedge clk) b;
    $display("count 2:     t=%0t a=%0d", $time, a);
    b = 16; a = repeat (u3) @(posedge clk) b;
    $display("unsigned 3:  t=%0t a=%0d", $time, a);
    $finish;
  end
endmodule

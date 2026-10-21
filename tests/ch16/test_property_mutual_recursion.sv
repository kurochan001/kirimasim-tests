/*
:name: test_property_mutual_recursion
:description: two properties that instantiate each other after a clock tick, counting down through a local input formal argument, check that x alternates for a given number of ticks, and a recursive property under accept_on stops requiring its operand once the abort condition becomes true (IEEE 1800-2023 Sections 16.12.17, 16.12.19)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.17 16.12.19 16.8.2 16.12.14 16.12.6 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_mutual_recursion.expected
*/
// IEEE 1800-2023 §16.12.17: properties may be mutually recursive, each
// instance coming after a positive advance in time (1'b1 |=>). ph_high(n)
// needs x now and ph_low(n - 1) at the next tick, ph_low(n) needs !x and
// then ph_high(n - 1); if (n > 0) makes the property true when n reaches 0
// (§16.12.6). The actual n - 1 uses the formal n, which restriction 4 allows
// because it is bound to a local variable formal argument; §16.12.19 makes
// such a formal of a property an input (§16.8.2). So ph_high(4) needs x
// high, low, high, low at four ticks. §16.12.17 also allows abort operators
// in a recursive property: hold(p, b) needs p at every tick until b, an
// asynchronous abort (§16.12.14), becomes true. Both assertions start at the
// tick T with go (§16.12.7); the fail actions count the failures of each
// phase (§16.14.1). Each line shows x and busy at T to T+3 and when stop is
// high, between two ticks. In the first phase busy is low at T+3, after
// stop; in the second it is low at T+2, before stop.

`timescale 1ns/1ns

module test_property_mutual_recursion;
  logic clk = 0, go = 0, x = 0, busy = 0, stop = 0;
  int f_alt = 0, f_hold = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property ph_high(local input int n);
    if (n > 0) (x and (1'b1 |=> ph_low(n - 1)));
  endproperty

  property ph_low(local input int n);
    if (n > 0) (!x and (1'b1 |=> ph_high(n - 1)));
  endproperty

  property hold(p, b);
    accept_on (b) (p and (1'b1 |=> hold(p, b)));
  endproperty

  a_alt: assert property (@(posedge clk) go |-> ph_high(4)) else f_alt++;
  a_hold: assert property (@(posedge clk) go |-> hold(busy, stop)) else f_hold++;

  // Runs one phase of six ticks, T at 5 after its start, changing the inputs
  // at every time unit; stop is high at the two time units from t_stop.
  task automatic phase(logic [3:0] xs, logic [3:0] bs, int t_stop, string when);
    for (int s = 0; s < 60; s++) begin
      go = s < 10;
      x = s < 40 ? xs[3 - s / 10] : 1'b0;
      busy = s < 40 ? bs[3 - s / 10] : 1'b0;
      stop = s == t_stop || s == t_stop + 1;
      #1;
    end
    $display("x %b, busy %b, stop %s: a_alt %0d, a_hold %0d", xs, bs, when, f_alt, f_hold);
    f_alt = 0;
    f_hold = 0;
  endtask

  initial begin
    phase(4'b1010, 4'b1110, 28, "between T+2 and T+3");
    phase(4'b1000, 4'b1100, 28, "between T+2 and T+3");
    phase(4'b1011, 4'b1000, 8, "between T and T+1");
    $finish;
  end
endmodule

/*
:name: test_property_until
:description: a until b needs a at every clock tick from the start up to, but not including, the tick where b holds, and a until_with b up to and including it; with b at the starting tick, until needs no a at all (IEEE 1800-2023 Section 16.12.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.12 16.12.7 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_until.expected
*/
// IEEE 1800-2023 §16.12.12: the non-overlapping until is true if a holds at
// every tick from the starting tick until at least one tick before a tick
// where b holds; the overlapping until_with also needs a at that tick. If b
// holds at the starting tick, until is true whatever a is. Both assertions
// check start |-> (...), so each phase starts an evaluation at its first tick
// (16.12.7), and the fail actions count the failures (16.14.1). b always comes
// within the phase, so weak and strong forms would agree; only the weak ones
// are used. In the first phase a holds at ticks 1 and 2 and b comes at tick 3
// without a; in the second a drops at tick 2 before b comes at tick 3; in the
// third b and start come together at tick 1, without a.

`timescale 1ns/1ns

module test_property_until;
  logic clk = 0, start = 0, a = 0, b = 0;
  int f_until = 0, f_with = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_until: assert property (@(posedge clk) start |-> (a until b)) else f_until++;
  a_with: assert property (@(posedge clk) start |-> (a until_with b)) else f_with++;

  // Sets the values sampled at the next tick.
  task automatic tick(logic vs, logic va, logic vb);
    start = vs;
    a = va;
    b = vb;
    #10;
  endtask

  task automatic report(string phase);
    $display("%s: until %0d, until_with %0d", phase, f_until, f_with);
    f_until = 0;
    f_with = 0;
  endtask

  initial begin
    tick(1, 1, 0); tick(0, 1, 0); tick(0, 0, 1); tick(0, 0, 0);
    report("a, a, then b without a");
    tick(1, 1, 0); tick(0, 0, 0); tick(0, 0, 1); tick(0, 0, 0);
    report("a drops before b");
    tick(1, 0, 1); tick(0, 0, 0);
    report("b at the starting tick");
    $finish;
  end
endmodule

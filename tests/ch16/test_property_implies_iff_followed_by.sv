/*
:name: test_property_implies_iff_followed_by
:description: p1 implies p2 and p1 iff p2 evaluate both properties from the same tick, and the followed-by operators #-# and #=# need a match of their sequence, unlike the implications they are duals of (IEEE 1800-2023 Sections 16.12.8, 16.12.9)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.8 16.12.9 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_implies_iff_followed_by.expected
*/
// IEEE 1800-2023 §16.12.8: p1 implies p2 is true if p1 is false or p2 is true,
// and p1 iff p2 if both are true or both false; both properties start at the
// same tick. §16.12.9: s #-# p is true if s has a match and p holds from its
// end tick, and s #=# p if p holds from the tick after; with no match of s
// they are false, where s |-> p would be true. The followed-by assertions are
// guarded by go |-> (§16.12.7), and the fail actions count the failures of
// each phase (§16.14.1). go is high at the first tick T of each phase. In
// the first phase p is high at T+1 and q at T+2; in the second p and q are
// high at T+1; in the third neither is high.

`timescale 1ns/1ns

module test_property_implies_iff_followed_by;
  logic clk = 0, go = 0, p = 0, q = 0;
  int f_implies = 0, f_iff = 0, f_ov = 0, f_nov = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_implies: assert property (@(posedge clk) (go ##1 p) implies (go ##2 q)) else f_implies++;
  a_iff: assert property (@(posedge clk) (go ##1 p) iff (go ##1 q)) else f_iff++;
  a_ov: assert property (@(posedge clk) go |-> (##1 p #-# q)) else f_ov++;
  a_nov: assert property (@(posedge clk) go |-> (##1 p #=# q)) else f_nov++;

  // Runs one phase: go at T, then p and q at T+1 and T+2.
  task automatic phase(string name, logic p1, logic q1, logic p2, logic q2);
    go = 1; p = 0; q = 0; #10;
    go = 0; p = p1; q = q1; #10;
    p = p2; q = q2; #10;
    p = 0; q = 0; #20;
    $display("%s: implies %0d, iff %0d, #-# %0d, #=# %0d", name, f_implies, f_iff, f_ov, f_nov);
    f_implies = 0;
    f_iff = 0;
    f_ov = 0;
    f_nov = 0;
  endtask

  initial begin
    phase("p at T+1, q at T+2", 1, 0, 0, 1);
    phase("p and q at T+1", 1, 1, 0, 0);
    phase("neither", 0, 0, 0, 0);
    $finish;
  end
endmodule

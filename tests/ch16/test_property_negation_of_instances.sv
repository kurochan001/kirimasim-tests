/*
:name: test_property_negation_of_instances
:description: not of an implication is false whenever the implication holds vacuously, and not distributes over or and and by De Morgan's laws, with named property instances as the operands (IEEE 1800-2023 Sections 16.12.3, 16.12.4, 16.12.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.3 16.12.4 16.12.5 16.12.1 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_negation_of_instances.expected
*/
// IEEE 1800-2023 §16.12.3: not p is true exactly when p is false. go |-> ##1 r
// is true when go is false (§16.12.7), so not (go |-> ##1 r) fails at every
// tick without go, and passes only where go is followed by no r.
// §16.12.4, §16.12.5: p1 or p2 is true when either is, p1 and p2 when both
// are; so not (s1 or s2) and (not s1) and (not s2) fail at the same ticks.
// §16.12.1: an instance of a named property can be an operand of these
// operators, as p_resp and p_seq are here. All assertions start at every
// tick. Each phase has three ticks: go at the first, r and s as listed at
// the second, nothing at the third. The action blocks count per phase
// (§16.14.1): passes and failures of a_not_imp, failures of the others.

`timescale 1ns/1ns

module test_property_negation_of_instances;
  logic clk = 0, go = 0, r = 0, s = 0;
  int f_not_imp = 0, p_not_imp = 0, f_or = 0, f_not_or = 0, f_and_not = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property p_resp(x, y);
    x |-> ##1 y;
  endproperty

  property p_seq(x, y);
    x ##1 y;
  endproperty

  a_not_imp: assert property (@(posedge clk) not p_resp(go, r)) p_not_imp++;
    else f_not_imp++;
  a_or: assert property (@(posedge clk) p_resp(go, r) or p_resp(go, s)) else f_or++;
  a_not_or: assert property (@(posedge clk) not (p_seq(go, r) or p_seq(go, s))) else f_not_or++;
  a_and_not: assert property (@(posedge clk) (not p_seq(go, r)) and (not p_seq(go, s)))
    else f_and_not++;

  // Runs one phase: go at T, r and s at T+1, nothing at T+2.
  task automatic phase(logic vr, logic vs);
    go = 1; r = 0; s = 0; #10;
    go = 0; r = vr; s = vs; #10;
    r = 0; s = 0; #10;
    $display("r %0d, s %0d: a_not_imp %0d fail %0d pass, a_or %0d, a_not_or %0d, a_and_not %0d",
             vr, vs, f_not_imp, p_not_imp, f_or, f_not_or, f_and_not);
    f_not_imp = 0;
    p_not_imp = 0;
    f_or = 0;
    f_not_or = 0;
    f_and_not = 0;
  endtask

  initial begin
    phase(1, 0);
    phase(0, 1);
    phase(0, 0);
    phase(1, 1);
    $finish;
  end
endmodule

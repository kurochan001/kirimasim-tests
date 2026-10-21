/*
:name: test_nonvacuous_evaluation_forms
:description: with the pass actions of vacuous successes turned off, the pass action runs only where the success is nonvacuous by the recursive rules for implication, not, or, and, if-else, implies, iff and nexttime, while fail actions still run (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.3 16.12.4 16.12.5 16.12.6 16.12.8 16.12.10 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_evaluation_forms.expected
*/
// IEEE 1800-2023 §16.14.8: an evaluation of a sequence is nonvacuous, s |-> p
// is when s matches and p from its end is, not p, p1 or p2 and p1 and p2
// when an operand is, if (b) p1 else p2 when the branch b selects is,
// p1 implies p2 when p1 is true and nonvacuous and p2 is nonvacuous, p1 iff
// p2 when an operand is, and nexttime p when p at the next tick is. A
// nonvacuous evaluation may be false, as go |-> x with go and no x is.
// §20.11: after $assertvacuousoff the pass action runs only for nonvacuous
// successes; fail actions are not affected. All assertions start at every
// tick (5 to 55); the action blocks record the times (§16.14.1). The inputs
// at the six ticks are listed in the code. For example, at 45 go |-> x fails
// nonvacuously, so the or with the vacuous go2 |-> y passes nonvacuously and
// not (go |-> x) passes; at 15 implies passes vacuously, as go2 |-> y holds
// only vacuously.

`timescale 1ns/1ns

module test_nonvacuous_evaluation_forms;
  logic clk = 0, go = 0, go2 = 0, x = 0, y = 0, sel = 0, nx = 0;
  int p_imp[$], f_imp[$], p_not[$], f_not[$], p_or[$], f_or[$], p_and[$], f_and[$];
  int p_if[$], f_if[$], p_implies[$], f_implies[$], p_iff[$], f_iff[$], p_next[$], f_next[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_imp: assert property (@(posedge clk) go |-> x) p_imp.push_back($time);
    else f_imp.push_back($time);
  a_not: assert property (@(posedge clk) not (go |-> x)) p_not.push_back($time);
    else f_not.push_back($time);
  a_or: assert property (@(posedge clk) (go |-> x) or (go2 |-> y)) p_or.push_back($time);
    else f_or.push_back($time);
  a_and: assert property (@(posedge clk) (go |-> x) and (go2 |-> y)) p_and.push_back($time);
    else f_and.push_back($time);
  a_if: assert property (@(posedge clk) if (sel) (go |-> x) else x) p_if.push_back($time);
    else f_if.push_back($time);
  a_implies: assert property (@(posedge clk) (go |-> x) implies (go2 |-> y))
    p_implies.push_back($time);
    else f_implies.push_back($time);
  a_iff: assert property (@(posedge clk) (go |-> x) iff (go2 |-> y)) p_iff.push_back($time);
    else f_iff.push_back($time);
  a_next: assert property (@(posedge clk) nx |-> nexttime (go |-> x)) p_next.push_back($time);
    else f_next.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic vgo, logic vgo2, logic vx, logic vy, logic vsel, logic vnx);
    go = vgo;
    go2 = vgo2;
    x = vx;
    y = vy;
    sel = vsel;
    nx = vnx;
    #10;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  function automatic void show(string name, int pq[$], int fq[$]);
    $display("%s: passes%s; failures%s", name, times(pq), times(fq));
  endfunction

  initial begin
    $assertvacuousoff;
    //   go go2 x  y  sel nx
    tick(0, 0, 1, 1, 0, 1);   // 5
    tick(1, 0, 1, 0, 1, 1);   // 15
    tick(0, 1, 0, 1, 1, 1);   // 25
    tick(1, 1, 1, 1, 0, 0);   // 35
    tick(1, 0, 0, 0, 0, 0);   // 45
    tick(0, 0, 0, 0, 1, 0);   // 55
    show("go |-> x", p_imp, f_imp);
    show("not (go |-> x)", p_not, f_not);
    show("(go |-> x) or (go2 |-> y)", p_or, f_or);
    show("(go |-> x) and (go2 |-> y)", p_and, f_and);
    show("if (sel) (go |-> x) else x", p_if, f_if);
    show("(go |-> x) implies (go2 |-> y)", p_implies, f_implies);
    show("(go |-> x) iff (go2 |-> y)", p_iff, f_iff);
    show("nx |-> nexttime (go |-> x)", p_next, f_next);
    $finish;
  end
endmodule

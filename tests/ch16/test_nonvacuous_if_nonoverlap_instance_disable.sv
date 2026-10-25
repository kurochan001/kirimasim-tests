/*
:name: test_nonvacuous_if_nonoverlap_instance_disable
:description: with the pass actions of vacuous successes turned off, if (c) p without else, s |=> p, property instances (also with a property actual) and disable iff (r) p run the pass action only for the nonvacuous successes that the rules of 16.14.8 define (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.6 16.12.7 16.12 16.12.18 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_if_nonoverlap_instance_disable.expected
*/
// IEEE 1800-2023 §16.14.8: rule g) makes if (c) p (no else) nonvacuous
// exactly when c is true and p is nonvacuous; rule h) makes s |=> p
// nonvacuous exactly when s has a match and p, started at the tick after it,
// is nonvacuous; rule i) makes a property instance nonvacuous exactly when
// its body with the actual arguments substituted is; rule ag) makes
// disable iff (r) p nonvacuous exactly when p is and r does not hold during
// the attempt. A disabled attempt neither passes nor fails (§16.12), and if
// (c) p is true when c is false (§16.12.6). §20.11: after $assertvacuousoff
// only nonvacuous successes run the pass action; failures still run the fail
// action. Every assertion starts at each tick (5 to 85); the action blocks
// (§16.14.1) record the times. p_imp(go, x) is go |-> x, and
// p_gate_q(go, g2 |-> x) is go |-> (g2 |-> x), whose property actual
// (§16.12.18) decides its vacuity. For example, at 5 if (sel) (go |-> x)
// passes vacuously although go |-> x would fail, and go |=> (g2 |-> x)
// started at 35 passes nonvacuously at 45, but the ones started at 45 and 55
// pass vacuously, as g2 is low one tick later. r is high at 45 and 55, where
// the disable iff assertion is disabled.

`timescale 1ns/1ns

module test_nonvacuous_if_nonoverlap_instance_disable;
  logic clk = 0, sel = 0, go = 0, x = 0, g2 = 0, r = 0;
  int p_if[$], f_if[$], p_nov[$], f_nov[$], p_inst[$], f_inst[$];
  int p_gate[$], f_gate[$], p_dis[$], f_dis[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property p_imp(a, b);
    a |-> b;
  endproperty

  property p_gate_q(a, property q);
    a |-> q;
  endproperty

  a_if: assert property (@(posedge clk) if (sel) (go |-> x)) p_if.push_back($time);
    else f_if.push_back($time);
  a_nov: assert property (@(posedge clk) go |=> (g2 |-> x)) p_nov.push_back($time);
    else f_nov.push_back($time);
  a_inst: assert property (@(posedge clk) p_imp(go, x)) p_inst.push_back($time);
    else f_inst.push_back($time);
  a_gate: assert property (@(posedge clk) p_gate_q(go, g2 |-> x)) p_gate.push_back($time);
    else f_gate.push_back($time);
  a_dis: assert property (@(posedge clk) disable iff (r) go |-> x) p_dis.push_back($time);
    else f_dis.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic vsel, logic vgo, logic vx, logic vg2, logic vr);
    sel = vsel;
    go = vgo;
    x = vx;
    g2 = vg2;
    r = vr;
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
    //   sel go x  g2 r
    tick(0, 1, 0, 0, 0);   // 5
    tick(1, 0, 1, 1, 0);   // 15
    tick(1, 1, 1, 0, 0);   // 25
    tick(1, 1, 0, 1, 0);   // 35
    tick(0, 1, 1, 1, 1);   // 45
    tick(1, 1, 1, 0, 1);   // 55
    tick(0, 0, 0, 0, 0);   // 65
    tick(1, 1, 1, 1, 0);   // 75
    tick(0, 0, 0, 0, 0);   // 85
    show("if (sel) (go |-> x)", p_if, f_if);
    show("go |=> (g2 |-> x)", p_nov, f_nov);
    show("p_imp(go, x)", p_inst, f_inst);
    show("p_gate_q(go, g2 |-> x)", p_gate, f_gate);
    show("disable iff (r) go |-> x", p_dis, f_dis);
    $finish;
  end
endmodule

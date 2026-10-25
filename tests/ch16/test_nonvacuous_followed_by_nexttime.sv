/*
:name: test_nonvacuous_followed_by_nexttime
:description: with the pass actions of vacuous successes turned off, s #-# p, s #=# p, nexttime [2] p, s_nexttime p and s_nexttime [2] p run the pass action only when the attempt of p that they start, at the end point of s, at the tick after it, or at the first or second next tick, is nonvacuous (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.9 16.12.10 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_followed_by_nexttime.expected
*/
// IEEE 1800-2023 §16.14.8: rule j) makes s #-# p nonvacuous exactly when s
// has an end point and the attempt of p started there is nonvacuous, rule k)
// does the same for s #=# p with the attempt started at the tick after the
// match, and rules m), n) and o) make nexttime [n] p, s_nexttime p and
// s_nexttime [n] p nonvacuous exactly when the ticks exist and the attempt of
// p at the last of them is nonvacuous. §16.12.9: a followed-by property is
// false when s has no match. §20.11: after $assertvacuousoff only nonvacuous
// successes run the pass action; failures still run the fail action. Here
// p = go |-> x; at the ticks 5 to 75 it is nonvacuously true at 5, 35 and 55,
// nonvacuously false at 25, and vacuously true elsewhere. Each assertion has
// its own trigger, high at three ticks: one whose p attempt is nonvacuously
// true, one where it is vacuously true and one where it is false. The
// nexttime forms are gated with trigger |-> (§16.12.7), so ticks without the
// trigger pass vacuously; the followed-by forms fail at each tick without
// their trigger. The action blocks (§16.14.1) record the times.

`timescale 1ns/1ns

module test_nonvacuous_followed_by_nexttime;
  logic clk = 0, go = 0, x = 0, s0 = 0, s1 = 0, s2 = 0, s3 = 0, s4 = 0;
  int p_fby0[$], f_fby0[$], p_fby1[$], f_fby1[$], p_nt2[$], f_nt2[$];
  int p_snt[$], f_snt[$], p_snt2[$], f_snt2[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_fby0: assert property (@(posedge clk) s0 #-# (go |-> x)) p_fby0.push_back($time);
    else f_fby0.push_back($time);
  a_fby1: assert property (@(posedge clk) s1 #=# (go |-> x)) p_fby1.push_back($time);
    else f_fby1.push_back($time);
  a_nt2: assert property (@(posedge clk) s2 |-> (nexttime [2] (go |-> x)))
    p_nt2.push_back($time); else f_nt2.push_back($time);
  a_snt: assert property (@(posedge clk) s3 |-> (s_nexttime (go |-> x)))
    p_snt.push_back($time); else f_snt.push_back($time);
  a_snt2: assert property (@(posedge clk) s4 |-> (s_nexttime [2] (go |-> x)))
    p_snt2.push_back($time); else f_snt2.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic vgo, logic vx, logic v0, logic v1, logic v2, logic v3, logic v4);
    go = vgo;
    x = vx;
    s0 = v0;
    s1 = v1;
    s2 = v2;
    s3 = v3;
    s4 = v4;
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
    //   go x  s0 s1 s2 s3 s4
    tick(1, 1, 1, 0, 1, 0, 1);   // 5
    tick(0, 0, 1, 1, 1, 1, 0);   // 15
    tick(1, 0, 1, 1, 1, 0, 1);   // 25
    tick(1, 1, 0, 1, 0, 0, 1);   // 35
    tick(0, 0, 0, 0, 0, 1, 0);   // 45
    tick(1, 1, 0, 0, 0, 1, 0);   // 55
    tick(0, 0, 0, 0, 0, 0, 0);   // 65
    tick(0, 0, 0, 0, 0, 0, 0);   // 75
    show("s0 #-# (go |-> x)", p_fby0, f_fby0);
    show("s1 #=# (go |-> x)", p_fby1, f_fby1);
    show("s2 |-> nexttime [2] (go |-> x)", p_nt2, f_nt2);
    show("s3 |-> s_nexttime (go |-> x)", p_snt, f_snt);
    show("s4 |-> s_nexttime [2] (go |-> x)", p_snt2, f_snt2);
    $finish;
  end
endmodule

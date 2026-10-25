/*
:name: test_nonvacuous_always_eventually
:description: with the pass actions of vacuous successes turned off, always [1:2] p, s_always [1:2] p, s_eventually p, s_eventually [1:2] p and eventually [1:2] p pass nonvacuously exactly when some attempt of p within their range, up to the deciding tick, is nonvacuous, and the failure of an unbounded always p is nonvacuous exactly when an attempt of p up to its failing tick is, as its negation shows (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.11 16.12.13 16.12.3 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_always_eventually.expected
*/
// IEEE 1800-2023 §16.14.8: rule p) makes always p nonvacuous exactly when p
// is nonvacuous at some tick and has not failed at an earlier one; rules q)
// and r) say the same for always [r] p and s_always [r] p within the range r;
// rule s) makes s_eventually p nonvacuous exactly when p is nonvacuous at
// some tick and has not held at an earlier one; rules t) and u) say the same
// for s_eventually [r] p and eventually [r] p within the range. Rule d)
// makes not q as vacuous as q. §16.12.11 and §16.12.13: the ranged forms
// count the ticks from the start of the attempt, so [1:2] covers the first and
// second ticks after it. §20.11: after $assertvacuousoff only nonvacuous
// successes run the pass action. Here p = go |-> x: at the ticks 5 to 95 it is
// nonvacuously true at 5 and 55, nonvacuously false at 35, 75 and 85, and
// vacuously true elsewhere. Each assertion is trigger |-> ... (§16.12.7) with
// its own trigger. An unbounded always p cannot succeed during the run, so its
// failures are seen through not always (not p): not p is vacuously false where
// p is vacuously true. For example, s_eventually p started at 35 passes at 45
// nonvacuously, as p was nonvacuous at 35, but s_eventually [1:2] p started
// at 35 passes at 45 only vacuously, as 35 is outside its range; and
// not always (not p) started at 15 fails always at once on a vacuous attempt,
// while the one started at 35 fails it at 45 after the nonvacuous attempt at
// 35. The action blocks (§16.14.1) record the times.

`timescale 1ns/1ns

module test_nonvacuous_always_eventually;
  logic clk = 0, go = 0, x = 0, tq = 0, tr = 0, ts = 0, tt = 0, tu = 0, tp = 0;
  int p_alw[$], f_alw[$], p_salw[$], f_salw[$], p_sev[$], f_sev[$];
  int p_sevr[$], f_sevr[$], p_evr[$], f_evr[$], p_nalw[$], f_nalw[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_alw: assert property (@(posedge clk) tq |-> (always [1:2] (go |-> x)))
    p_alw.push_back($time); else f_alw.push_back($time);
  a_salw: assert property (@(posedge clk) tr |-> (s_always [1:2] (go |-> x)))
    p_salw.push_back($time); else f_salw.push_back($time);
  a_sev: assert property (@(posedge clk) ts |-> (s_eventually (go |-> x)))
    p_sev.push_back($time); else f_sev.push_back($time);
  a_sevr: assert property (@(posedge clk) tt |-> (s_eventually [1:2] (go |-> x)))
    p_sevr.push_back($time); else f_sevr.push_back($time);
  a_evr: assert property (@(posedge clk) tu |-> (eventually [1:2] (go |-> x)))
    p_evr.push_back($time); else f_evr.push_back($time);
  a_nalw: assert property (@(posedge clk) tp |-> (not (always (not (go |-> x)))))
    p_nalw.push_back($time); else f_nalw.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic vgo, logic vx, logic [5:0] trig);
    go = vgo;
    x = vx;
    {tq, tr, ts, tt, tu, tp} = trig;
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
    //   go x  tq tr ts tt tu tp
    tick(1, 1, 6'b110001);   // 5
    tick(0, 0, 6'b001001);   // 15
    tick(0, 0, 6'b000100);   // 25
    tick(1, 0, 6'b101111);   // 35
    tick(0, 0, 6'b010010);   // 45
    tick(1, 1, 6'b100000);   // 55
    tick(0, 0, 6'b010110);   // 65
    tick(1, 0, 6'b001000);   // 75
    tick(1, 0, 6'b000000);   // 85
    tick(0, 0, 6'b000000);   // 95
    show("always [1:2] (go |-> x)", p_alw, f_alw);
    show("s_always [1:2] (go |-> x)", p_salw, f_salw);
    show("s_eventually (go |-> x)", p_sev, f_sev);
    show("s_eventually [1:2] (go |-> x)", p_sevr, f_sevr);
    show("eventually [1:2] (go |-> x)", p_evr, f_evr);
    show("not always (not (go |-> x))", p_nalw, f_nalw);
    $finish;
  end
endmodule

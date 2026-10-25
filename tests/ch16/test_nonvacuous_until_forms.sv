/*
:name: test_nonvacuous_until_forms
:description: with the pass actions of vacuous successes turned off, p until q and p s_until q pass nonvacuously when an attempt of p or of q up to the tick where q holds is nonvacuous, while p until_with q and p s_until_with q need a nonvacuous attempt of p (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.12 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_until_forms.expected
*/
// IEEE 1800-2023 §16.14.8: rules v) and w) make p until q and p s_until q
// nonvacuous exactly when, at some tick before which q has not held and p has
// held, the attempt of p or of q is nonvacuous; rules x) and y) say the same
// for until_with and s_until_with, but only an attempt of p counts. §16.12.12:
// the non-overlapping forms need p at each tick before the first tick where q
// holds, the overlapping forms at that tick too. §20.11: after
// $assertvacuousoff only nonvacuous successes run the pass action; failures
// still run the fail action. Here p = g1 |-> x1 and q = g2 |-> x2, and each
// assertion is s |-> (...) (§16.12.7), with s high at 5, 25, 45, 65, 85 and
// 105. At 5 both are vacuously true. At 25 q is vacuously true and p
// nonvacuously true (rule v) counts the attempt of p at that tick as well). At
// 45 q is nonvacuously false and p vacuously true, then both are vacuously
// true at 55. At 65 q is nonvacuously true and p vacuously true. At 85 p and q
// are both false. At 105 p is nonvacuously true and q false, then both are
// vacuously true at 115. The strong forms give the results of the weak ones,
// as q holds in the end. The action blocks (§16.14.1) record the times.
// Icarus Verilog 13.0 does not support these assertions. The 5.052 release
// of Verilator gives the same successes and failures but runs the pass
// action of the vacuous successes as well (at 5 for all four, at 55 and 65
// for the overlapping forms), as if $assertvacuousoff had no effect.

`timescale 1ns/1ns

module test_nonvacuous_until_forms;
  logic clk = 0, s = 0, g1 = 0, x1 = 0, g2 = 0, x2 = 0;
  int p_u[$], f_u[$], p_su[$], f_su[$], p_uw[$], f_uw[$], p_suw[$], f_suw[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_u: assert property (@(posedge clk) s |-> ((g1 |-> x1) until (g2 |-> x2)))
    p_u.push_back($time); else f_u.push_back($time);
  a_su: assert property (@(posedge clk) s |-> ((g1 |-> x1) s_until (g2 |-> x2)))
    p_su.push_back($time); else f_su.push_back($time);
  a_uw: assert property (@(posedge clk) s |-> ((g1 |-> x1) until_with (g2 |-> x2)))
    p_uw.push_back($time); else f_uw.push_back($time);
  a_suw: assert property (@(posedge clk) s |-> ((g1 |-> x1) s_until_with (g2 |-> x2)))
    p_suw.push_back($time); else f_suw.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic vs, logic vg1, logic vx1, logic vg2, logic vx2);
    s = vs;
    g1 = vg1;
    x1 = vx1;
    g2 = vg2;
    x2 = vx2;
    #10;
  endtask

  function automatic string times(int q[$]);
    string str = "";
    foreach (q[i]) str = {str, $sformatf(" %0d", q[i])};
    return str;
  endfunction

  function automatic void show(string name, int pq[$], int fq[$]);
    $display("%s: passes%s; failures%s", name, times(pq), times(fq));
  endfunction

  initial begin
    $assertvacuousoff;
    //   s  g1 x1 g2 x2
    tick(1, 0, 0, 0, 0);   // 5
    tick(0, 0, 0, 0, 0);   // 15
    tick(1, 1, 1, 0, 0);   // 25
    tick(0, 0, 0, 0, 0);   // 35
    tick(1, 0, 0, 1, 0);   // 45
    tick(0, 0, 0, 0, 0);   // 55
    tick(1, 0, 0, 1, 1);   // 65
    tick(0, 0, 0, 0, 0);   // 75
    tick(1, 1, 0, 1, 0);   // 85
    tick(0, 0, 0, 0, 0);   // 95
    tick(1, 1, 1, 1, 0);   // 105
    tick(0, 0, 0, 0, 0);   // 115
    show("p until q", p_u, f_u);
    show("p s_until q", p_su, f_su);
    show("p until_with q", p_uw, f_uw);
    show("p s_until_with q", p_suw, f_suw);
    $finish;
  end
endmodule

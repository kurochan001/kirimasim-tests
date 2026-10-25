/*
:name: test_nonvacuous_sequence_strong_weak
:description: with the pass actions of vacuous successes turned off, every success of a sequence property, of strong(sequence) and of weak(sequence) still runs its pass action, as these attempts are always nonvacuous, while an implication with a false antecedent passes vacuously (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.2 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_sequence_strong_weak.expected
*/
// IEEE 1800-2023 §16.14.8, rules a) to c): an evaluation attempt of a property
// that is a sequence, or that has the form strong(sequence) or weak(sequence),
// is always nonvacuous, so each of its successes is a nonvacuous success.
// Rule h) makes go |-> x vacuous when go is false. §20.11: after
// $assertvacuousoff the pass action runs only on nonvacuous successes, and the
// fail actions are not affected. Every assertion starts an attempt at each
// tick (5 to 55); the action blocks (§16.14.1) record the times. go ##1 x
// (§16.12.2) succeeds one tick after a tick with go when x is then high, and
// fails at a tick without go, or one tick after go when x is low; the strong
// and weak forms give the same results, as the ticks they need exist. The
// control assertion go |-> x shows that its vacuous successes at 15, 45 and 55
// do not run the pass action.

`timescale 1ns/1ns

module test_nonvacuous_sequence_strong_weak;
  logic clk = 0, go = 0, x = 0;
  int p_ctl[$], f_ctl[$], p_seq[$], f_seq[$], p_strong[$], f_strong[$], p_weak[$], f_weak[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_ctl: assert property (@(posedge clk) go |-> x) p_ctl.push_back($time);
    else f_ctl.push_back($time);
  a_seq: assert property (@(posedge clk) go ##1 x) p_seq.push_back($time);
    else f_seq.push_back($time);
  a_strong: assert property (@(posedge clk) strong(go ##1 x)) p_strong.push_back($time);
    else f_strong.push_back($time);
  a_weak: assert property (@(posedge clk) weak(go ##1 x)) p_weak.push_back($time);
    else f_weak.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic vgo, logic vx);
    go = vgo;
    x = vx;
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
    //   go x
    tick(1, 0);   // 5
    tick(0, 1);   // 15
    tick(1, 1);   // 25
    tick(1, 1);   // 35
    tick(0, 0);   // 45
    tick(0, 0);   // 55
    show("go |-> x", p_ctl, f_ctl);
    show("go ##1 x", p_seq, f_seq);
    show("strong(go ##1 x)", p_strong, f_strong);
    show("weak(go ##1 x)", p_weak, f_weak);
    $finish;
  end
endmodule

/*
:name: test_nonvacuous_not_and_abort
:description: with the pass actions of vacuous successes turned off, accept_on, reject_on, sync_accept_on and sync_reject_on succeed nonvacuously only when their operand is nonvacuous and the abort condition does not hold in a time step (asynchronous forms) or at a clock event (synchronous forms) of the attempt, and not p is nonvacuous exactly when p is, which also makes an aborted reject_on visible as a vacuous success of its negation (IEEE 1800-2023 Section 16.14.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.8 20.11 16.12.3 16.12.14 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonvacuous_not_and_abort.expected
*/
// IEEE 1800-2023 §16.14.8: rule d) makes not p nonvacuous exactly when p is.
// Rules ab) and ac) make accept_on (c) p and reject_on (c) p nonvacuous
// exactly when p is nonvacuous and c holds in no time step of the attempt;
// rules ad) and ae) do the same for sync_accept_on and sync_reject_on with
// the clock events of the attempt. §16.12.14: an abort makes accept_on true
// and reject_on false; the asynchronous forms look at the sampled value of c
// in every time step, the synchronous forms only at ticks. §20.11: after
// $assertvacuousoff only nonvacuous successes run the pass action; failures
// still run the fail action. Each assertion is start |-> ... (§16.12.7), and
// start is high at one tick of each phase, so each phase has one attempt of
// p = go |=> x: it is vacuous when go is low at that tick and is decided by x
// one tick later otherwise. The action blocks (§16.14.1) record the phase.
// Phase 1: go, then x, no abort (p nonvacuously true). Phase 2: no go (p
// vacuously true). Phase 3: go, no x (p nonvacuously false). Phases 4 and 5:
// go, and c high only between the two ticks, so that the time step at 9 sees
// it but no tick does; x is low in phase 4 and high in phase 5. Phase 6: go,
// x, and c high at the second tick. An aborted reject_on is false and vacuous,
// so its negation passes only vacuously and no pass action runs (phases 4 to
// 6), while not p and not sync_reject_on pass in phase 4, where p fails
// nonvacuously. Icarus Verilog 13.0 does not support these assertions. The
// 5.052 release of Verilator runs the test but differs from the standard: it
// does not see c between the ticks in accept_on and reject_on, runs the pass
// action of the accepted attempts of phase 6, and runs both actions of
// not (go |=> x) in every phase.

`timescale 1ns/1ns

module test_nonvacuous_not_and_abort;
  logic clk = 0, start = 0, go = 0, x = 0, c = 0;
  int phase = 0;
  int p_acc[$], f_acc[$], p_sacc[$], f_sacc[$], p_rej[$], f_rej[$], p_srej[$], f_srej[$];
  int p_nrej[$], f_nrej[$], p_nsrej[$], f_nsrej[$], p_not[$], f_not[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_acc: assert property (@(posedge clk) start |-> (accept_on (c) (go |=> x)))
    p_acc.push_back(phase); else f_acc.push_back(phase);
  a_sacc: assert property (@(posedge clk) start |-> (sync_accept_on (c) (go |=> x)))
    p_sacc.push_back(phase); else f_sacc.push_back(phase);
  a_rej: assert property (@(posedge clk) start |-> (reject_on (c) (go |=> x)))
    p_rej.push_back(phase); else f_rej.push_back(phase);
  a_srej: assert property (@(posedge clk) start |-> (sync_reject_on (c) (go |=> x)))
    p_srej.push_back(phase); else f_srej.push_back(phase);
  a_nrej: assert property (@(posedge clk) start |-> (not (reject_on (c) (go |=> x))))
    p_nrej.push_back(phase); else f_nrej.push_back(phase);
  a_nsrej: assert property (@(posedge clk) start |-> (not (sync_reject_on (c) (go |=> x))))
    p_nsrej.push_back(phase); else f_nsrej.push_back(phase);
  a_not: assert property (@(posedge clk) start |-> (not (go |=> x)))
    p_not.push_back(phase); else f_not.push_back(phase);

  // One phase of 30 time units: start and go for the tick at +5, x for the
  // tick at +15, and an idle tick at +25. cmode 1 raises c from +7 to +9,
  // cmode 2 from +10 to +20.
  task automatic run_phase(int k, logic vgo, logic vx, int cmode);
    phase = k;
    start = 1;
    go = vgo;
    if (cmode == 1) begin
      #7 c = 1;
      #2 c = 0;
      #1;
    end else begin
      #10;
    end
    start = 0;
    go = 0;
    x = vx;
    if (cmode == 2) c = 1;
    #10 x = 0;
    c = 0;
    #10;
  endtask

  function automatic string phases(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  function automatic void show(string name, int pq[$], int fq[$]);
    $display("%s: passes in phases%s; failures in phases%s", name, phases(pq), phases(fq));
  endfunction

  initial begin
    $assertvacuousoff;
    run_phase(1, 1, 1, 0);
    run_phase(2, 0, 0, 0);
    run_phase(3, 1, 0, 0);
    run_phase(4, 1, 0, 1);
    run_phase(5, 1, 1, 1);
    run_phase(6, 1, 1, 2);
    show("accept_on (c) (go |=> x)", p_acc, f_acc);
    show("sync_accept_on (c) (go |=> x)", p_sacc, f_sacc);
    show("reject_on (c) (go |=> x)", p_rej, f_rej);
    show("sync_reject_on (c) (go |=> x)", p_srej, f_srej);
    show("not reject_on (c) (go |=> x)", p_nrej, f_nrej);
    show("not sync_reject_on (c) (go |=> x)", p_nsrej, f_nsrej);
    show("not (go |=> x)", p_not, f_not);
    $finish;
  end
endmodule

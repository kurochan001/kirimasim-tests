/*
:name: test_recursive_property_abort_operators
:description: accept_on, reject_on, sync_accept_on and sync_reject_on can each be used in a recursive property, and the abort of such a property acts on the whole recursive evaluation: an asynchronous abort between ticks or a synchronous one at a tick ends it as true or false, and without an abort the recursion requires its operand at every tick (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.17 16.12.14 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_property_abort_operators.expected
*/
// IEEE 1800-2023 §16.12.17: the abort operators accept_on, reject_on,
// sync_accept_on and sync_reject_on may be used inside a recursive property.
// Each property here is abort (b) (p and (1'b1 |=> itself(p, b))) with one of
// the four operators: without an abort it needs p at every tick from its
// start. §16.12.14: an abort condition that becomes true during the
// evaluation makes accept_on and sync_accept_on true and reject_on and
// sync_reject_on false; the asynchronous forms look at the sampled value of b
// in every time step, the synchronous forms only at ticks. Each assertion
// starts at the tick T with go (§16.12.7); the fail actions count the failures
// of each phase (§16.14.1). busy is high at the ticks the line shows (T to
// T+3) and low afterwards. In phase 1 stop is high only between T+1 and T+2,
// so the asynchronous forms see it and the synchronous ones fail when busy
// falls at T+3; in phase 2 stop is high at the tick T+2; in phase 3 there is
// no stop and busy falls at T+2.

`timescale 1ns/1ns

module test_recursive_property_abort_operators;
  logic clk = 0, go = 0, busy = 0, stop = 0;
  int f_acc = 0, f_rej = 0, f_sacc = 0, f_srej = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property hold_acc(p, b);
    accept_on (b) (p and (1'b1 |=> hold_acc(p, b)));
  endproperty

  property hold_rej(p, b);
    reject_on (b) (p and (1'b1 |=> hold_rej(p, b)));
  endproperty

  property hold_sacc(p, b);
    sync_accept_on (b) (p and (1'b1 |=> hold_sacc(p, b)));
  endproperty

  property hold_srej(p, b);
    sync_reject_on (b) (p and (1'b1 |=> hold_srej(p, b)));
  endproperty

  a_acc: assert property (@(posedge clk) go |-> hold_acc(busy, stop)) else f_acc++;
  a_rej: assert property (@(posedge clk) go |-> hold_rej(busy, stop)) else f_rej++;
  a_sacc: assert property (@(posedge clk) go |-> hold_sacc(busy, stop)) else f_sacc++;
  a_srej: assert property (@(posedge clk) go |-> hold_srej(busy, stop)) else f_srej++;

  // One phase of six ticks, T at 5 after its start. busy follows bs at T to
  // T+3; smode 1 raises stop from 17 to 19, smode 2 from 20 to 30.
  task automatic run_phase(int k, logic [3:0] bs, int smode, string what);
    for (int s = 0; s < 60; s++) begin
      go = s < 10;
      busy = s < 40 ? bs[3 - s / 10] : 1'b0;
      stop = (smode == 1 && s >= 17 && s < 19) || (smode == 2 && s >= 20 && s < 30);
      #1;
    end
    $display("%s %s", $sformatf("phase %0d (busy %b, %s): accept_on %0d, reject_on %0d,",
                                k, bs, what, f_acc, f_rej),
             $sformatf("sync_accept_on %0d, sync_reject_on %0d", f_sacc, f_srej));
    f_acc = 0;
    f_rej = 0;
    f_sacc = 0;
    f_srej = 0;
  endtask

  initial begin
    run_phase(1, 4'b1110, 1, "stop between T+1 and T+2");
    run_phase(2, 4'b1110, 2, "stop at T+2");
    run_phase(3, 4'b1100, 0, "no stop");
    $finish;
  end
endmodule

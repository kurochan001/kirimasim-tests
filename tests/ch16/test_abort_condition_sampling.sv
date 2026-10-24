/*
:name: test_abort_condition_sampling
:description: accept_on and reject_on look at the sampled value of their condition in every time step of the evaluation, also between clock ticks, sync_accept_on and sync_reject_on only at the clock ticks, an abort makes the result true or false rather than disabling it, a condition seen in the time step where the evaluation ends takes precedence, and reject_on (c) p behaves as not (accept_on (c) not p) (IEEE 1800-2023 Section 16.12.14)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.14 16.5.1 16.12.3 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abort_condition_sampling.expected
*/
// IEEE 1800-2023 §16.12.14: if the abort condition becomes true during the
// evaluation of the operand, accept_on (c) p is true and reject_on (c) p is
// false; otherwise the result is that of p. An abort gives a result, so the
// fail action of reject_on runs. accept_on and reject_on check c in every
// time step, sync_accept_on and sync_reject_on only in the time steps of
// their clock; all of them use the sampled value of c (§16.5.1), from before
// any change in that time step. A condition that becomes true in the time
// step where p ends takes precedence. reject_on (c) p is the same as not
// (accept_on (c) not p) (§16.12.3), and likewise for the synchronous forms.
// Every assertion checks start |-> (...) ##2 done (§16.12.7); start is
// sampled high only at tick 0 of a phase, at T, and the evaluation ends at
// tick 2, at T+20. The fail actions (§16.14.1) count the failures of a
// phase. stop: "between ticks" is high from T+3 to T+6; "at tick 1" from
// T+8 to T+12; "with tick 1" rises at T+10, in the time step of tick 1 but
// before the clock edge, and falls at T+13; "with tick 2" rises in the time
// step of tick 2, at T+20, so after the evaluation its sampled value only
// changes at T+22; "at tick 2" from T+18 to T+22, sampled high from tick 2.

`timescale 1ns/1ns

module test_abort_condition_sampling;
  logic clk = 0, start = 0, done = 0, stop = 0;
  int f_acc = 0, f_rej = 0, f_sacc = 0, f_srej = 0, f_rej_d = 0, f_srej_d = 0;

  a_acc: assert property (@(posedge clk) start |-> accept_on (stop) ##2 done) else f_acc++;
  a_rej: assert property (@(posedge clk) start |-> reject_on (stop) ##2 done) else f_rej++;
  a_sacc: assert property (@(posedge clk) start |-> sync_accept_on (stop) ##2 done)
    else f_sacc++;
  a_srej: assert property (@(posedge clk) start |-> sync_reject_on (stop) ##2 done)
    else f_srej++;
  a_rej_d: assert property (@(posedge clk) start |-> not (accept_on (stop) not (##2 done)))
    else f_rej_d++;
  a_srej_d: assert property (@(posedge clk) start |-> not (sync_accept_on (stop) not (##2 done)))
    else f_srej_d++;

  // Runs one phase, from T-5 to T+35; mode selects the stop pulse.
  task automatic phase(string name, bit with_done, int mode);
    start = 1;
    #5 clk = 1;                          // T: tick 0
    #3 if (mode == 1) stop = 1;          // T+3
    #2 clk = 0;                          // T+5
    start = 0;
    #1 if (mode == 1) stop = 0;          // T+6
    #2 if (mode == 2) stop = 1;          // T+8
    #2 if (mode == 4) stop = 1;          // T+10
    clk = 1;                             // tick 1
    #2 if (mode == 2) stop = 0;          // T+12
    #1 if (mode == 4) stop = 0;          // T+13
    #2 clk = 0;                          // T+15
    done = with_done;
    #3 if (mode == 5) stop = 1;          // T+18
    #2 if (mode == 3) stop = 1;          // T+20
    clk = 1;                             // tick 2
    #2 if (mode == 5 || mode == 3) stop = 0;   // T+22
    #3 clk = 0;                          // T+25
    done = 0;
    #5 clk = 1;                          // T+30: tick 3
    #5 clk = 0;                          // T+35
    $display("%s: accept_on %0d, reject_on %0d, sync_accept_on %0d, sync_reject_on %0d, %s",
             name, f_acc, f_rej, f_sacc, f_srej,
             $sformatf("not accept_on not %0d, not sync_accept_on not %0d", f_rej_d, f_srej_d));
    f_acc = 0;
    f_rej = 0;
    f_sacc = 0;
    f_srej = 0;
    f_rej_d = 0;
    f_srej_d = 0;
  endtask

  initial begin
    phase("no stop, done", 1, 0);
    phase("no stop, no done", 0, 0);
    phase("between ticks, done", 1, 1);
    phase("between ticks, no done", 0, 1);
    phase("at tick 1, done", 1, 2);
    phase("at tick 1, no done", 0, 2);
    phase("with tick 2, done", 1, 3);
    phase("with tick 1, done", 1, 4);
    phase("at tick 2, done", 1, 5);
    phase("at tick 2, no done", 0, 5);
    $finish;
  end
endmodule

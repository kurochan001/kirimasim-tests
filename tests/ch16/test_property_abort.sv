/*
:name: test_property_abort
:description: accept_on and reject_on make an assertion pass or fail when their abort condition becomes true at any time step of an evaluation, sync_accept_on and sync_reject_on only when it is true at a clock tick, and without an abort the property decides (IEEE 1800-2023 Section 16.12.14)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.14 16.5.1 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_abort.expected
*/
// IEEE 1800-2023 §16.12.14: an evaluation of accept_on (c) p is true, and of
// reject_on (c) p false, if the abort condition c becomes true during it;
// otherwise p decides. accept_on and reject_on look at c in every time step,
// sync_accept_on and sync_reject_on only at clock ticks; all four use sampled
// values (16.5.1). Each assertion checks start |-> ##2 done with one of the
// four aborts, so an evaluation starts at a tick with start and ends two ticks
// later (16.12.7). The fail actions count the failures of each phase
// (16.14.1). In the first phase done comes in time and stop is high only
// between ticks, so only reject_on fails. In the second phase done does not
// come and stop is high at the middle tick, so the accepting forms pass and
// the rejecting forms fail. In the third phase done does not come and there is
// no stop, so all four fail.

`timescale 1ns/1ns

module test_property_abort;
  logic clk = 0, start = 0, done = 0, stop = 0;
  int f_acc = 0, f_rej = 0, f_sacc = 0, f_srej = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_acc: assert property (@(posedge clk) start |-> accept_on (stop) ##2 done) else f_acc++;
  a_rej: assert property (@(posedge clk) start |-> reject_on (stop) ##2 done) else f_rej++;
  a_sacc: assert property (@(posedge clk) start |-> sync_accept_on (stop) ##2 done)
    else f_sacc++;
  a_srej: assert property (@(posedge clk) start |-> sync_reject_on (stop) ##2 done)
    else f_srej++;

  task automatic report(string phase);
    $display("%s: accept_on %0d, reject_on %0d, sync_accept_on %0d, sync_reject_on %0d",
             phase, f_acc, f_rej, f_sacc, f_srej);
    f_acc = 0;
    f_rej = 0;
    f_sacc = 0;
    f_srej = 0;
  endtask

  initial begin
    // Phase 1: start at 5, stop high from 8 to 11, done at 25.
    start = 1;
    #8 stop = 1;
    #2 start = 0;
    #1 stop = 0;
    #9 done = 1;
    #10 done = 0;
    #10 report("stop between ticks, done in time");
    // Phase 2: start at 45, stop high at the tick at 55, no done at 65.
    start = 1;
    #10 start = 0;
    #2 stop = 1;
    #6 stop = 0;
    #22 report("stop at a tick, no done");
    // Phase 3: start at 85, no stop, no done at 105.
    start = 1;
    #10 start = 0;
    #30 report("no stop, no done");
    $finish;
  end
endmodule

/*
:name: test_wait_order_later_event_ignores_earlier_trigger
:description: wait_order uses the triggered state of the current time step only for its first event, so a later event triggered just before the construct starts must be triggered again, and an out-of-order trigger runs the else statement or, without one, calls $error (IEEE 1800-2023 Section 15.5.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_order_later_event_ignores_earlier_trigger.expected
:expected_stderr_regex: (?i)\berror\b
*/
// IEEE 1800-2023 §15.5.4: wait_order waits until its events are triggered in
// the listed order and fails when one of the events still to come is
// triggered before the events it follows. Only the first event in the list
// can be satisfied by its persistent triggered state; a later event has to be
// triggered while the construct waits for it. On a failure the else statement
// of the action block runs; without an else statement, a failure calls $error.
//
// At 10 a process triggers b and then starts wait_order(a, b): b is not the
// first event, so its trigger at 10 counts neither for the order nor as an
// out-of-order trigger. a at 12 and b at 14 complete the order: the pass
// statement stores 1 at 14. If the triggered state of b were used, the
// construct would have failed at 10 or 12 (status 0) or completed at 12.
// At 20 a process triggers c and then starts wait_order(c, d): c is first, so
// its triggered state counts and d at 22 completes the order at 22.
// At 30 wait_order(e, f) starts and f is triggered at 32, before e: the else
// statement stores 0 and counts one run, at 32.
// At 40 wait_order(g, h), which has no action block, starts and h is
// triggered at 42, before g: the failure calls $error, checked by
// :expected_stderr_regex: (the printed lines contain no such word), and the
// process goes on with its next statement at 42.
// Each phase starts after the previous one has ended, and the values are
// printed at 50 by one process. Neither Icarus Verilog 13.0 nor Verilator
// 5.054 supports wait_order, so :oracle: is spec alone.

`timescale 1ns/1ns

module test_wait_order_later_event_ignores_earlier_trigger;
  event a, b, c, d, e, f, g, h;
  int st_ab = -1, st_cd = -1, st_ef = -1, else_runs = 0;
  int t_ab = -1, t_cd = -1, t_ef = -1, t_gh = -1;

  initial begin
    #10;
    -> b;
    wait_order (a, b) st_ab = 1; else st_ab = 0;
    t_ab = $time;
  end
  initial begin
    #12 -> a;
    #2 -> b;
  end

  initial begin
    #20;
    -> c;
    wait_order (c, d) st_cd = 1; else st_cd = 0;
    t_cd = $time;
  end
  initial #22 -> d;

  initial begin
    #30;
    wait_order (e, f) st_ef = 1;
    else begin
      st_ef = 0;
      else_runs++;
    end
    t_ef = $time;
  end
  initial #32 -> f;

  initial begin
    #40;
    wait_order (g, h);
    t_gh = $time;
  end
  initial #42 -> h;

  initial begin
    #50;
    $display("b triggered before wait_order(a, b): status %0d at %0d", st_ab, t_ab);
    $display("c triggered before wait_order(c, d): status %0d at %0d", st_cd, t_cd);
    $display("f before e with else: status %0d at %0d, else ran %0d time", st_ef, t_ef,
             else_runs);
    $display("h before g without else: went on at %0d", t_gh);
  end
endmodule

/*
:name: test_named_event_alias_queue_and_triggered_wait
:description: a named event assigned from another shares its waiting queue, @ misses a trigger that came before it while wait on the triggered state does not in either order within the time step, the end of the step does not wake a wait on the triggered state, and triggered() is a bit (IEEE 1800-2023 Section 15.5)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5 15.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_event_alias_queue_and_triggered_wait.expected
*/
// IEEE 1800-2023 §15.5: a named event can be triggered explicitly, used in an
// event control, and assigned from another named event; it is a handle to a
// synchronization object that keeps a queue of the processes waiting on it.
// A process waits either with @, for a trigger that comes after the wait
// starts, or with wait() on the triggered state. §15.5.3: triggered() takes no
// argument and returns bit, true in the time step of a trigger and false
// otherwise. A wait on the triggered state is released whether it starts
// before the trigger (in an earlier step or earlier in the same step) or after
// it in the same step. A wait condition is evaluated again only when one of
// its operands changes, so the triggered state going back to 0 when time
// advances does not wake a wait.
//
// Time 10: one trigger of e1 releases three processes that started waiting at
// time 0: @(e1), @(alias1) after alias1 = e1, and wait(e1.triggered). If the
// assignment copied the event instead of sharing its object, @(alias1) would
// never be released (-1).
// Time 20: wait(e2.triggered) starts before the trigger in the same step (the
// trigger is delayed by #0 into the Inactive region, after the Active
// region where the wait blocks), and a second wait starts after a trigger by
// its own process; both are released at 20.
// Time 20/30: a process triggers e3 and then waits with @(e3): it misses its
// own trigger and is released only by the next trigger, at 30.
// Time 40: a process triggers e4 and waits for !e4.triggered || go, which is
// false then. A change of an unrelated variable at 45 starts a new time step;
// only go changing at 50 wakes the wait, so it ends at 50, not at 40 or 45.
// Time 60: $typename and $bits of triggered() give bit and 1, and the values
// for e1, triggered at 60, and e2, triggered at 20, are 1 and 0.
// Every value is stored and printed at time 70 by one process, so the order
// of the processes released together does not matter.
//
// Icarus Verilog 13.0 supports neither the assignment of an event nor
// triggered, and Verilator 5.054 does not support the assignment here. With
// the assignment taken out of a copy of the test, Verilator 5.054 gives the
// other lines but releases the wait on e4 at 45, when only the unrelated
// variable changes, which 15.5.3 does not allow.

`timescale 1ns/1ns

module test_named_event_alias_queue_and_triggered_wait;
  event e1, e2, e3, e4, alias1;
  bit go, other;
  int at_e1 = -1, at_alias = -1, at_wait1 = -1;
  int at_before = -1, at_after = -1, at_at = -1, at_fall = -1;
  bit t1, t2;

  initial @(e1) at_e1 = $time;
  initial begin
    alias1 = e1;
    @(alias1) at_alias = $time;
  end
  initial begin
    wait (e1.triggered);
    at_wait1 = $time;
  end
  initial #10 -> e1;

  initial begin
    #20;
    wait (e2.triggered);
    at_before = $time;
  end
  initial begin
    #20;
    #0 -> e2;
    wait (e2.triggered);
    at_after = $time;
  end

  initial begin
    #20;
    -> e3;
    @(e3) at_at = $time;
  end
  initial #30 -> e3;

  initial begin
    #40;
    -> e4;
    wait (!e4.triggered || go);
    at_fall = $time;
  end
  initial #45 other = 1;
  initial #50 go = 1;

  initial begin
    #60;
    -> e1;
    t1 = e1.triggered();
    t2 = e2.triggered;
    #10;
    $display("e1 trigger at 10: @e1 %0d, @alias1 %0d, wait triggered %0d", at_e1, at_alias,
             at_wait1);
    $display("e2 at 20: wait before trigger %0d, wait after trigger %0d", at_before, at_after);
    $display("e3 triggered at 20 then @e3: released at %0d", at_at);
    $display("e4 at 40: wait (!e4.triggered || go) released at %0d", at_fall);
    $display("triggered(): %s, %0d bit, e1 %b, e2 %b", $typename(e1.triggered()),
             $bits(e1.triggered()), t1, t2);
  end
endmodule

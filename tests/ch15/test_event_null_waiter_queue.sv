/*
:name: test_event_null_waiter_queue
:description: Assigning null to one of two merged event variables takes only that variable off the shared synchronization queue: triggering the null variable then releases nobody and leaves the other variable untriggered, its triggered method is false, and a trigger of the other variable still releases its waiters (IEEE 1800-2023 Section 15.5.5.2)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.5.2 15.5.5.1 15.5.3 15.5.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_null_waiter_queue.expected
*/
// IEEE 1800-2023 §15.5.5.1: e2 = e1, done before any process waits, makes
// both variables share one synchronization queue, so -> e1 at 1 releases the
// process waiting on e2. §15.5.5.2: e1 = null at 2, when no process waits,
// breaks the link between e1 and the queue, and triggering a null event has
// no effect. e2 keeps the queue (§15.5.5.3: e1 compares equal to null, e2
// does not). A second process waits on e2 from 2; -> e1 at 3 does nothing,
// so it stays blocked and e2.triggered stays 0, and -> e2 at 4 releases it.
// §15.5.3: the triggered method of the null e1 is false, while e2.triggered
// is true after -> e2. No variable is assigned while a process waits on it.

`timescale 1ns/1ns

module test_event_null_waiter_queue;
  event e1, e2;
  int w1 = -1, w2 = -1;
  bit trig1_3, trig2_3, trig1_4, trig2_4;

  initial begin
    e2 = e1;
    fork
      begin @e2; w1 = $time; end
    join_none
    #1 -> e1;
    #1 e1 = null;
    $display("t=2: e1 == null %0d, e2 == null %0d", e1 == null, e2 == null);
    fork
      begin @e2; w2 = $time; end
    join_none
    #1 -> e1;
    trig1_3 = e1.triggered;
    trig2_3 = e2.triggered;
    #1 $display("t=4: the first waiter on e2 woke at %0d, the second at %0d", w1, w2);
    -> e2;
    trig1_4 = e1.triggered;
    trig2_4 = e2.triggered;
    #1 $display("t=5: the second waiter on e2 woke at %0d", w2);
    $display("triggered at 3: e1 %0d e2 %0d, at 4: e1 %0d e2 %0d", trig1_3, trig2_3, trig1_4,
             trig2_4);
  end
endmodule

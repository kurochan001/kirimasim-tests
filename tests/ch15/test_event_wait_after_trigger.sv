/*
:name: test_event_wait_after_trigger
:description: A trigger releases every process already waiting on the event with @, while a process that reaches @ after the trigger, even the triggering process itself in the same time step, waits for the next trigger (IEEE 1800-2023 Section 15.5.2)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.2 15.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_wait_after_trigger.expected
*/
// IEEE 1800-2023 §15.5.2: @ e blocks until e is triggered, and a trigger
// releases a process only if the process executed @ before the trigger;
// otherwise it stays blocked. §15.5.1: -> e releases all the processes then
// waiting on e. Three processes wait from time 0, and the trigger at 1
// releases all three. The process that triggers then executes @ e itself in
// the same time step, after its own trigger, so it is not released until the
// trigger at 5, which also releases the process that started to wait at 2.

`timescale 1ns/1ns

module test_event_wait_after_trigger;
  event e;
  int woke = 0;
  int self_woke_at = -1, late_woke_at = -1;

  initial begin
    repeat (3)
      fork
        begin @e; woke++; end
      join_none
    #1 -> e;
    @e;                         // after the trigger: waits for the next one
    self_woke_at = $time;
  end

  initial begin
    #2 @e;
    late_woke_at = $time;
  end

  initial #5 -> e;

  initial begin
    #3 $display("t=3: %0d waiters released, the triggering process still waits: %0d", woke,
                self_woke_at < 0);
    #3 $display("t=6: the triggering process woke at %0d, the waiter from 2 at %0d, %0d released",
                self_woke_at, late_woke_at, woke);
  end
endmodule

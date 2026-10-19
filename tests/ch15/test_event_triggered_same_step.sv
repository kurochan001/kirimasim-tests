/*
:name: test_event_triggered_same_step
:description: The triggered state of a named event lasts for the rest of the time step, so wait(e.triggered) does not miss a trigger in the same step (IEEE 1800-2023 Section 15.5.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.3 15.5.2 15.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_triggered_same_step.expected
*/
// IEEE 1800-2023 §15.5.3: e.triggered is true from the moment e is triggered
// (15.5.1) until simulation time advances. So wait(e.triggered) (15.5.2) is
// released whether it starts before or after the trigger in the same time
// step, and e.triggered is false again in the next time step.

`timescale 1ns/1ns

module test_event_triggered_same_step;
  event e;
  int released_at = -1;
  bit seen_first, seen_next;

  initial begin
    #1;
    seen_first = e.triggered;
    -> e;
    seen_next = e.triggered;
  end

  initial begin
    #1;
    wait (e.triggered);         // the order against the trigger is not fixed
    released_at = $time;
  end

  initial begin
    #2;
    $display("before the trigger=%0d after it=%0d", seen_first, seen_next);
    $display("wait(e.triggered) released at %0d", released_at);
    $display("triggered at time 2: %0d", e.triggered);
  end
endmodule

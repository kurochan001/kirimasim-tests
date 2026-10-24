/*
:name: test_event_triggered_state_lasts_time_step
:description: the triggered state of an event stays true for the rest of the time step, through later regions, and is false in the next time step (IEEE 1800-2023 Section 6.17)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.17 15.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_triggered_state_lasts_time_step.expected
*/
// IEEE 1800-2023 §6.17: an event variable has a triggered state that lasts
// for the whole time step. §15.5.3: triggered() is 1 when the event was
// triggered in the current time step, until simulation time advances, and a
// wait on it that starts after the trigger in that time step does not block.
// The trigger happens at time 1 in the Active region. The observer reads the
// state after #0 (Inactive region), after a nonblocking update has woken it
// (after the NBA region), and in a wait, all still at time 1; then at time 2
// the state is 0, and a wait started at time 2 ends with the trigger at 3.
// Icarus Verilog 13.0 does not know the triggered method (unsupported
// construct).

`timescale 1ns/1ns
module test_event_triggered_state_lasts_time_step;
  event e;
  bit flag;

  initial begin
    #1 -> e;
    $display("t=%0t trigger process: %0d", $time, e.triggered);
    #2 -> e;
  end

  initial begin
    #1;
    #0;
    $display("t=%0t after #0: %0d", $time, e.triggered);
    wait (e.triggered);
    $display("t=%0t wait after the trigger passed", $time);
    flag <= 1;
    @(flag);
    $display("t=%0t after nonblocking update: %0d", $time, e.triggered);
    #1;
    $display("t=%0t next time step: %0d", $time, e.triggered);
    wait (e.triggered);
    $display("t=%0t wait started at time 2 ended", $time);
  end
endmodule

/*
:name: test_sched_nonblocking_event_trigger
:description: An event triggered with ->> wakes its waiting process in the NBA region, after the blocking writes that follow the trigger (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 15.5.1 9.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nonblocking_event_trigger.expected
*/
// IEEE 1800-2023 §15.5.1: ->> does not block; it creates a nonblocking assign
// update event, so the event occurs in the NBA region (§4.4.2.4) of the time
// step. The waiting process therefore resumes after the triggering process has
// written x twice and sees the last value.
// Icarus Verilog 13.0 does not support ->>, and Verilator 5.052 never wakes the
// waiting process (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_sched_nonblocking_event_trigger;
  event e;
  int x = 0;
  initial begin
    fork
      begin
        @(e);
        $display("event at %0t: x=%0d", $time, x);
      end
    join_none
    #0;
    x = 1;
    ->> e;
    x = 2;
  end
endmodule

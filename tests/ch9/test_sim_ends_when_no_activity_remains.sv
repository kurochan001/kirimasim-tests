/*
:name: test_sim_ends_when_no_activity_remains
:description: without $finish, the simulation ends by itself after the last scheduled event, even though an always procedure is still waiting for an event that never comes, and the final procedure then runs (IEEE 1800-2023 Section 9.6.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.1 9.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sim_ends_when_no_activity_remains.expected
*/
// IEEE 1800-2023 §9.6.1: the simulation ends by itself when there is no
// further activity of any kind. A process blocked on an event control that
// nothing will trigger is not activity. The end is an implicit $finish, so
// the final procedure runs then (9.2.3), at the time of the last event.
//
// The last scheduled event is at time 7. The always procedure waits for a
// named event that is never triggered. The final procedure prints the time
// at which the simulation ended and the value written at 7.

`timescale 1ns/1ns
module test_sim_ends_when_no_activity_remains;
  event never;
  int x = 0, woke = 0;

  always @(never) woke++;

  initial #3 x = 1;
  initial #7 x = 2;

  final $display("ended at t=%0t x=%0d woke=%0d", $time, x, woke);
endmodule

/*
:name: test_vpi_time_queue_current_and_end
:description: vpi_iterate(vpiTimeQueue, NULL) returns the time queues in increasing order of time, includes the current time only while events before read-only synchronization remain, and is NULL once nothing is left (IEEE 1800-2023 Section 37.81)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.81 38.36.2 38.13 4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_time_queue_current_and_end.c
:expected_stdout: @test_vpi_time_queue_current_and_end.expected
*/
// IEEE 1800-2023 §37.81: the time queue objects are returned in increasing
// order of simulation time (detail 1), vpi_iterate() returns NULL when nothing
// is left in the time queue (detail 2), and the current time queue is part of
// the iteration only if events that precede read-only synchronization remain
// (detail 3). §38.13: vpi_get_time of a time queue object gives its time in
// simulation time units. §38.36.2: a cbAtStartOfSimTime callback comes before
// the events of its time step, and a cbReadOnlySynch callback after all the
// events of the step that can change values (4.4).
//
// The design schedules events at 5, 20 and 25, declared in another order. At
// the start of simulation (time 0, so a requested time and a delay are the
// same) the application registers a cbAtStartOfSimTime callback at 5, where
// the resumption of the process waiting for 5 is still pending, and
// cbReadOnlySynch callbacks at 5 and at 25, the last time with events. Each
// callback prints the times of the iteration in the order returned, or that
// the iterator is NULL.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its vpi_user.h lacks vpiTimeQueue; a run with Verilator
// 5.052 prints a NULL iterator in all three callbacks.

`timescale 1ns/1ns

module test_vpi_time_queue_current_and_end;
  logic x = 1'b0, y = 1'b0, z = 1'b0;

  initial #25 z = 1'b1;
  initial #5 x = 1'b1;
  initial #20 y = 1'b1;
endmodule

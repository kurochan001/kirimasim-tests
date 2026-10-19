/*
:name: test_vpi_time_queue
:description: vpi_iterate(vpiTimeQueue, NULL) gives one object per future time at which events are scheduled, in increasing order of time, with that time from vpi_get_time, and NULL when nothing is left (IEEE 1800-2023 Section 37.81)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.81 38.11 9.4.1 9.4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_time_queue.c
:expected_stdout: @test_vpi_time_queue.expected
*/
// IEEE 1800-2023 §37.81: vpi_iterate(vpiTimeQueue, NULL) returns the time
// queue objects in increasing order of simulation time (detail 1), and NULL
// when nothing is left in the time queue (detail 2); vpi_get_time (§38.11)
// gives the time of each. The current time is returned only if events remain
// before read-only synchronization (detail 3), so the application prints the
// times after the current one. At 1, events are scheduled at 5 (a delay,
// §9.4.1), 11 (the update of a nonblocking assignment with an intra-assignment
// delay, §9.4.5), 30 and 40, while the delay of 34 of the calling process is
// scheduled only after the call; at 35 only 40 is left; at 40, after the
// last event, nothing is.

`timescale 1ns/1ns

module test_vpi_time_queue;
  logic x = 0, y = 0;

  initial #5 x = 1;
  initial y <= #11 1;
  initial #30 x = 0;
  initial #40 $vt_queue;

  initial begin
    #1 $vt_queue;
    #34 $vt_queue;
  end
endmodule

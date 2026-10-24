/*
:name: test_vpi_time_callbacks_without_events
:description: cbAtStartOfSimTime and cbAfterDelay callbacks run before the events of their time step and also at times with no event, cbNextSimTime runs before the events of the next time step whatever its time fields hold, and each kind of time callback gets a new s_cb_data with the current time and the registered user_data, the value field being ignored (IEEE 1800-2023 Section 38.36.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.36.3 4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_time_callbacks_without_events.c
:expected_stdout: @test_vpi_time_callbacks_without_events.expected
*/
// IEEE 1800-2023 §38.36.2: a cbAtStartOfSimTime callback runs before the
// events of its time step, and a cbAfterDelay callback after its delay and
// before the events of that step; both can be set for a time at which no
// event exists. A cbNextSimTime callback runs before the events of the next
// time step, and the time fields of its request are ignored. The value field
// of the request is ignored for the time callback reasons. The routine gets
// a pointer to a new s_cb_data, not to the one given to vpi_register_cb,
// whose time holds the current time and whose user_data is the registered
// one.
//
// At the start of the simulation (38.36.3), at time 0, where a time and a
// delay are the same, the application registers cbAtStartOfSimTime for 10
// and 15, cbAfterDelay for 20 and 25, cbAtEndOfSimTime for 30 and
// cbReadWriteSynch and cbReadOnlySynch for 35, from static s_cb_data
// structures whose value points to an s_vpi_value with a format that no
// table defines. The design writes v at 10, 20, 30 and 35 and w with a
// nonblocking assignment at 30; nothing happens at 15 and 25. The callback at
// 25 registers cbNextSimTime with a time of 2 in its fields: the next time
// step is 30. Each callback prints the time of its structure, its user_data,
// v and w, and whether its structure is a new one with the registered
// reason. The order of the lines at 30 and 35 is that of the regions of
// these reasons (4.10).
// For the cbNextSimTime callback, Verilator 5.052 passes the time fields of
// the request (2) instead of the current time.

`timescale 1ns/1ns

module test_vpi_time_callbacks_without_events;
  int v = 0, w = 0;

  initial begin
    #10 v = 1;
    #10 v = 2;
    #10 v = 3;
    w <= 4;
    #5 v = 5;
    #5 $finish;
  end
endmodule

/*
:name: test_vpi_routines_simulation_time
:description: the routine of Table 36-8 does what it lists: vpi_get_time gives the current simulation time in the simulation time unit and, for a module, in its own time unit, and gives the scheduled times of the future events from the time queue objects (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.13 37.81 38.36.2 3.14.2.2 3.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_simulation_time.c
:expected_stdout: @test_vpi_routines_simulation_time.expected
*/
// IEEE 1800-2023 §36.11, Table 36-8: vpi_get_time finds the current
// simulation time or the scheduled time of future events. §38.13: with a NULL
// object it gives the simulation time in the simulation time unit; with an
// object, in the time unit of the object; with a time queue object, the time
// of its future events in the simulation time unit. §3.14.3: the simulation
// time unit is the smallest time precision of the design, 1 ns here; the
// module sub has the time unit 10 ns (3.14.2.2). §37.81: vpi_iterate
// (vpiTimeQueue, NULL) gives the time queue objects in increasing order of
// time, and the current time only if events before read-only synchronization
// remain there.
// The application registers a cbReadOnlySynch callback for time 10 (38.36.2),
// when no events of time 10 remain; the design has events at 25, 40 and 50.
// It prints the current time with vpiSimTime and NULL, and with
// vpiScaledRealTime for the top module and for sub, and the times of the
// time queue objects.
// Icarus Verilog 13.0 has no vpiTimeQueue in its vpi_user.h; without the
// time queue it gives the other lines. Verilator 5.052 gives sub the time
// 10.0 and no time queue objects.

`timescale 1ns/1ns

module test_vpi_routines_simulation_time_sub;
  timeunit 10ns;
  timeprecision 1ns;
  logic s = 1'b0;
endmodule

module test_vpi_routines_simulation_time;
  logic x = 1'b0, y = 1'b0;

  test_vpi_routines_simulation_time_sub sub();

  initial #25 x = 1'b1;
  initial #40 y = 1'b1;
  initial #50 $display("design at 50: x=%b y=%b", x, y);
endmodule

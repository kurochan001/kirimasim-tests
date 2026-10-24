/*
:name: test_vpi_pli_error_callback_counts_failed_calls
:description: A cbPLIError callback runs once for each VPI call that fails with an error and not for the calls that succeed (IEEE 1800-2023 Section 38.36.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_pli_error_callback_counts_failed_calls.c
:expected_stdout: @test_vpi_pli_error_callback_counts_failed_calls.expected
*/
// IEEE 1800-2023 §38.36.3: cbPLIError is an action callback, which every VPI
// tool has, for a run-time error in a PLI function call. A startup routine may
// register it (36.10.2). §38.36.2: registering a cbAfterDelay callback whose
// time type is vpiSuppressTime, or whose time pointer is NULL, is an error,
// and no callback is created.
// The startup routine registers cbPLIError, cbStartOfSimulation and
// cbEndOfSimulation. At the start of the simulation, the application makes VPI
// calls that succeed (it reads the time, finds r by name and reads its size),
// then the two failing registrations, then again calls that succeed. The
// cbPLIError routine only counts its calls; it makes no VPI call, so it cannot
// cause an error itself. When the simulation ends, the application prints
// whether the registrations failed and how often cbPLIError ran: twice. The
// vpi_user.h of Icarus Verilog 13.0 lacks cbPLIError, and both registrations
// succeed in Verilator 5.052, so :oracle: names no simulator.

`timescale 1ns/1ns

module test_vpi_pli_error_callback_counts_failed_calls;
  logic [7:0] r;

  initial #1 r = 8'd1;
endmodule

/*
:name: test_vpi_simulation_action_callbacks
:description: Callbacks registered from vlog_startup_routines for the end of compilation, the start and the end of simulation run in that order around the design's own activity, and get their reason and user_data (IEEE 1800-2023 Sections 36.9.2 and 38.36.3)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.9.2 36.10.2 38.36.3 38.36
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_simulation_action_callbacks.c
:expected_stdout: @test_vpi_simulation_action_callbacks.expected
*/
// IEEE 1800-2023 §36.9.2, §36.10.2: a startup routine may register callbacks
// for cbEndOfCompile, cbStartOfSimulation and cbEndOfSimulation. §38.36.3:
// cbEndOfCompile comes when the design has been built, and from then on every
// VPI routine is available (36.10.2), so the callback finds r by name;
// cbStartOfSimulation comes at the beginning of the time 0 cycle, before the
// initial procedure runs; cbEndOfSimulation comes when the simulation ends,
// here by $finish at 10. Each callback gets the reason it was registered for
// and its user_data.

`timescale 1ns/1ns

module test_vpi_simulation_action_callbacks;
  logic [7:0] r = 8'h5a;

  initial begin
    $display("%0d: initial procedure, r = %h", $time, r);
    #10 $display("%0d: $finish", $time);
    $finish;
  end
endmodule

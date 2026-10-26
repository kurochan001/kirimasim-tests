/*
:name: test_vpi_callback_registration_errors
:description: vpi_register_cb refuses a cbForce callback on a variable bit-select, a zero-delay cbAtStartOfSimTime after entering a time slice, a zero-delay cbReadWriteSynch at read-only time, and a cbNextSimTime or cbAfterDelay whose time is NULL or of the suppressed type, and creates no callback for them (IEEE 1800-2023 Sections 38.36.1 and 38.36.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.36.2 38.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callback_registration_errors.c
:expected_stdout: @test_vpi_callback_registration_errors.expected
*/
// IEEE 1800-2023 §38.36.1: it is illegal to place a cbForce, cbRelease or
// cbDisable callback on a variable bit-select. §38.36.2: a cbAtStartOfSimTime
// callback with a delay of zero is an error once the simulation has entered a
// time slice, unless it is registered from another cbAtStartOfSimTime
// callback, a zero-delay cbReadWriteSynch at read-only synch time is an error,
// and for cbNextSimTime the time field must be a non-NULL time with the
// scaled-real or simulation time type, whose value is ignored; the suppressed
// time type or a NULL time is an error. Each refused registration returns NULL
// and creates no callback, which the application prints at the end of the
// simulation: such a callback never runs, while the callbacks that the clause
// allows run once. The design forces q at time 2, which is the next event
// queue after the start of the simulation, so both cbNextSimTime callbacks
// must run at 2 although their requested times differ.

`timescale 1ns/1ns

module test_vpi_callback_registration_errors;
  logic [3:0] q = 4'd0;

  initial begin
    #2 force q = 4'd9;
    #1 release q;
    #2;
  end
endmodule

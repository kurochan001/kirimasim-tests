/*
:name: test_vpi_time_callback_reentrant
:description: A cbAtStartOfSimTime callback that registers another cbAtStartOfSimTime with a delay of zero gets that callback in the same time slice (IEEE 1800-2023 Section 38.36.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.36
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_time_callback_reentrant.c
:expected_stdout: @test_vpi_time_callback_reentrant.expected
*/
// IEEE 1800-2023 §38.36.2: a cbAtStartOfSimTime callback occurs before the
// events of its time step. Placing a cbAtStartOfSimTime callback with a delay
// of zero during such a callback results in another cbAtStartOfSimTime
// callback during the same time slice; this differs from placing one with a
// delay of zero from another callback after the time slice has begun, which
// is an error.
//
// $vt_setup registers the first cbAtStartOfSimTime for time 5. Its callback
// registers a second one for the same time, which is a delay of zero, and
// both print their time. The design writes v at 10 and finishes at 20.

`timescale 1ns/1ns

module test_vpi_time_callback_reentrant;
  int v;

  initial begin
    $vt_setup;
    #10 v = 1;
    #10 $finish;
  end
endmodule

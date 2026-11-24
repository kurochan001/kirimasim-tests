/*
:name: test_vpi_time_callback_reentrant_start_stays_before_active_events
:description: A reentrant start-of-time callback runs before active events in the same time slice
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +time_reentrant
:vpi_c: @vpi_time_registration_boundaries.c
:expected_stdout: @test_vpi_time_callback_reentrant_start_stays_before_active_events.expected
*/
`timescale 1ps/1ps
module test_vpi_time_callback_reentrant_start_stays_before_active_events;
  initial begin
    #6 $display("active t=%0d", $time);
    #1 $display("fixture t=%0d", $time);
    $finish(0);
  end
endmodule

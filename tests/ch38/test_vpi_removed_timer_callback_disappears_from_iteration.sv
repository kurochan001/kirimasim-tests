/*
:name: test_vpi_removed_timer_callback_disappears_from_iteration
:description: Removing a queued timer callback makes it disappear while another timer still fires
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.39
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_removed_callback_disappears_from_iteration.c
:expected_stdout: @test_vpi_removed_timer_callback_disappears_from_iteration.expected
*/
`timescale 1ns/1ns
module test_vpi_removed_timer_callback_disappears_from_iteration;
  initial begin
    #2 $vt_remove_after_delay;
    #10 $vt_report_callback_calls;
  end
endmodule

/*
:name: test_vpi_removed_value_callback_disappears_from_iteration
:description: Removing a value callback makes it disappear from fresh VPI iteration and stops delivery
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.39
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_removed_callback_disappears_from_iteration.c
:expected_stdout: @test_vpi_removed_value_callback_disappears_from_iteration.expected
*/
`timescale 1ns/1ns
module test_vpi_removed_value_callback_disappears_from_iteration;
  bit watched = 0;

  initial begin
    #2 $vt_remove_value_change(watched);
    #2 watched = 1;
    #2 watched = 0;
    #2 $vt_report_callback_calls;
  end
endmodule

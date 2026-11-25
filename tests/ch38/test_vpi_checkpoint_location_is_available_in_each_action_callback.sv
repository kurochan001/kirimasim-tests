/*
:name: test_vpi_checkpoint_location_is_available_in_each_action_callback
:description: The checkpoint location is available at the start and end of save and restart
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.9 38.31
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_checkpoint_location_is_available_in_each_action_callback.expected
:expected_exit: 0
:vpi_c: @test_vpi_checkpoint_location_is_available_in_each_action_callback.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_checkpoint_location_is_available_in_each_action_callback;
  `include "request_restore_once.svh"

  initial begin
    #4 $save("callback-location.chk");
    #4;
    if (first_restore_request()) $restart("callback-location.chk");
    #1 $finish(0);
  end
endmodule

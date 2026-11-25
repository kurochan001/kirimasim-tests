/*
:name: test_vpi_end_save_data_is_available_at_start_of_restart
:description: VPI application data written at the end of save is available at the start of restart
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.9 38.31 36.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_end_save_data_is_available_at_start_of_restart.expected
:expected_exit: 0
:vpi_c: @test_vpi_end_save_data_is_available_at_start_of_restart.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_end_save_data_is_available_at_start_of_restart;
  `include "request_restore_once.svh"

  initial begin
    #4 $save("callback-phases.chk");
    #4;
    if (first_restore_request()) $restart("callback-phases.chk");
    #1 $finish(0);
  end
endmodule

/*
:name: test_vpi_put_data_counts_at_end_of_save
:description: An end-of-save callback writes four bytes and checks nonpositive counts before start-of-restart recovery
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.31 38.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_put_data_counts_at_end_of_save.expected
:expected_exit: 0
:vpi_c: @test_vpi_put_data_callback_boundaries.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_put_data_counts_at_end_of_save;
  `include "request_restore_once.svh"

  initial begin
    #1 $vt_select_checkpoint_writer(1);
    #3 $save("end-boundary.chk");
    #4;
    if (first_restore_request()) $restart("end-boundary.chk");
    #1 $finish(0);
  end
endmodule

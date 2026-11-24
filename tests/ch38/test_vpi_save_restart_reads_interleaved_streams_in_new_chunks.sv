/*
:name: test_vpi_save_restart_reads_interleaved_streams_in_new_chunks
:description: Save and restart preserve two interleaved VPI byte streams across different chunk sizes
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.31 38.9 D.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_save_restart_reads_interleaved_streams_in_new_chunks.expected
:expected_exit: 0
:vpi_c: @test_vpi_save_restart_reads_interleaved_streams_in_new_chunks.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_save_restart_reads_interleaved_streams_in_new_chunks;
  `include "request_restore_once.svh"

  initial begin
    #4 $save("interleaved-streams.chk");
    #4;
    if (first_restore_request()) $restart("interleaved-streams.chk");
    #1 $finish(0);
  end
endmodule

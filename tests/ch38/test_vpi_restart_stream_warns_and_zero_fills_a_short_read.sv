/*
:name: test_vpi_restart_stream_warns_and_zero_fills_a_short_read
:description: A short restart stream read returns the remaining bytes and fills the tail with zeros
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.9 38.31 D.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_restart_stream_warns_and_zero_fills_a_short_read.expected
:expected_exit: 0
:vpi_c: @test_vpi_restart_stream_warns_and_zero_fills_a_short_read.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_restart_stream_warns_and_zero_fills_a_short_read;
  `include "request_restore_once.svh"

  initial begin
    #4 $save("short-stream.chk");
    #4;
    if (first_restore_request()) $restart("short-stream.chk");
    #1 $finish(0);
  end
endmodule

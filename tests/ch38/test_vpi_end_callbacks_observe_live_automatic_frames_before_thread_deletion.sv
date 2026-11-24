/*
:name: test_vpi_end_callbacks_observe_live_automatic_frames_before_thread_deletion
:description: A frame end callback can read its automatic local before the matching forked thread ends
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.43 37.44
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_end_callbacks_observe_live_automatic_frames_before_thread_deletion.expected
:files: vpi_forked_lifetime_fixture.sv
:vpi_c: @vpi_forked_lifetime_callbacks.c
*/
`timescale 1ns/1ns

module test_vpi_end_callbacks_observe_live_automatic_frames_before_thread_deletion;
  vpi_forked_lifetime_fixture fixture();
endmodule

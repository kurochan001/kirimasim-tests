/*
:name: test_vpi_end_of_frame_or_thread_object_reports_no_time
:description: End-of-object callbacks observe automatic frames and threads and receive no time despite requesting simulation time
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.43 37.44
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_end_of_frame_or_thread_object_reports_no_time.expected
:files: vpi_forked_lifetime_fixture.sv
:vpi_c: @vpi_forked_lifetime_callbacks.c
*/
`timescale 1ns/1ns

module test_vpi_end_of_frame_or_thread_object_reports_no_time;
  vpi_forked_lifetime_fixture #(1) fixture();
endmodule

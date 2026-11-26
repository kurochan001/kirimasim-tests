/*
:name: test_vpi_frame_status_without_vpi_valid
:description: Track the end of a child frame with a lifetime callback and a fresh traversal
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.8 C.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_frame_status_without_vpi_valid.c
:expected_stdout: @test_vpi_frame_status_without_vpi_valid.expected
*/
`timescale 1ns/1ns

module test_vpi_frame_status_without_vpi_valid;
  task automatic child;
    int local_value = 24;
    $vt_arm_frame_watch;
    #4 $display("child returned value=%0d", local_value);
  endtask

  task automatic watch_child;
    fork
      child();
    join_none
    #1 $vt_sample_frame_watch;
    wait fork;
    #1 $vt_check_frame_watch;
  endtask

  initial begin
    watch_child();
    $finish(0);
  end
endmodule

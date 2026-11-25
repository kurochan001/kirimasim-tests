/*
:name: test_vpi_callbacks_at_thread_and_frame_start
:description: Thread and frame callbacks precede the bodies of two automatic tasks
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.43 37.44
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callbacks_at_thread_and_frame_start.c
:expected_stdout: @test_vpi_callbacks_at_thread_and_frame_start.expected
*/
`timescale 1ns/1ns
module test_vpi_callbacks_at_thread_and_frame_start;
  task automatic worker(input int argument);
    int local_value = argument + 21;
    if ($test$plusargs("trace_vpi_start"))
      $inspect_start_frame;
    $display("task body argument=%0d local=%0d", argument, local_value);
    #2;
  endtask

  initial begin
    if ($test$plusargs("trace_vpi_start"))
      $inspect_start_frame;
    #2;
    $display("before fork");
    fork
      worker(37);
      begin
        #1;
        worker(51);
      end
    join
    $display("after join");
    $finish(0);
  end
endmodule

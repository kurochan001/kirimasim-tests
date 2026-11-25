/*
:name: test_vpi_frame_and_thread_handle_release
:description: VPI handle release after two forked automatic task activations end at different times
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.2 37.43 37.44 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_frame_and_thread_handle_release.c
:expected_stdout: @test_vpi_frame_and_thread_handle_release.expected
*/
`timescale 1ns/1ns

module test_vpi_frame_and_thread_handle_release;
  int module_state = 53;

  task automatic worker(input int index, input int duration);
    int stamp = index + 23;
    logic [7:0] bits = 8'b10000110;
    $record_runtime_handles(index);
    #(duration) $display("worker %0d stamp=%0d bits=%b", index, stamp, bits);
  endtask

  initial begin
    fork
      begin
        worker(0, 3);
        #2 $display("branch 0 completed");
      end
      begin
        #1 worker(1, 5);
        #2 $display("branch 1 completed");
      end
    join_none
    #2 $sample_runtime_handles(1);
    #2 $sample_runtime_handles(2);
    #3 $sample_runtime_handles(3);
    #2 $sample_runtime_handles(4);
    wait fork;
  end
endmodule

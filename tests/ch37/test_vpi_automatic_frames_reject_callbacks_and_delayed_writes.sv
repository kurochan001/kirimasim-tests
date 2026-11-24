/*
:name: test_vpi_automatic_frames_reject_callbacks_and_delayed_writes
:description: Two live instances of a task reject callback registration and delayed writes to their automatic variables
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 38.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_automatic_frames_reject_callbacks_and_delayed_writes.expected
:expected_stderr_regex: (?im)\A(?=[\s\S]*^callback error: [^\n]*(?:vpi_register_cb[^\n]*automatic|automatic[^\n]*callback))(?=[\s\S]*^delay error: [^\n]*(?:vpi_put_value[^\n]*automatic|automatic[^\n]*(?:delay|vpiNoDelay)))[\s\S]*\Z
:vpi_c: @test_vpi_automatic_frames_reject_callbacks_and_delayed_writes.c
*/
`timescale 1ns/1ns
module test_vpi_automatic_frames_reject_callbacks_and_delayed_writes;
  task automatic exercise_frame(input int id);
    int local_value;
    static int persistent;
    local_value = id;
    $vt_check_auto(local_value, persistent, id);
    $display("frame %0d immediate=%0d", id, local_value);
    #4 $display("frame %0d later=%0d", id, local_value);
  endtask

  initial begin
    fork
      exercise_frame(1);
      begin
        #1;
        exercise_frame(2);
      end
    join
  end
endmodule

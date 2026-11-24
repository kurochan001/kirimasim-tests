/*
:name: test_vpi_value_change_callback_refuses_automatic_variable
:description: A live automatic variable rejects a value-change callback while a static variable notifies
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_value_change_callback_refuses_automatic_variable.expected
:vpi_c: @test_vpi_value_change_callback_refuses_automatic_variable.c
*/
`timescale 1ns/1ns
module test_vpi_value_change_callback_refuses_automatic_variable;
  int persistent_state;

  task automatic exercise_frame;
    int local_state;
    $vt_watch_value(local_state, 1);
    #1 local_state = 23;
    #1 $display("automatic value=%0d", local_state);
  endtask

  initial begin
    $vt_watch_value(persistent_state, 0);
    #1 persistent_state = 17;
    exercise_frame();
    #1 $display("static value=%0d", persistent_state);
  end
endmodule

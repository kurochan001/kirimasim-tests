/*
:name: test_vpi_delayed_write_refuses_automatic_variable
:description: A delayed write to a live automatic variable fails while the same write to a static variable takes effect
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_delayed_write_refuses_automatic_variable.expected
:vpi_c: @test_vpi_delayed_write_refuses_automatic_variable.c
*/
`timescale 1ns/1ns
module test_vpi_delayed_write_refuses_automatic_variable;
  int persistent_state;

  task automatic exercise_frame;
    int local_state;
    $vt_delayed_write(local_state, 1);
    #4 $display("automatic value=%0d", local_state);
  endtask

  initial begin
    $vt_delayed_write(persistent_state, 0);
    exercise_frame();
    $display("static value=%0d", persistent_state);
  end
endmodule

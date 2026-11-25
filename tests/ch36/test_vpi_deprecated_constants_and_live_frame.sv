/*
:name: test_vpi_deprecated_constants_and_live_frame
:description: The legacy interface iterator and fresh queries of live child frames
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 M.2 C.4.3 37.2.4 37.43 37.44
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_deprecated_constants_and_live_frame.c
:expected_stdout: @test_vpi_deprecated_constants_and_live_frame.expected
*/
`timescale 1ns/1ns

interface deprecated_constant_interface;
  logic signal;
endinterface

module test_vpi_deprecated_constants_and_live_frame;
  deprecated_constant_interface bus();
  virtual deprecated_constant_interface selected;

  task automatic child_task;
    int local_value = 17;
    #5 local_value += 7;
    $display("child return=%0d", local_value);
  endtask

  task automatic watch_child;
    fork
      child_task();
    join_none
    #2 $vt_live_child_frame;
    wait fork;
    #1 $vt_live_child_frame;
  endtask

  initial begin
    selected = bus;
    $vt_deprecated_interface;
    watch_child();
  end
endmodule

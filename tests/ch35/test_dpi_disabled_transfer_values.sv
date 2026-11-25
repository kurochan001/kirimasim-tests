/*
:name: test_dpi_disabled_transfer_values
:description: Observe output and inout values after disabled DPI calls alongside ordinary controls
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_disabled_transfer_values.cpp
:expected_stdout: @test_dpi_disabled_transfer_values.expected
*/
`timescale 1ns/1ns

module test_dpi_disabled_transfer_values;
  import "DPI-C" context task task_write(input int cancel, output int out, inout int io);
  import "DPI-C" context function int function_write(input int cancel, output int out,
                                                      inout int io);
  import "DPI-C" context task wrap_function(input int cancel);
  export "DPI-C" task task_stop;
  export "DPI-C" function function_stop;
  export "DPI-C" task sv_function_wrapper;

  int task_out, task_io, fun_out, fun_io, fun_result;

  task sv_function_wrapper(input int cancel);
    fun_result = function_write(cancel, fun_out, fun_io);
    $display("function wrapper completed");
  endtask

  task task_stop(input int cancel);
    if (cancel) disable task_worker;
  endtask

  function int function_stop(input int cancel);
    if (cancel) disable function_worker;
    return 63;
  endfunction

  initial begin : task_worker
    task_out = 11;
    task_io = 12;
    task_write(0, task_out, task_io);
    $display("task control=%0d/%0d", task_out, task_io);
    if ($test$plusargs("observe_disable")) begin
      task_out = 31;
      task_io = 32;
      #1 task_write(1, task_out, task_io);
      $display("task worker continued");
    end
  end

  initial begin : function_worker
    #2 fun_out = 21;
    fun_io = 22;
    wrap_function(0);
    $display("function control=%0d/%0d/%0d", fun_out, fun_io, fun_result);
    if ($test$plusargs("observe_disable")) begin
      fun_out = 41;
      fun_io = 42;
      fun_result = 43;
      #1 wrap_function(1);
      $display("function worker continued");
    end
  end

  initial begin
    #5;
    if ($test$plusargs("observe_disable")) begin
      $display("peer task=%0d/%0d", task_out, task_io);
      $display("peer function=%0d/%0d/%0d", fun_out, fun_io, fun_result);
    end
  end
endmodule

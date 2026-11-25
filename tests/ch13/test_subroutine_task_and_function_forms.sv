/*
:name: test_subroutine_task_and_function_forms
:description: Task enables and function calls use different argument and completion forms
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.2 13.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_task_and_function_forms.expected
*/
`timescale 1ns/1ns
module test_subroutine_task_and_function_forms;
  int ticks;

  function automatic int adjust(input int value);
    return value ^ 13;
  endfunction

  task tick;
    ticks++;
  endtask

  task automatic inner(input int value, output int result);
    #2;
    result = adjust(value);
    tick;
    $display("inner completed time=%0d result=%0d", $time, result);
  endtask

  task automatic outer(input int value, output int result);
    #3;
    inner(value, result);
    tick();
    $display("outer completed time=%0d result=%0d", $time, result);
  endtask

  initial begin
    int observed;
    $display("function result=%0d time=%0d", adjust(10), $time);
    outer(.result(observed), .value(10));
    $display("caller resumed time=%0d result=%0d ticks=%0d", $time, observed, ticks);
    $finish(0);
  end
endmodule

/*
:name: test_dpi_import_task_reentrant
:description: An imported task that calls an exported task with a delay suspends its thread inside the C code, so the same C code can be active in several threads at once, each with its own local variables (IEEE 1800-2023 Section 35.5.1.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.5 35.8 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_task_reentrant.c
:expected_stdout: @test_dpi_import_task_reentrant.expected
*/
// IEEE 1800-2023 §35.5.1.5: a call of an imported task suspends its thread
// when the task calls an exported task that waits, so the C code of an
// imported task can be active in several threads at the same time (35.8).
// c_waiter keeps a local variable, waits through sv_wait and reports it
// through sv_report. The first thread enters at 0 and waits 5, the second
// enters at 1 and waits 2; both are inside c_waiter from 1 to 3, so the
// largest number of active calls is 2, and each gets its own local back.

`timescale 1ns/1ns

module test_dpi_import_task_reentrant;
  import "DPI-C" context task c_waiter(input int id, input int d);
  import "DPI-C" function int c_max_active();
  export "DPI-C" task sv_wait;
  export "DPI-C" function sv_report;

  task sv_wait(input int d);
    #d;
  endtask

  function void sv_report(input int id, input int local_value);
    $display("t=%0t: thread %0d back in C, local=%0d", $time, id, local_value);
  endfunction

  initial begin
    fork
      c_waiter(1, 5);
      #1 c_waiter(2, 2);
    join
    $display("most calls active at once: %0d", c_max_active());
  end
endmodule

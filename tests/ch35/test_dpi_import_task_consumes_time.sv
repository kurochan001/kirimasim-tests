/*
:name: test_dpi_import_task_consumes_time
:description: Imported functions, and an exported function called from C, complete without simulation time passing, while an imported task, which returns no value to SystemVerilog, consumes time by calling an exported task that waits (IEEE 1800-2023 Sections 35.2.1 and 35.5.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.1 35.5.1.1 35.8 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_task_consumes_time.c
:expected_stdout: @test_dpi_import_task_consumes_time.expected
*/
// IEEE 1800-2023 §35.2.1: functions used through DPI complete at once and
// take no simulation time, like native functions, while task enables also
// cross the language boundary: SystemVerilog calls imported tasks and foreign
// code calls SystemVerilog tasks, and an imported task has the semantics of a
// native task, returning no value and able to consume simulation time.
// §35.5.1.1: imported functions take no simulation time; imported tasks can.
// At 5 the design calls the imported function dpi_add and the context
// function dpi_square_via_sv, which calls the exported function sv_square,
// and prints the time that passed, 0. It then calls the context task
// dpi_wait_steps, which calls the exported task sv_wait (35.8, 35.5.3), which
// waits 4, three times, and reports the count in an output argument; the
// task returns at 17. Another process prints at 10, while the task waits.
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 does not support
// timing controls in exported tasks.

`timescale 1ns/1ns

module test_dpi_import_task_consumes_time;
  import "DPI-C" function int dpi_add(input int a, input int b);
  import "DPI-C" context function int dpi_square_via_sv(input int v);
  import "DPI-C" context task dpi_wait_steps(input int n, output int done);
  export "DPI-C" function sv_square;
  export "DPI-C" task sv_wait;

  function int sv_square(input int v);
    return v * v;
  endfunction

  task sv_wait(input int d);
    #d;
  endtask

  time t0;
  int s, q, done;

  initial begin
    #5 t0 = $time;
    s = dpi_add(2, 3);
    q = dpi_square_via_sv(6);
    $display("%0t: functions returned %0d and %0d, %0t passed", $time, s, q, $time - t0);
    dpi_wait_steps(3, done);
    $display("%0t: task returned, done=%0d, %0t passed", $time, done, $time - t0);
  end

  initial #10 $display("%0t: another process runs while the task waits", $time);
endmodule

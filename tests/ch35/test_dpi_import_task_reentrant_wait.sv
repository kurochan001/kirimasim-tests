/*
:name: test_dpi_import_task_reentrant_wait
:description: An imported task that calls an exported task waiting on an event control or a wait statement suspends its thread inside the C code, so three calls of the same C function are active at once and share its static variables but not its locals (IEEE 1800-2023 Section 35.5.1.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.5 35.8 35.5.3 9.4.2 9.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_task_reentrant_wait.c
:expected_stdout: @test_dpi_import_task_reentrant_wait.expected
*/
// IEEE 1800-2023 §35.5.1.5: when an imported task calls an exported task that
// executes a delay control, an event control or a wait statement, the thread
// is suspended, so the C code of the task can be active in several threads at
// once, and static variables are shared between them. Three threads call
// c_visit at 0. Threads 1 and 2 wait in sv_wait_level on a wait statement
// (9.4.3) for level to reach 1 and 2, set at 5 and 10; thread 3 waits in
// sv_wait_event on an event control (9.4.2) for go, triggered at 15. The
// static variable active counts the calls under way, and the automatic task
// keeps each call's own argument and local value, which it reports through
// sv_back (35.8).

`timescale 1ns/1ns

module test_dpi_import_task_reentrant_wait;
  import "DPI-C" context task c_visit(input int id);
  export "DPI-C" task sv_wait_level;
  export "DPI-C" task sv_wait_event;
  export "DPI-C" function sv_back;

  event go;
  int level;

  task automatic sv_wait_level(input int n);
    wait (level >= n);
  endtask

  task sv_wait_event();
    @go;
  endtask

  function void sv_back(input int id, input int active, input int own);
    $display("t=%0t: thread %0d back in C, %0d call(s) inside, own value %0d", $time, id,
             active, own);
  endfunction

  initial begin
    fork
      c_visit(1);
      c_visit(2);
      c_visit(3);
    join
    $display("t=%0t: all calls returned", $time);
  end

  initial begin
    #5 level = 1;
    #5 level = 2;
    #5 -> go;
  end
endmodule

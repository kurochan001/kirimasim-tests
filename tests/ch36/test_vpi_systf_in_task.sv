/*
:name: test_vpi_systf_in_task
:description: A user-defined system task can be called from a task, runs at each call of that task, and the task may be called from another task (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9.1 13.3 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_in_task.c
:expected_stdout: @test_vpi_systf_in_task.expected
*/
// IEEE 1800-2023 §36.4: a user-defined system task is called like a built-in
// system task from any procedural code, which includes the body of a task
// (13.3). The task note calls $vt_note at each of its calls. It is called
// once from the initial procedure, then twice through the task twice, so
// $vt_note runs three times and its argument is the running total of the
// program. §36.9.1: the application registers $vt_note and $vt_report from
// vlog_startup_routines.

module test_vpi_systf_in_task;
  int total = 0;

  task automatic note(input int by);
    total += by;
    $vt_note(total);
  endtask

  task automatic twice();
    note(2);
    note(3);
  endtask

  initial begin
    note(1);
    twice();
    $vt_report(total);
  end
endmodule

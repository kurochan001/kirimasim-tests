/*
:name: test_timeunit_scope_task
:description: A delay in a task declared in the compilation-unit scope is in the time unit of that scope, not in that of the module that calls it (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.12.1 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_scope_task.expected
*/
// IEEE 1800-2023 §3.12.1: a task may be declared in the compilation-unit
// scope, where every module can call it. §3.14.2.2: timeunit and
// timeprecision set the time unit and precision of that scope, here 100ps and
// 10ps. §3.14.2.3: a delay uses the time unit of the scope that declares the
// code around it, so the #25 of the task is 2.5ns although the calling module
// has a time unit of 1ns; the module's #1 is 1ns. The report task of the
// module prints both times in ns, and §20.3.3 gives $realtime there.

`timescale 1ns / 1ps

timeunit 100ps;
timeprecision 10ps;

task automatic unit_step;
  #25 test_timeunit_scope_task.report("$unit task, #25 in units of 100ps");
endtask

module test_timeunit_scope_task;
  timeunit 1ns;
  timeprecision 1ps;

  task report(string what);
    $display("%0.2f ns: %s", $realtime, what);
  endtask

  initial begin
    unit_step();
    #1 report("module, #1 in units of 1ns");
  end
endmodule

/*
:name: test_runtime_realtime_delay_uses_package_task_time_scope
:description: Two package tasks round the same runtime real delay at their own precision before returning to a finer caller
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 3.14.1 3.14.2.2 26.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_runtime_realtime_delay_uses_package_task_time_scope.expected
*/
package coarse_task_clock;
  timeunit 1ns;
  timeprecision 100ps;

  task automatic coarse_wait(input realtime interval);
    #(interval);
  endtask
endpackage

package fine_task_clock;
  timeunit 1ns;
  timeprecision 10ps;

  task automatic fine_wait(input realtime interval);
    #(interval);
  endtask
endpackage

module test_runtime_realtime_delay_uses_package_task_time_scope;
  timeunit 1ps;
  timeprecision 1ps;
  import coarse_task_clock::coarse_wait;
  import fine_task_clock::fine_wait;

  task automatic sample(input string label_text, input realtime amount);
    time started, coarse_ticks, fine_ticks;
    started = $time;
    coarse_wait(amount);
    coarse_ticks = $time - started;
    started = $time;
    fine_wait(amount);
    fine_ticks = $time - started;
    $display("%s coarse=%0d fine=%0d", label_text, coarse_ticks, fine_ticks);
  endtask

  initial begin
    #1;
    sample("below fine half step", 0.044);
    sample("above fine half step", 0.046);
    sample("between coarse steps", 0.146);
    $finish(0);
  end
endmodule

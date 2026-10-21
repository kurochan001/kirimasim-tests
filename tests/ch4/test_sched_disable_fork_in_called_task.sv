/*
:name: test_sched_disable_fork_in_called_task
:description: disable fork in a task ends the processes spawned by the process that called the task (IEEE 1800-2023 Section 4.4.2.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 9.6.3 13.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_disable_fork_in_called_task.expected
*/
// IEEE 1800-2023 §9.6.3: disable fork applies to the calling process. A task
// (§13.3) runs in the process that calls it, so disable fork in the task ends
// the child that the caller spawned before the call; the caller itself goes on.
// Icarus Verilog 13.0 does not end the child, which prints at 3
// (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_sched_disable_fork_in_called_task;
  task stop_children();
    disable fork;
  endtask

  initial begin
    fork
      #3 $display("child at %0t", $time);
    join_none
    #1 stop_children();
    $display("caller goes on at %0t", $time);
    #4 $display("caller at %0t", $time);
  end
endmodule

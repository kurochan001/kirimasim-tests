/*
:name: test_disable_task_from_another_process
:description: disable with a task's name ends every running activation of the task, and each caller resumes after its call (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_task_from_another_process.expected
*/
// IEEE 1800-2023 §9.6.2: disabling a task by its name ends the task's
// activity, also when the disable statement is in another process. When the
// task was enabled more than once, every activation of it ends. Each process
// that called it resumes at the statement after its call, and the rest of
// the task does not run. A later call runs the task to its end as usual.

module test_disable_task_from_another_process;
  int finished = 0;
  int first_resumed = -1, second_resumed = -1;

  task wait_then_mark;
    #5 finished++;
  endtask

  initial begin
    wait_then_mark;
    first_resumed = $time;
  end

  initial begin
    #1 wait_then_mark;
    second_resumed = $time;
  end

  initial begin
    #2 disable wait_then_mark;
    #10;
    $display("callers resumed at %0d and %0d, finished=%0d", first_resumed, second_resumed,
             finished);
    wait_then_mark;
    $display("t=%0d a later call finished, finished=%0d", $time, finished);
  end
endmodule

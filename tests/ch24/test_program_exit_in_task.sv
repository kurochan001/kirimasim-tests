/*
:name: test_program_exit_in_task
:description: $exit ends all initial procedures of the program when it is called in a task that an initial procedure calls (IEEE 1800-2023 Section 24.7)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.7 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_exit_in_task.expected
*/
// IEEE 1800-2023 §24.7: $exit ends every initial procedure of the program
// that calls it, and all their descendant threads. The initial procedure of
// p_task_exit calls stop_now at 2, and the $exit in that task ends the
// procedure, so the message after the call never appears, and it also ends
// the other initial procedure, whose #4 never matures. §24.3: when every
// initial procedure of every program has ended, the simulation ends by an
// implicit $finish, so the module's message at 10 never appears; its final
// procedure runs at 2. The 5.052 release returns from the task instead of
// ending the initial procedure, which the test records as its difference.

`timescale 1ns/1ns

program p_task_exit;
  task automatic stop_now();
    $display("%0d: task calls $exit", $time);
    $exit;
  endtask

  initial begin
    #2 stop_now();
    $display("%0d: after the task", $time);
  end

  initial #4 $display("%0d: other initial", $time);
endprogram

module test_program_exit_in_task;
  initial #10 $display("%0d: module still running", $time);
  final $display("%0d: final", $time);
endmodule

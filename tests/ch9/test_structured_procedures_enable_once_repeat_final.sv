/*
:name: test_structured_procedures_enable_once_repeat_final
:description: initial and always procedures start at time 0, an initial procedure runs once and an always procedure repeats until $finish, the final procedure runs once at the end, and tasks and functions run only when called (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2 9.2.1 9.2.2.1 9.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_structured_procedures_enable_once_repeat_final.expected
*/
// IEEE 1800-2023 §9.2: initial and always procedures are enabled when the
// simulation begins. An initial procedure runs its statement once and then
// ceases; an always procedure runs its statement again and again until the
// simulation is terminated. Final procedures are enabled at the end of the
// simulation and run once. Tasks and functions are procedures that run when
// another procedure calls them.
//
// The always procedure counts its passes, one every 10 time units from time
// 0. One initial procedure counts its own single pass, waits, and calls the
// task note; a second initial procedure prints the counters at the fixed
// times 1, 21 and 41, calls note and the function twice_of, and ends the run
// at 41. The task never_task and the function never_func are never called
// and would print a line if they ran. The final procedure prints the time and
// the counters, and counts its own runs.

`timescale 1ns/1ns

module test_structured_procedures_enable_once_repeat_final;
  int always_runs = 0;
  int initial_runs = 0;
  int task_runs = 0;
  int func_runs = 0;
  int final_runs = 0;

  task note(input int who);
    task_runs++;
    $display("%0t note called by procedure %0d", $time, who);
  endtask

  task never_task();
    $display("never_task ran");
  endtask

  function int twice_of(input int k);
    func_runs++;
    return 2 * k;
  endfunction

  function int never_func();
    $display("never_func ran");
    return 0;
  endfunction

  always begin
    always_runs++;
    #10;
  end

  initial begin
    initial_runs++;
    #5;
    note(1);
  end

  initial begin
    #1 $display("t=1: always_runs=%0d initial_runs=%0d", always_runs, initial_runs);
    #20 $display("t=21: always_runs=%0d initial_runs=%0d", always_runs, initial_runs);
    note(2);
    $display("twice_of(7)=%0d", twice_of(7));
    #20 $display("t=41: always_runs=%0d initial_runs=%0d", always_runs, initial_runs);
    $finish;
  end

  final begin
    final_runs++;
    $display("final at %0t: always_runs=%0d initial_runs=%0d", $time, always_runs, initial_runs);
    $display("final: task_runs=%0d func_runs=%0d final_runs=%0d", task_runs, func_runs, final_runs);
  end
endmodule

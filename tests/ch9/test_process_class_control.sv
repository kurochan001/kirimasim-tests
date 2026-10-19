/*
:name: test_process_class_control
:description: The process class: self, status and kill (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_class_control.expected
*/
// IEEE 1800-2023 §9.7: process::self() returns a handle to the calling process.
// status() is WAITING while the process is blocked, FINISHED once it has ended
// normally and KILLED once kill() has ended it. A killed process does not run
// the rest of its statements. test_process_suspend_resume_await checks
// suspend(), resume() and await().

`timescale 1ns/1ns

module test_process_class_control;
  process p_kill, p_done;
  int kill_reached = 0;

  initial begin
    fork
      begin p_kill = process::self(); #10 kill_reached = 1; end
      begin p_done = process::self(); #3; end
    join_none
    #1;
    $display("%0d: waiting=%0d", $time, p_kill.status() == process::WAITING);
    p_kill.kill();
    $display("%0d: killed=%0d", $time, p_kill.status() == process::KILLED);
    #3;
    $display("%0d: finished=%0d", $time, p_done.status() == process::FINISHED);
    #10;
    $display("%0d: kill_reached=%0d", $time, kill_reached);
  end
endmodule

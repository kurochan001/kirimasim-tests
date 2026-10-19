/*
:name: test_process_suspend_resume_await
:description: The process class: await waits for another process to end, and a process suspended during a delay continues only after resume (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_suspend_resume_await.expected
*/
// IEEE 1800-2023 §9.7: await() returns when the other process has ended.
// suspend() on a process that waits on a delay stops it from reacting to the
// end of the delay, and status() is then SUSPENDED. resume() makes it sensitive
// again; if the delay has already passed, it continues in the current time
// step.
//
// Version 5.052 of Verilator stops at suspend(), which it does not support,
// and does not return from await(); Icarus Verilog 13.0 does not compile the
// process class.

`timescale 1ns/1ns

module test_process_suspend_resume_await;
  process p_done, p_susp;
  int susp_reached = 0;

  initial begin
    fork
      begin p_done = process::self(); #3; end
      begin p_susp = process::self(); #4 susp_reached = 1; end
    join_none
    #1;
    p_done.await();
    $display("%0d: await returned, finished=%0d", $time, p_done.status() == process::FINISHED);
    p_susp.suspend();
    #5;
    $display("%0d: suspended=%0d reached=%0d", $time, p_susp.status() == process::SUSPENDED, susp_reached);
    p_susp.resume();
    #1;
    $display("%0d: reached=%0d finished=%0d", $time, susp_reached, p_susp.status() == process::FINISHED);
  end
endmodule

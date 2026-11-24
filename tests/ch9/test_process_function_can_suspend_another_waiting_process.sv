/*
:name: test_process_function_can_suspend_another_waiting_process
:description: A function may suspend another process and the caller can resume it
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 G.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_function_can_suspend_another_waiting_process.expected
*/
`timescale 1ns/1ns
module test_process_function_can_suspend_another_waiting_process;
  std::process worker;
  bit start_work, completed;

  function automatic void pause_target(std::process target);
    target.suspend();
  endfunction

  initial begin
    fork
      begin
        worker = std::process::self();
        wait (start_work);
        completed = 1;
      end
    join_none
    #1 pause_target(worker);
    $display("suspended=%b", worker.status() == std::process::SUSPENDED);
    start_work = 1;
    #1 $display("while stopped=%b", completed);
    worker.resume();
    #1 $display("after resume=%b finished=%b", completed,
                worker.status() == std::process::FINISHED);
  end
endmodule

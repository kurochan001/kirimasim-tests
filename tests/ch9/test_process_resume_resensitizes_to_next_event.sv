/*
:name: test_process_resume_resensitizes_to_next_event
:description: A waiting process is resensitized after suspend and resume and misses events during suspension
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 G.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_resume_resensitizes_to_next_event.expected
*/
`timescale 1ns/1ns
module test_process_resume_resensitizes_to_next_event;
  event pulse;
  std::process waiter;
  int resumed_at = -1;

  initial begin
    fork
      begin
        waiter = std::process::self();
        @pulse;
        resumed_at = int'($time);
      end
    join_none

    #1;
    $display("waiting=%0d", waiter.status() == std::process::WAITING);
    waiter.suspend();
    $display("suspended=%0d", waiter.status() == std::process::SUSPENDED);

    #2 -> pulse;
    #1 waiter.resume();
    #1 $display("before_new_event=%0d", resumed_at);
    #1 -> pulse;
    waiter.await();
    $display("resumed_at=%0d", resumed_at);
    $finish;
  end
  initial #20 $fatal(1, "process did not resume");
endmodule

/*
:name: test_process_await_normal_and_forced_termination
:description: Process await resumes on natural completion or kill and returns at once for a terminal handle
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 G.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_await_normal_and_forced_termination.expected
*/
// Normal and forced termination occur at separate times. Each observer
// records when its await returns and immediately awaits the same handle.
`timescale 1ns/1ns
module test_process_await_normal_and_forced_termination;
  std::process normal_target, killed_target;
  int normal_time, killed_time, normal_again, killed_again;

  initial begin
    fork
      begin
        normal_target = std::process::self();
        #5;
      end
      begin
        killed_target = std::process::self();
        #30;
      end
    join_none

    #1;
    fork
      begin
        normal_target.await();
        normal_time = int'($time);
        normal_target.await();
        normal_again = int'($time);
      end
      begin
        killed_target.await();
        killed_time = int'($time);
        killed_target.await();
        killed_again = int'($time);
      end
      begin
        #7 killed_target.kill();
      end
    join

    $display("normal=%0d,%0d finished=%0d", normal_time, normal_again,
             normal_target.status() == std::process::FINISHED);
    $display("forced=%0d,%0d killed=%0d", killed_time, killed_again,
             killed_target.status() == std::process::KILLED);
    $finish;
  end
  initial #40 $fatal(1, "await did not return");
endmodule

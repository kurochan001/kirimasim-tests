/*
:name: test_await_resumes_after_normal_and_forced_exit_then_rejects_self
:description: Await resumes for natural and forced termination, then reports an error for waiting on the calling process
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_await_resumes_after_normal_and_forced_exit_then_rejects_self.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*\bawait\b)(?=[^\n]*\b(?:self|own|current process)\b)[^\n]+
*/
`timescale 1ns/1ns
module test_await_resumes_after_normal_and_forced_exit_then_rejects_self;
  std::process normal_target, forced_target, caller;
  int normal_time, forced_time;

  initial begin
    caller = std::process::self();
    fork
      begin
        normal_target = std::process::self();
        #5;
      end
      begin
        forced_target = std::process::self();
        #20;
      end
    join_none

    #1;
    fork
      begin
        normal_target.await();
        normal_time = int'($time);
      end
      begin
        forced_target.await();
        forced_time = int'($time);
      end
      begin
        #6 forced_target.kill();
      end
    join
    $display("normal=%0d:%0d forced=%0d:%0d", normal_time,
             normal_target.status() == std::process::FINISHED, forced_time,
             forced_target.status() == std::process::KILLED);
    $display("calling await on self");
    caller.await();
  end

  initial #25 $finish(0);
endmodule

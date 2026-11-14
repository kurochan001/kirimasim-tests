/*
:name: test_queue_longest_wait_of_jobs_in_queue
:description: $q_exam with q_stat_code 5 returns the longest wait of the jobs that are still in the queue, leaving out a job that waited longer before it was removed, and it is the longest of them, not the wait of the job at the head of a last-in, first-out queue (IEEE 1800-2023 Section 20.15.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.15.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_longest_wait_of_jobs_in_queue.expected
*/
// IEEE 1800-2023 §20.15.5, Table 20-10: q_stat_code 5 asks $q_exam for the
// longest wait time of the jobs still in the queue. A job waits from its
// $q_add; a job still in the queue at the call has waited until that time.
// Table 20-9: queue type 1 is first-in, first-out and type 2 last-in,
// first-out, so $q_remove takes the oldest or the newest job.
//
// Queue 1 (type 1) gets job 1 at 0 ns, which $q_remove takes at 40 ns after
// a wait of 40 ns; jobs 2 and 3 arrive at 42 and 47 ns. At 50 ns they have
// waited 8 and 3 ns, so code 5 gives 8, not the 40 of the job that left.
// Queue 2 (type 2) gets jobs 4 and 5 at 0 and 10 ns; $q_remove at 20 ns takes
// job 5, and job 6 arrives at 30 ns. At 50 ns jobs 4 and 6 have waited 50 and
// 20 ns: code 5 gives 50, while job 6, the newest, is the one the next
// $q_remove would take. Code 1 gives the length of each queue at 50 ns.
// Icarus Verilog 13.0 prints the expected output; the queue tasks are not
// implemented in the 5.054 release of Verilator.

`timescale 1ns/1ns

module test_queue_longest_wait_of_jobs_in_queue;
  int status, job, inform, value;

  initial begin
    $q_initialize(1, 1, 10, status);
    $q_initialize(2, 2, 10, status);
    $q_add(1, 1, 10, status);
    $q_add(2, 4, 40, status);
    #10 $q_add(2, 5, 50, status);
    #10 begin
      $q_remove(2, job, inform, status);
      $display("t=%0t queue 2 removed job %0d", $time, job);
    end
    #10 $q_add(2, 6, 60, status);
    #10 begin
      $q_remove(1, job, inform, status);
      $display("t=%0t queue 1 removed job %0d", $time, job);
    end
    #2 $q_add(1, 2, 20, status);
    #5 $q_add(1, 3, 30, status);
    #3 begin
      $q_exam(1, 1, value, status);
      $display("t=%0t queue 1 length=%0d", $time, value);
      $q_exam(1, 5, value, status);
      $display("t=%0t queue 1 code 5 longest=%0d status=%0d", $time, value, status);
      $q_exam(2, 1, value, status);
      $display("t=%0t queue 2 length=%0d", $time, value);
      $q_exam(2, 5, value, status);
      $display("t=%0t queue 2 code 5 longest=%0d status=%0d", $time, value, status);
    end
  end
endmodule

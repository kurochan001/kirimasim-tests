/*
:name: test_queue_statistics_wait_codes
:description: $q_exam with q_stat_code 2 returns the mean interarrival time, with 4 the shortest wait time ever, with 5 the longest wait time of the jobs still in the queue and with 6 the average wait time in the queue, each with status 0 when the queue has the data (IEEE 1800-2023 Section 20.15.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.15.5 20.15.2 20.15.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_statistics_wait_codes.expected
*/
// IEEE 1800-2023 §20.15.5: $q_exam(q_id, q_stat_code, q_stat_value, status)
// returns in q_stat_value the information that Table 20-10 names for the code.
// Code 2 is the mean interarrival time, code 4 the shortest wait time ever,
// code 5 the longest wait time for the jobs still in the queue and code 6 the
// average wait time in the queue. A job waits from its $q_add to its $q_remove,
// and a job still in the queue at the call waits up to that time.
//
// Each queue makes one statistic unambiguous. Queue 1 receives a job at 0, 10
// and 20 ns, so the mean interarrival time is 10 ns when it is examined at
// 20 ns. Queue 2 has one job that waits 20 ns and one that waits 5 ns, so the
// shortest wait ever is 5 ns. Queue 3 still holds jobs added at 0 and 10 ns
// when it is examined at 30 ns, so the longest wait of those jobs is 30 ns.
// Queue 4 held one job that waited 5 ns, so the average wait of the queue is
// 5 ns whether the average counts the job or only the jobs still there.

`timescale 1ns/1ns

module test_queue_statistics_wait_codes;
  int status, job, inform, value;

  initial begin
    $q_initialize(1, 1, 10, status);
    $q_initialize(2, 1, 10, status);
    $q_initialize(3, 1, 10, status);
    $q_initialize(4, 1, 10, status);
    $q_add(1, 1, 1, status);
    $q_add(2, 1, 1, status);
    $q_add(3, 1, 1, status);
    $q_add(4, 1, 1, status);

    #5 $q_remove(4, job, inform, status);
    #5 begin
      $q_add(1, 2, 2, status);
      $q_add(3, 2, 2, status);
      $q_exam(4, 6, value, status);
      $display("t=%0t code 6 average=%0d status=%0d", $time, value, status);
      $q_exam(4, 1, value, status);
      $display("t=%0t queue 4 length=%0d", $time, value);
    end

    #10 begin
      $q_add(1, 3, 3, status);
      $q_exam(1, 2, value, status);
      $display("t=%0t code 2 mean=%0d status=%0d", $time, value, status);
      $q_remove(2, job, inform, status);
      $q_add(2, 2, 2, status);
    end

    #5 begin
      $q_remove(2, job, inform, status);
      $q_exam(2, 4, value, status);
      $display("t=%0t code 4 shortest=%0d status=%0d", $time, value, status);
      $q_exam(2, 1, value, status);
      $display("t=%0t queue 2 length=%0d", $time, value);
    end

    #5 begin
      $q_exam(3, 5, value, status);
      $display("t=%0t code 5 longest=%0d status=%0d", $time, value, status);
    end
  end
endmodule

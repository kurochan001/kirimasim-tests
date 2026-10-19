/*
:name: test_stochastic_queues
:description: $q_initialize creates FIFO and LIFO queues, $q_add and $q_remove add and take entries in that order, $q_full tells whether a queue is full, $q_exam reports its current and maximum length, and each call returns the status codes for full, empty, undefined, duplicate and invalid queues (IEEE 1800-2023 Section 20.15)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.15 20.15.1 20.15.2 20.15.3 20.15.4 20.15.5 20.15.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stochastic_queues.expected
*/
// IEEE 1800-2023 §20.15.1: $q_initialize(id, type, max_length, status) creates
// queue id, first-in first-out for type 1 and last-in first-out for type 2.
// §20.15.2 and §20.15.3: $q_add stores a job id and an inform id, which
// $q_remove returns. §20.15.4: $q_full returns 1 when the queue is full.
// §20.15.5: $q_exam with code 1 gives the current length and with code 3 the
// maximum length. §20.15.6: status 0 is OK, 1 queue full, 2 undefined queue,
// 3 queue empty, 4 unsupported type, 5 length not above 0, 6 duplicate id.
// The FIFO queue is filled up to its maximum of 3, so the maximum length is 3
// whether it means the most entries held or the limit.

module test_stochastic_queues;
  int status, job, inform, value, full;

  initial begin
    $q_initialize(1, 1, 3, status);
    $display("create FIFO 1: %0d", status);
    $q_initialize(1, 2, 3, status);
    $display("create 1 again: %0d", status);
    $q_initialize(2, 3, 3, status);
    $display("create with type 3: %0d", status);
    $q_initialize(3, 1, 0, status);
    $display("create with length 0: %0d", status);
    $q_initialize(4, 2, 5, status);
    $display("create LIFO 4: %0d", status);

    for (int i = 1; i <= 3; i++) begin
      #1 $q_add(1, i, 100 * i, status);
      $display("add job %0d to 1: %0d", i, status);
      $q_add(4, i, 10 * i, status);
    end
    full = $q_full(1, status);
    $display("1 full: %0d, status %0d", full, status);
    $q_add(1, 4, 400, status);
    $display("add job 4 to 1: %0d", status);
    $q_exam(1, 1, value, status);
    $display("length of 1: %0d, status %0d", value, status);
    $q_exam(1, 3, value, status);
    $display("maximum length of 1: %0d, status %0d", value, status);

    $q_remove(1, job, inform, status);
    $display("remove from 1: job %0d inform %0d, status %0d", job, inform, status);
    full = $q_full(1, status);
    $display("1 full: %0d, status %0d", full, status);
    $q_remove(4, job, inform, status);
    $display("remove from 4: job %0d inform %0d, status %0d", job, inform, status);
    $q_remove(4, job, inform, status);
    $display("remove from 4: job %0d inform %0d, status %0d", job, inform, status);
    $q_exam(4, 1, value, status);
    $display("length of 4: %0d, status %0d", value, status);
    $q_remove(4, job, inform, status);
    $q_remove(4, job, inform, status);
    $display("remove from empty 4: %0d", status);
    $q_add(9, 1, 1, status);
    $display("add to undefined 9: %0d", status);
  end
endmodule

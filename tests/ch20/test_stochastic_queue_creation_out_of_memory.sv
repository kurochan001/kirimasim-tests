/*
:name: test_stochastic_queue_creation_out_of_memory
:description: A failed queue allocation reports status and leaves the ID available
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.15.6 20.15.1 20.15.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stochastic_queue_creation_out_of_memory.expected
*/
module test_stochastic_queue_creation_out_of_memory;
  int status, length, job, information;

  initial begin
    $q_initialize(99, 1, 3, status);
    $display("existing create=%0d", status);
    $q_add(99, 71, 83, status);
    $display("existing add=%0d", status);

    // The qualified trial fails one allocation during this creation.
    $q_initialize(17, 1, 257, status);
    $display("target create=%0d", status);
    $q_exam(17, 1, length, status);
    $display("target lookup=%0d", status);
    $q_initialize(17, 1, 1, status);
    $display("target retry=%0d", status);
    $q_exam(17, 1, length, status);
    $display("target after retry length=%0d status=%0d", length, status);

    $q_remove(99, job, information, status);
    $display("existing job=%0d,%0d status=%0d", job, information, status);
    $finish(0);
  end
endmodule

/*
:name: test_stochastic_queue_capacity_one_reuse
:description: A capacity one stochastic queue can be filled removed and reused while preserving job information and full status (IEEE 1800-2023 Section 20.15.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.15.1 20.15.2 20.15.3 20.15.4 20.15.5 20.15.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stochastic_queue_capacity_one_reuse.expected
*/
// IEEE 1800-2023 20.15.1 20.15.2 20.15.3 20.15.4 20.15.5 20.15.6: The boundary
// at one item makes the full and empty transitions observable; an overfill must
// preserve the previously stored entry.
// Oracle checks: The 5.052 release does not build this case.

module test_stochastic_queue_capacity_one_reuse;
  int status, full, length, job, info;
  initial begin
    $q_initialize(27, 1, 1, status);
    $display("create=%0d", status);
    $q_add(27, 11, 111, status);
    full = $q_full(27, status);
    $display("full=%0d status=%0d", full, status);
    $q_add(27, 22, 222, status);
    $display("overfill=%0d", status);
    $q_remove(27, job, info, status);
    $display("removed=%0d,%0d status=%0d", job, info, status);
    $q_add(27, 33, 333, status);
    $q_exam(27, 1, length, status);
    $display("reused_length=%0d status=%0d", length, status);
    $q_remove(27, job, info, status);
    $display("reused_entry=%0d,%0d", job, info);
    $q_remove(27, job, info, status);
    $display("empty_status=%0d", status);
  end
endmodule

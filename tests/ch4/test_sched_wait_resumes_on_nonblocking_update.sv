/*
:name: test_sched_wait_resumes_on_nonblocking_update
:description: A wait statement whose condition a nonblocking update makes true resumes in that time step (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.4.3 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_wait_resumes_on_nonblocking_update.expected
*/
// IEEE 1800-2023 §9.4.3: wait blocks until its condition is true. The condition
// becomes true when the NBA region (§4.4.2.4) of time 0 updates ready, and the
// waiting process resumes in that time step and sees the updated value.

`timescale 1ns/1ns

module test_sched_wait_resumes_on_nonblocking_update;
  bit ready = 0;
  initial begin
    fork
      begin
        wait (ready);
        $display("resumed at %0t: ready=%0d", $time, ready);
      end
    join_none
    #0;
    ready <= 1;
  end
endmodule

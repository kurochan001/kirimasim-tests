/*
:name: test_sched_nba_update_wakes_forked_waiter
:description: A process waiting for a change of a variable resumes in the time step of the nonblocking update that changes it and sees the new value (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.4.2 9.3.2 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nba_update_wakes_forked_waiter.expected
*/
// IEEE 1800-2023 §9.3.2: the process forked with join_none starts when its
// parent blocks, and waits for x (§9.4.2). The parent's nonblocking assignment
// changes x in the NBA region (§4.4.2.4) of time 0, which wakes the waiting
// process in that time step, with the new value.

`timescale 1ns/1ns

module test_sched_nba_update_wakes_forked_waiter;
  int x = 0;
  initial begin
    fork
      begin
        @(x);
        $display("woke at %0t: x=%0d", $time, x);
      end
    join_none
    #0;
    x <= 5;
    #2 $display("done at %0t", $time);
  end
endmodule

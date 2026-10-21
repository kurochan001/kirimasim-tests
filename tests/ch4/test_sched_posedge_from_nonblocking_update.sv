/*
:name: test_sched_posedge_from_nonblocking_update
:description: A rising edge made by a nonblocking update wakes a process waiting for posedge in the same time step, and the falling edge does not (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.4.2 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_posedge_from_nonblocking_update.expected
*/
// IEEE 1800-2023 §9.4.2: posedge waits for a change of the variable from 0 to
// 1. The nonblocking update at time 0 makes that edge and wakes the waiting
// process in the NBA region of time 0 (§4.4.2.4); the change back to 0 at time
// 1 is a negative edge, for which only the second waiter wakes.

`timescale 1ns/1ns

module test_sched_posedge_from_nonblocking_update;
  bit clk = 0;
  initial begin
    fork
      begin
        @(posedge clk);
        $display("posedge at %0t", $time);
      end
    join_none
    fork
      begin
        @(negedge clk);
        $display("negedge at %0t", $time);
      end
    join_none
    #0;
    clk <= 1;
    #1 clk <= 0;
  end
endmodule

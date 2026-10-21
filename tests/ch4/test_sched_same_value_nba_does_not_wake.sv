/*
:name: test_sched_same_value_nba_does_not_wake
:description: A nonblocking assignment of the value a variable holds is no change and wakes no process waiting for the variable (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 9.4.2 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_same_value_nba_does_not_wake.expected
*/
// IEEE 1800-2023 §9.4.2: an event control on a variable waits for a change of
// its value. The nonblocking write of 3 at time 0 gives x the value it has,
// which is no change, so the waiting process wakes only at time 1, when x
// becomes 4.

`timescale 1ns/1ns

module test_sched_same_value_nba_does_not_wake;
  int x = 3;
  initial begin
    fork
      begin
        @(x);
        $display("woke at %0t: x=%0d", $time, x);
      end
    join_none
    #0;
    x <= 3;
    #1 x <= 4;
  end
endmodule

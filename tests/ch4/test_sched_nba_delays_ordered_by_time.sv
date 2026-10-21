/*
:name: test_sched_nba_delays_ordered_by_time
:description: Nonblocking assignments with intra-assignment delays update their variable at their own times, the shorter delay first (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 10.4.2 9.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nba_delays_ordered_by_time.expected
*/
// IEEE 1800-2023 §10.4.2 and §9.4.5: a nonblocking assignment with an
// intra-assignment delay evaluates its right-hand side at once and updates the
// variable in the NBA region of the time the delay ends. The write with delay 2
// is made first and the one with delay 1 second; x is 2 at time 1 and 1 at time
// 2.

`timescale 1ns/1ns

module test_sched_nba_delays_ordered_by_time;
  int x = 0;
  initial begin
    x <= #2 1;
    x <= #1 2;
    #1 $strobe("%0t: x=%0d", $time, x);
    #1 $strobe("%0t: x=%0d", $time, x);
  end
endmodule

/*
:name: test_sched_nba_delays_same_time_keep_order
:description: Nonblocking assignments to one variable whose delays end at the same time update it in the order they ran (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 10.4.2 9.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nba_delays_same_time_keep_order.expected
*/
// IEEE 1800-2023 §10.4.2: the order in which distinct nonblocking assignments
// to a variable run is kept when they update it, also when intra-assignment
// delays (§9.4.5) bring the updates to the same time step. Both delays end at
// 2, so x takes 7 and then 8.

`timescale 1ns/1ns

module test_sched_nba_delays_same_time_keep_order;
  int x = 0;
  initial begin
    x <= #2 7;
    #1 x <= #1 8;
    #1 $strobe("%0t: x=%0d", $time, x);
  end
endmodule

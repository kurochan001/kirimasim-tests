/*
:name: test_vpi_future_success_callback_time
:description: A nonvacuous future sampled assertion success callback runs at the next global tick while retaining its original event time (IEEE 1800-2023 Section 39.4.2.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2.1 39.4.2 16.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_future_success_callback_time.c
:expected_stdout: @test_vpi_future_success_callback_time.expected
*/
// IEEE 1800-2023 39.4.2.1 39.4.2 16.9.4: The assertion succeeds at time fifteen
// but its callback executes at time eighteen, the first strictly later global
// posedge; this complements the earlier kill-callback test.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

`timescale 1ns/1ns
module test_vpi_future_success_callback_time;
  bit clk, global_clk, enabled = 1;
  always #5 clk = ~clk;
  always #2 global_clk = ~global_clk;
  global clocking g @(posedge global_clk); endclocking
  a1: assert property (@(posedge clk) enabled |=> $future_gclk(1'b1));
  initial begin
    $depth_success_watch;
    #10 enabled = 0;
    #10 $depth_success_report;
    $finish;
  end
endmodule

/*
:name: test_vpi_assertion_kill_reset
:description: vpiAssertionKill discards the one attempt that started at the given time and vpiAssertionReset discards all attempts of an assertion, which stays enabled, and the kill and reset callbacks get no attempt information (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2 39.4.2 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_kill_reset.c
:expected_stdout: @test_vpi_assertion_kill_reset.expected
*/
// IEEE 1800-2023 §39.5.2: a1 needs b three ticks after a. The attempts that
// start at 5 and 15 would pass at 35 and 45; at 20, $vt_kill(5) calls
// vpi_control(vpiAssertionKill) with the start time 5, which discards only that
// attempt. The attempts that start at 65 and 75 would pass at 95 and 105; at
// 80, $vt_reset calls vpi_control(vpiAssertionReset), which discards both. The
// assertion stays enabled: the attempt that starts at 125 fails at 155.
// §39.4.2: the application records cbAssertionSuccess, cbAssertionFailure,
// cbAssertionKill and cbAssertionReset. Success is only nonvacuous (16.12.7),
// so the ticks where a is 0 give no callback. Kill and reset callbacks get a
// NULL attempt information pointer; their cb_time is the time of the kill or
// reset. The kill callback is removed before the reset, because a reset could
// also report its discarded attempts as killed.

`timescale 1ns/1ns

module test_vpi_assertion_kill_reset;
  logic clk = 0, a = 0, b = 0;
  int fails = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a |-> ##3 b) else fails++;

  initial begin
    $vt_watch;
    a = 1;          // attempts at 5 and 15
    #20 a = 0;
    $vt_kill(5);
    #10 b = 1;      // b at 35 and 45
    #20 b = 0;
    #10 a = 1;      // attempts at 65 and 75
    #20 a = 0;
    $vt_reset;
    #10 b = 1;      // b at 95 and 105
    #20 b = 0;
    #10 a = 1;      // attempt at 125, b is 0 at 155
    #10 a = 0;
    #40 $vt_report;
    $display("fail actions: %0d", fails);
    $finish;
  end
endmodule

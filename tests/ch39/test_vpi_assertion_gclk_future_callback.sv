/*
:name: test_vpi_assertion_gclk_future_callback
:description: A callback for an assertion that uses a global clocking future sampled value function runs at the next tick of the global clock after the event, while cb_time gives the time of the event (IEEE 1800-2023 Section 39.4.2.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2.1 39.4.2 16.9.4 20.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_gclk_future_callback.c
:expected_stdout: @test_vpi_assertion_gclk_future_callback.expected
*/
// IEEE 1800-2023 §39.4.2.1: for an assertion that refers to a global clocking
// future sampled value function (16.9.4), such as $rising_gclk, a callback runs
// at the nearest tick of the global clock strictly after the callback event,
// and cb_time holds the time of the event. The global clock rises at 1, 3, 5
// and so on. The attempt of a1 that starts at 5 waits for the tick at 15;
// $assertkill (20.11) at 11 kills it, so the cbAssertionKill callback (39.4.2)
// runs at 13, with cb_time 11.

`timescale 1ns/1ns

module test_vpi_assertion_gclk_future_callback;
  logic clk = 0, gclk = 0, a = 0, b = 0;

  always #5 clk = ~clk;
  always #1 gclk = ~gclk;

  global clocking g @(posedge gclk);
  endclocking

  a1: assert property (@(posedge clk) a |=> $rising_gclk(b));

  initial begin
    $vt_watch;
    a = 1;
    #11 $assertkill(0, a1);
    a = 0;
    #20 $vt_report;
    $finish;
  end
endmodule

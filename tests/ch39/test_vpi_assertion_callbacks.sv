/*
:name: test_vpi_assertion_callbacks
:description: vpi_register_assertion_cb reports the start, nonvacuous success, vacuous success, failure and disabled evaluation of assertion attempts, with the callback time and the attempt's start time (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 16.12 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_callbacks.c
:expected_stdout: @test_vpi_assertion_callbacks.expected
*/
// IEEE 1800-2023 §39.4.2: at time 0, $vt_watch places callbacks with
// vpi_register_assertion_cb: cbAssertionStart, cbAssertionSuccess and
// cbAssertionFailure on a1, cbAssertionSuccess, cbAssertionVacuousSuccess and
// cbAssertionFailure on a2, and cbAssertionDisabledEvaluation,
// cbAssertionSuccess and cbAssertionVacuousSuccess on a3. An attempt starts at
// every clock tick (5, 15, 25 and 35). cbAssertionSuccess is for nonvacuous
// success; an implication whose antecedent does not match succeeds vacuously
// (16.12.7). a3 starts at 25 while its disable iff condition is true, so that
// attempt reaches the disabled state (16.12). cb_time is the time of the
// event, and for start, success and failure attemptStartTime is the start of
// the attempt. Several callbacks can come in one time step in any order, so the
// application records them and $vt_report prints them sorted. Each assertion
// has a fail action, so a failure prints nothing by itself (16.14.1); fails
// counts the failures of a1 and a2.

`timescale 1ns/1ns

module test_vpi_assertion_callbacks;
  logic clk = 0, a = 0, b = 0, rst = 0;
  int fails = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##1 b) else fails++;
  a2: assert property (@(posedge clk) a |-> b) else fails++;
  a3: assert property (@(posedge clk) disable iff (rst) a |=> b) else fails++;

  initial begin
    $vt_watch;
    a = 1; b = 0; rst = 0;   // tick 5
    #10 a = 0; b = 1;        // tick 15
    #10 a = 1; rst = 1;      // tick 25
    #10 a = 0; b = 0; rst = 0; // tick 35
    #10 $vt_report;
    $display("fail actions: %0d", fails);
    $finish;
  end
endmodule

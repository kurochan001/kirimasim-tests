/*
:name: test_vpi_assertion_callback_time_and_attempt_info
:description: For every kind of assertion callback, cb_time is the time of the event it reports, the start, success, failure and step callbacks get the start of their attempt, the failure also its failing expression and the step its step information, and a step failure callback comes only for the attempt whose stepping is enabled (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_callback_time_and_attempt_info.c
:expected_stdout: @test_vpi_assertion_callback_time_and_attempt_info.expected
*/
// IEEE 1800-2023 §39.4.2: cb_time is the time when the attempt started for
// cbAssertionStart, when it succeeded nonvacuously or failed for
// cbAssertionSuccess and cbAssertionFailure, when it succeeded vacuously or
// reached the disabled state for cbAssertionVacuousSuccess and
// cbAssertionDisabledEvaluation, when the step succeeded or failed for the
// step callbacks, and when the assertion or attempt was disabled, enabled,
// reset or killed for cbAssertionDisable, cbAssertionEnable, cbAssertionReset
// and cbAssertionKill. The attempt information of start and success callbacks
// has a valid attemptStartTime, that of a failure also detail.failExpr, and
// that of a step also detail.step. A step callback placed for one reason is
// also called for the steps of the other kind.
// The clock rises at 5, 15, 25 and so on; a1 needs a and then b one tick later.
// At 1, $vt_watch places these callbacks: on a1 the start, success, failure,
// step failure (also called for the steps that succeed), kill, reset, disable
// and enable callbacks, and on a2, whose disable iff condition is rst, the
// vacuous success and disabled evaluation callbacks. a1: the attempt of 5
// passes at 15; that of 15 fails at once (a is 0); stepping is enabled at 20
// for the attempt of 25, which steps at 25 (a holds) and fails its step and the
// attempt at 35 (b is 0), while the failures of the other attempts give no step
// callback; $vt_kill(35) at 40 kills the attempt of 35, which would pass at 45;
// that of 45 fails at once; $vt_control resets a1 at 50, with no attempt
// running, disables it at 52 and enables it at 60, so no attempt starts at 55
// and one starts at 65. a2 succeeds vacuously at 5 and starts at 15 while rst
// is 1. The other attempts of a2 pass nonvacuously, which is not watched. Each
// callback records cb_time and, for start, success, failure and step callbacks,
// the attempt start time and whether the failing expression or the step
// information is there. They are printed at the end, sorted, each distinct line
// once. No simulator here runs the application: the expected output is derived
// from §39.4.2.

`timescale 1ns/1ns

module test_vpi_assertion_callback_time_and_attempt_info;
  logic clk = 0, a = 0, b = 0, p = 0, q = 1, rst = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##1 b) else ;
  a2: assert property (@(posedge clk) disable iff (rst) p |-> q) else ;

  initial begin
    a = 1; b = 0; p = 0;                  // sampled at 5
    #1 $vt_watch;                         // 1
    #9 a = 0; b = 1; p = 1; rst = 1;      // 10, sampled at 15
    #10 a = 1; b = 0; rst = 0;            // 20, sampled at 25
    $vt_step(25);
    #10 a = 1; b = 0;                     // 30, sampled at 35
    #10 a = 0; b = 1;                     // 40, sampled at 45
    $vt_kill(35);
    #10 a = 1;                            // 50, sampled at 55 and 65
    $vt_control("reset");
    #2 $vt_control("disable");            // 52
    #8 $vt_control("enable");             // 60
    #10 $vt_report;                       // 70
    $finish;
  end
endmodule

/*
:name: test_vpi_assertion_system_lock_reset
:description: While the assertion system is locked a control cannot disable an assertion, after unlocking it can, and a system reset discards the attempts in progress but keeps the assertion callbacks (IEEE 1800-2023 Section 39.5.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1 39.5.2 39.4.1 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_system_lock_reset.c
:expected_stdout: @test_vpi_assertion_system_lock_reset.expected
*/
// IEEE 1800-2023 §39.5.1: vpiAssertionSysLock keeps the status of the
// assertions from being changed until vpiAssertionSysUnlock, and
// vpiAssertionSysReset discards every attempt in progress and returns the
// assertion system to its initial state, keeping the assertion callbacks
// other than step callbacks. §39.4.1: cbAssertionSysLock, cbAssertionSysUnlock
// and cbAssertionSysReset report these. a1 needs b two ticks after a; ticks
// are at 5, 15, 25 and so on. vpiAssertionDisable (39.5.2) at 3, under the
// lock, has no effect, so the attempt at 5 passes at 25; at 31, after the
// unlock, it stops the attempt at 35. The assertion is enabled again at 40,
// and the reset at 50 discards the attempt of 45, which b at 65 would pass;
// the attempt at 75 fails at 95 and its failure callback is still there.

`timescale 1ns/1ns

module test_vpi_assertion_system_lock_reset;
  logic clk = 0, a = 0, b = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a |-> ##2 b);

  initial begin
    $vt_watch;
    #2 $vt_control("lock");
    #1 $vt_control("disable");
    a = 1;               // sampled at 5
    #5 a = 0;
    #15 b = 1;           // sampled at 25
    #5 b = 0;
    #2 $vt_control("unlock");
    #1 $vt_control("disable");
    #2 a = 1;            // at 33, sampled at 35
    #5 a = 0;
    #2 $vt_control("enable");
    #3 a = 1;            // at 43, sampled at 45
    #5 a = 0;
    #2 $vt_control("reset");
    #13 b = 1;           // at 63, sampled at 65
    #5 b = 0;
    #5 a = 1;            // at 73, sampled at 75; b is 0 at 95
    #5 a = 0;
    #22 $vt_report;
    $finish;
  end
endmodule

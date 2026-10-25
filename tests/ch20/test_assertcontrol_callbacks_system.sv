/*
:name: test_assertcontrol_callbacks_system
:description: $assertcontrol with control types 1 to 11 and the control and action tasks, called without a list of scopes or assertions, report cbAssertionSysLock, SysUnlock, SysOff, SysOn, SysKill, SysDisablePassAction, SysEnablePassAction, SysDisableFailAction, SysEnableFailAction, SysDisableVacuousAction and SysEnableNonvacuousAction, and control types 6 to 11 leave the assertion coverage counters alone (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 39.4.1 40.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_assertcontrol_callbacks_system.c
:expected_stdout: @test_assertcontrol_callbacks_system.expected
*/
// IEEE 1800-2023 §20.11, Table 20-8: without a list of scopes or assertions
// the control types and the control and action tasks map to the assertion
// system callbacks of §39.4.1: 1 Lock to cbAssertionSysLock, 2 Unlock to
// cbAssertionSysUnlock, 3 On to cbAssertionSysOn, 4 Off to cbAssertionSysOff,
// 5 Kill to cbAssertionSysKill, 6 PassOn to cbAssertionSysEnablePassAction,
// 7 PassOff to cbAssertionSysDisablePassAction, 8 FailOn to
// cbAssertionSysEnableFailAction, 9 FailOff to cbAssertionSysDisableFailAction,
// 10 NonvacuousOn to cbAssertionSysEnableNonvacuousAction and 11 VacuousOff to
// cbAssertionSysDisableVacuousAction. $asserton, $assertoff and $assertkill map
// as 3, 4 and 5, and the six action tasks as 6 to 11. Control types 6 to 11
// do not affect the assertion statistics counters. §40.5.2: the counters are
// the attempts, nonvacuous successes, vacuous successes and failures of an
// assertion, which the application reads with vpi_get.
// The clock ticks at 5, 15, 25, ... The counters are read around two phases of
// three ticks of a_cnt, s |-> t: a nonvacuous success, a vacuous success (s is
// 0) and a failure. Between the phases the application calls 7, 9 and 11, and
// after the second phase 6, 8 and 10; every reading shows that the counters
// have not changed except by the attempts. The callbacks are printed only
// after $vt_begin, and each control is called one time unit after the one
// before it. Each control follows a state that it changes, so a callback that
// reports the change has to come: Off follows the running system, On follows
// Off, Kill follows On, Unlock follows Lock, and each action control follows
// the opposite one.
// No simulator here runs the application: Icarus Verilog 13.0 has no
// concurrent assertions, and release 5.052 of the Verilator tool implements
// neither $coverage_control nor these assertion system callbacks.

`timescale 1ns/1ns

module test_assertcontrol_callbacks_system;
  logic clk = 0, s = 1, t = 1;
  int a_fail = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a1: assert property (@(posedge clk) 1'b0) else a_fail++;
  a_cnt: assert property (@(posedge clk) s |-> t) else ;

  initial begin
    // The counters exist only where assertion coverage is collected (40.5.2).
    $coverage_control(`SV_COV_START, `SV_COV_ASSERTION, `SV_COV_HIER,
                      test_assertcontrol_callbacks_system);
    $vt_watch;
    #1 $vt_counters("before");            // 1
    #5 s = 0;                             // 6
    #10 s = 1; t = 0;                     // 16
    #10 $vt_counters("after phase 1");    // 26
    #1 $assertcontrol(7);                 // 27
    $vt_counters("after control 7");      // 27
    #1 $assertcontrol(9);                 // 28
    $vt_counters("after control 9");      // 28
    #1 $assertcontrol(11);                // 29
    $vt_counters("after control 11");     // 29
    #1 s = 1; t = 1;                      // 30
    #6 s = 0;                             // 36
    #10 s = 1; t = 0;                     // 46
    #10 $vt_counters("after phase 2");    // 56
    #1 $assertcontrol(6);                 // 57
    $vt_counters("after control 6");      // 57
    #1 $assertcontrol(8);                 // 58
    $vt_counters("after control 8");      // 58
    #1 $assertcontrol(10);                // 59
    $vt_counters("after control 10");     // 59
    #1 $vt_begin;                         // 60

    #1 $assertcontrol(1);                 // 61: Lock
    #1 $assertcontrol(2);                 // 62: Unlock
    #1 $assertcontrol(4);                 // 63: Off
    #1 $assertcontrol(3);                 // 64: On
    #1 $assertcontrol(5);                 // 65: Kill
    #1 $assertcontrol(3);                 // 66: On
    #1 $assertcontrol(7);                 // 67: PassOff
    #1 $assertcontrol(6);                 // 68: PassOn
    #1 $assertcontrol(9);                 // 69: FailOff
    #1 $assertcontrol(8);                 // 70: FailOn
    #1 $assertcontrol(11);                // 71: VacuousOff
    #1 $assertcontrol(7);                 // 72: PassOff
    #1 $assertcontrol(10);                // 73: NonvacuousOn
    #1 $assertcontrol(6);                 // 74: PassOn
    #1 $assertoff;                        // 75
    #1 $asserton;                         // 76
    #1 $assertkill;                       // 77
    #1 $asserton;                         // 78
    #1 $assertpassoff;                    // 79
    #1 $assertpasson;                     // 80
    #1 $assertfailoff;                    // 81
    #1 $assertfailon;                     // 82
    #1 $assertvacuousoff;                 // 83
    #1 $assertpassoff;                    // 84
    #1 $assertnonvacuouson;               // 85
    #1 $assertpasson;                     // 86
    $finish;
  end
endmodule

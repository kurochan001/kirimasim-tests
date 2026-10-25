/*
:name: test_assertcontrol_callbacks_selected
:description: $assertcontrol with control types 1 to 11 and the action tasks, called with a levels argument and a list that names one assertion, report cbAssertionLock, Unlock, Enable, Disable, Reset and Disable, DisablePassAction, EnablePassAction, DisableFailAction, EnableFailAction, DisableVacuousAction and EnableNonvacuousAction on that assertion and on no other (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_assertcontrol_callbacks_selected.c
:expected_stdout: @test_assertcontrol_callbacks_selected.expected
*/
// IEEE 1800-2023 §20.11, Table 20-8: with a list of scopes or assertions the
// control types and the action tasks map to the assertion callbacks of
// §39.4.2 on the selected assertions: 1 Lock to cbAssertionLock, 2 Unlock to
// cbAssertionUnlock, 3 On to cbAssertionEnable, 4 Off to cbAssertionDisable,
// 5 Kill to cbAssertionReset and cbAssertionDisable, 6 PassOn to
// cbAssertionEnablePassAction, 7 PassOff to cbAssertionDisablePassAction,
// 8 FailOn to cbAssertionEnableFailAction, 9 FailOff to
// cbAssertionDisableFailAction, 10 NonvacuousOn to
// cbAssertionEnableNonvacuousAction and 11 VacuousOff to
// cbAssertionDisableVacuousAction. $assertfailoff, $assertfailon, $assertkill,
// $assertnonvacuouson, $assertpassoff, $assertpasson and $assertvacuousoff
// map to the same reasons as 9, 8, 5, 10, 7, 6 and 11.
// The clock ticks at 5, 15, 25, ...; a1 and a2 both fail at each tick and have
// a fail action, so a failure prints nothing (16.14.1). The application places
// a callback for each reason of 39.4.2 on both assertions before the controls
// start. Every control names only a1, so a2 must get no callback; the
// application prints a count of callbacks whose handle is neither. Each
// control follows a state that it changes, so the callback has to come. Kill
// gives two callbacks in one time step, whose order §20.11 does not fix, so
// the application records them and prints them sorted by time, assertion and
// reason.
// No simulator here runs the application: Icarus Verilog 13.0 has no
// concurrent assertions, and release 5.052 of the Verilator tool cannot call
// the $vt_... tasks and does not report these assertion callbacks.

`timescale 1ns/1ns

module test_assertcontrol_callbacks_selected;
  logic clk = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a1: assert property (@(posedge clk) 1'b0) else ;
  a2: assert property (@(posedge clk) 1'b0) else ;

  initial begin
    $vt_watch;                           // place the callbacks on a1 and a2
    #1 $vt_begin;                        // 1: print the callbacks from here
    #1 $assertcontrol(1, 1, 1, 0, a1);   // 2: Lock
    #1 $assertcontrol(2, 1, 1, 0, a1);   // 3: Unlock
    #1 $assertcontrol(4, 1, 1, 0, a1);   // 4: Off
    #1 $assertcontrol(3, 1, 1, 0, a1);   // 5: On
    #1 $assertcontrol(5, 1, 1, 0, a1);   // 6: Kill
    #1 $assertcontrol(3, 1, 1, 0, a1);   // 7: On
    #1 $assertcontrol(7, 1, 1, 0, a1);   // 8: PassOff
    #1 $assertcontrol(6, 1, 1, 0, a1);   // 9: PassOn
    #1 $assertcontrol(9, 1, 1, 0, a1);   // 10: FailOff
    #1 $assertcontrol(8, 1, 1, 0, a1);   // 11: FailOn
    #1 $assertcontrol(11, 1, 1, 0, a1);  // 12: VacuousOff
    #1 $assertcontrol(7, 1, 1, 0, a1);   // 13: PassOff
    #1 $assertcontrol(10, 1, 1, 0, a1);  // 14: NonvacuousOn
    #1 $assertcontrol(6, 1, 1, 0, a1);   // 15: PassOn
    #1 $assertfailoff(0, a1);            // 16
    #1 $assertfailon(0, a1);             // 17
    #1 $assertkill(0, a1);               // 18
    #1 $assertcontrol(3, 1, 1, 0, a1);   // 19: On
    #1 $assertpassoff(0, a1);            // 20
    #1 $assertpasson(0, a1);             // 21
    #1 $assertvacuousoff(0, a1);         // 22
    #1 $assertpassoff(0, a1);            // 23
    #1 $assertnonvacuouson(0, a1);       // 24
    #1 $assertpasson(0, a1);             // 25
    $vt_report;
    $finish;
  end
endmodule

/*
:name: test_vpi_assertion_system_control
:description: vpi_control turns the whole assertion system off, kills it, turns it on, disables and enables pass and fail actions and ends it, and the assertion system callbacks report each change (IEEE 1800-2023 Sections 39.5.1 and 39.4.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1 39.4.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_system_control.c
:expected_stdout: @test_vpi_assertion_system_control.expected
*/
// IEEE 1800-2023 §39.5.1: $vt_system calls vpi_control with a system control
// and a NULL scope, which means every assertion. Each phase has three clock
// ticks. The attempt started at the first tick needs b two ticks later and
// passes; the attempts at the second and third ticks fail at once because a is
// 0. vpiAssertionSysOff in the middle of a phase stops new attempts but lets
// the running attempt pass; vpiAssertionSysKill also discards it.
// vpiAssertionSysOn starts the system again. vpiAssertionSysDisableFailAction
// and vpiAssertionSysDisablePassAction stop the fail and pass actions.
// vpiAssertionSysEnd discards all attempts and stops all assertion activity, so
// vpiAssertionSysOn after it has no effect. §39.4.1: callbacks placed with
// vpi_register_cb for the assertion system reasons report these changes; the
// application prints them only after the first control, because the system can
// also start at the beginning of the simulation. cbAssertionSysInitialized is
// called once.

`timescale 1ns/1ns

module test_vpi_assertion_system_control;
  logic clk = 0, a = 0, b = 0;
  int p = 0, f = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##2 b) p++; else f++;

  task automatic three_ticks(string phase, string middle);
    a = 1; b = 0;
    #10 a = 0;
    if (middle != "") $vt_system(middle);
    #10 b = 1;
    #10 $display("%0d: %s: pass %0d fail %0d", $time, phase, p, f);
    p = 0; f = 0;
  endtask

  initial begin
    three_ticks("all on", "");
    three_ticks("off in the middle", "off");
    $vt_system("on");
    three_ticks("kill in the middle", "kill");
    $vt_system("on");
    $vt_system("disable fail action");
    three_ticks("fail action disabled", "");
    $vt_system("enable fail action");
    $vt_system("disable pass action");
    three_ticks("pass action disabled", "");
    $vt_system("enable pass action");
    $vt_system("end");
    three_ticks("on after end", "on");
    $vt_report;
    $finish;
  end
endmodule

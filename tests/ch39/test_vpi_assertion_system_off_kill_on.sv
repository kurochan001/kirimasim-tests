/*
:name: test_vpi_assertion_system_off_kill_on
:description: vpiAssertionSysOff stops new attempts but lets the running one end, vpiAssertionSysKill also discards the running one, vpiAssertionSysOn starts the attempts of every assertion again, both stops can be repeated, the assertion callbacks placed before them keep working, and the system callbacks report each change (IEEE 1800-2023 Sections 39.5.1 and 39.4.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1 39.4.1 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_system_off_kill_on.c
:expected_stdout: @test_vpi_assertion_system_off_kill_on.expected
*/
// IEEE 1800-2023 §39.5.1: $vt_system calls vpi_control with a system control
// and a NULL scope, which acts on every assertion, here a1 in the top module
// and a2 in the instance u. vpiAssertionSysOff stops the start of new attempts
// and leaves running attempts alone; vpiAssertionSysKill also discards the
// running attempts; vpiAssertionSysOn starts the attempts again. None of them
// changes the assertion callbacks placed before. §39.4.1: cbAssertionSysOff,
// cbAssertionSysKill and cbAssertionSysOn report the changes, and the system
// can be stopped and started again any number of times; while it is killed no
// attempt runs and no assertion callback comes.
// Both assertions need b two ticks after a; the clock rises at 5, 15, 25 and
// so on. An attempt where a is 0 succeeds vacuously and runs its pass action
// (16.12.7, 16.14.1). The attempt of 5 succeeds at 25 although the system is
// off from 10 to 30, where no attempt starts. The attempts of 35 and 65 would
// succeed at 55 and 85, but the kills at 40 and 80 discard them. The pass
// counts are printed at fixed times. $vt_watch places cbAssertionStart on both
// assertions at 1, and, with vpi_register_cb, the system callbacks
// cbAssertionSysOff, cbAssertionSysKill and cbAssertionSysOn, which a startup
// routine may not place (36.10.2). The application records the start times of
// the attempts and the system callbacks that follow the first control and
// prints them, sorted, at the end. No simulator here runs the application: the
// expected output is derived from §39.5.1 and §39.4.1.

`timescale 1ns/1ns

module sk_leaf(input logic clk, input logic a, input logic b, output int passes,
               output int fails);
  initial begin
    passes = 0;
    fails = 0;
  end
  a2: assert property (@(posedge clk) a |-> ##2 b) passes++; else fails++;
endmodule

module test_vpi_assertion_system_off_kill_on;
  logic clk = 0, a = 0, b = 0;
  int p1 = 0, f1 = 0, p2, f2;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a |-> ##2 b) p1++; else f1++;

  sk_leaf u(.clk(clk), .a(a), .b(b), .passes(p2), .fails(f2));

  task automatic show(string phase);
    $display("%0d: after %s: a1 pass %0d fail %0d, u.a2 pass %0d fail %0d", $time, phase,
             p1, f1, p2, f2);
  endtask

  initial begin
    a = 1;                     // sampled at 5
    #1 $vt_watch;              // 1
    #9 a = 0;                  // 10
    $vt_system("off");
    #10 b = 1;                 // 20, sampled at 25
    #10 b = 0;                 // 30
    show("off");
    $vt_system("on");
    a = 1;                     // sampled at 35
    #10 a = 0;                 // 40
    show("on");
    $vt_system("kill");
    #10 b = 1;                 // 50, sampled at 55
    #10 b = 0;                 // 60
    show("kill");
    $vt_system("on");
    a = 1;                     // sampled at 65
    #10 a = 0;                 // 70
    #10 show("second on");     // 80
    $vt_system("kill");
    b = 1;                     // sampled at 85
    #10 b = 0;                 // 90
    show("second kill");
    $vt_system("on");
    a = 1;                     // sampled at 95
    #10 a = 0;                 // 100
    #10 b = 1;                 // 110, sampled at 115
    #10 b = 0;                 // 120
    show("third on");
    $vt_report;
    $finish;
  end
endmodule

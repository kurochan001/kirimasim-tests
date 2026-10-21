/*
:name: test_vpi_assertion_system_task_control
:description: The assertion control tasks $assertoff, $asserton and $assertkill stop and restart checking and discard attempts in progress, and the assertion callbacks report the disable, enable and kill with no attempt information (IEEE 1800-2023 Sections 20.11 and 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 20.11 39.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_system_task_control.c
:expected_stdout: @test_vpi_assertion_system_task_control.expected
*/
// IEEE 1800-2023 §20.11: $assertoff stops the checking of the named assertion,
// so no new attempts start, while attempts already executing finish;
// $asserton starts checking again; $assertkill aborts the attempts in progress
// and then stops checking until the next $asserton. §39.4.2: the callbacks
// cbAssertionDisable, cbAssertionEnable and cbAssertionKill report these
// changes, and for these reasons the attempt information pointer is NULL.
// §39.3.1: the application finds a1 among all assertions. The clock ticks at
// 5, 15, 25, ... and a and b are 1 from before the first tick, so the attempts
// started at 5 and 15 both succeed. $assertoff at 16 lets the attempt from 15
// finish at 25 but starts no new one; $asserton at 26 lets one start at 35,
// which $assertkill at 36 discards; $asserton at 46 starts one at 55 that
// succeeds at 65, where another attempt starts. So the pass action runs three
// times and the fail action never. The events of each time step are printed
// sorted.

`timescale 1ns/1ns

module test_vpi_assertion_system_task_control;
  logic clk = 0, a = 0, b = 0;
  int passes = 0, fails = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##1 b) passes++; else fails++;

  initial begin
    $vt_watch;
    a = 1;
    #11 b = 1;                // 11
    #5 $assertoff(0, a1);     // 16
    #10 $asserton(0, a1);     // 26
    #10 $assertkill(0, a1);   // 36
    #10 $asserton(0, a1);     // 46
    #20 $vt_report;           // 66
    $display("pass actions: %0d, fail actions: %0d", passes, fails);
    $finish;
  end
endmodule

/*
:name: test_vpi_assertion_control
:description: vpi_control disables and enables one assertion, its pass and fail actions and its pass action on vacuous success, a locked assertion keeps its status, and each change calls the matching assertion callback without attempt information (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2 39.4.2 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_control.c
:expected_stdout: @test_vpi_assertion_control.expected
*/
// IEEE 1800-2023 §39.5.2: $vt_control calls vpi_control on the named assertion
// between clock ticks. Each phase has three ticks, after which the counts of
// pass and fail actions are printed and cleared. With all actions enabled, a1
// passes once and fails twice, and a2 passes nonvacuously, passes vacuously
// (y is 0, 16.12.7) and fails. vpiAssertionDisableFailAction and
// vpiAssertionDisablePassAction stop the fail and pass actions,
// vpiAssertionDisable stops new attempts, and vpiAssertionLock keeps the status
// of a1, so vpiAssertionEnable has no effect until vpiAssertionUnlock.
// vpiAssertionDisableVacuousAction stops the pass action only on vacuous
// success; after vpiAssertionDisablePassAction,
// vpiAssertionEnableNonvacuousAction enables it again only on nonvacuous
// success. Controlling a1 does not change a2. §39.4.2: callbacks placed with
// vpi_register_assertion_cb for these reasons are called when the change
// happens, and their attempt information pointer is NULL.

`timescale 1ns/1ns

module test_vpi_assertion_control;
  logic clk = 0, x = 0, y = 0;
  int p1 = 0, f1 = 0, p2 = 0, f2 = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) x) p1++; else f1++;
  a2: assert property (@(posedge clk) y |-> x) p2++; else f2++;

  task automatic three_ticks(string phase);
    x = 1; y = 1;
    #10 x = 0; y = 0;
    #10 x = 0; y = 1;
    #10 $display("%0d: %s: a1 pass %0d fail %0d, a2 pass %0d fail %0d", $time, phase,
                 p1, f1, p2, f2);
    p1 = 0; f1 = 0; p2 = 0; f2 = 0;
  endtask

  initial begin
    $vt_watch;
    three_ticks("all enabled");
    $vt_control("a1", "disable fail action");
    three_ticks("a1 fail action disabled");
    $vt_control("a1", "enable fail action");
    $vt_control("a1", "disable pass action");
    three_ticks("a1 pass action disabled");
    $vt_control("a1", "enable pass action");
    $vt_control("a1", "disable");
    three_ticks("a1 disabled");
    $vt_control("a1", "lock");
    $vt_control("a1", "enable");
    three_ticks("a1 locked");
    $vt_control("a1", "unlock");
    $vt_control("a1", "enable");
    three_ticks("a1 enabled");
    $vt_control("a2", "disable vacuous action");
    three_ticks("a2 vacuous action disabled");
    $vt_control("a2", "disable pass action");
    $vt_control("a2", "enable nonvacuous action");
    three_ticks("a2 nonvacuous action enabled");
    $vt_control("a2", "enable pass action");
    three_ticks("a2 pass action enabled");
    $finish;
  end
endmodule

/*
:name: test_vpi_assertion_step_callbacks
:description: Step callbacks occur only for an attempt whose stepping was enabled, at each clock tick it advances, with the failing step naming its expression, and not for an attempt whose stepping was disabled before it started (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_step_callbacks.c
:expected_stdout: @test_vpi_assertion_step_callbacks.expected
*/
// IEEE 1800-2023 §39.5.2: stepping is off by default and is enabled for one
// attempt, given by its start time, with vpiAssertionEnableStep; with
// vpiAssertionClockSteps a step callback occurs at every clock tick at which
// the attempt advances. vpiAssertionDisableStep turns it off again. §39.4.2:
// placing a step callback gives the same function the success and the failure
// steps; a failing step has at least one expression, the last being where it
// failed, and states are numbered from the origin, 0. a1 needs a, b and c on
// three ticks in a row. The attempt at 15 sees a and b and fails at 35 on c;
// the one at 45 passes at 65, but its stepping is disabled at 40, before it
// starts. Only the distinct times and kinds of the steps are printed.

`timescale 1ns/1ns

module test_vpi_assertion_step_callbacks;
  logic clk = 0, a = 0, b = 0, c = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##1 b ##1 c);

  initial begin
    $vt_watch;          // enables stepping for the attempts at 15 and 45
    #10 a = 1;          // sampled at 15
    #10 a = 0; b = 1;   // sampled at 25
    #10 b = 0;          // c is 0 at 35
    #10 $vt_nostep;     // at 40, for the attempt at 45
    a = 1;
    #10 a = 0; b = 1;
    #10 b = 0; c = 1;   // sampled at 65
    #10 c = 0;
    #10 $vt_report;
    $finish;
  end
endmodule

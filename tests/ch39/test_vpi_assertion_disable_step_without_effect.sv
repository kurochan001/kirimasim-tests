/*
:name: test_vpi_assertion_disable_step_without_effect
:description: vpiAssertionDisableStep turns off the stepping enabled for an attempt, and has no effect when the stepping of the attempt is already disabled or was never enabled, so a repeated or needless disable neither turns stepping on nor keeps a later enable from working (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_disable_step_without_effect.c
:expected_stdout: @test_vpi_assertion_disable_step_without_effect.expected
*/
// IEEE 1800-2023 §39.5.2: vpi_control(vpiAssertionDisableStep, assertion,
// start) disables the step callbacks for the attempt of the assertion that
// starts at the given time; it has no effect if stepping is not enabled or is
// already disabled. vpiAssertionEnableStep with vpiAssertionClockSteps enables
// them, with a step callback at each clock tick at which the attempt advances;
// stepping is disabled by default.
// The clock rises at 5, 15, 25 and so on; a1 needs a, b and c on three ticks in
// a row, and the attempts of 15, 55, 95 and 125 get them and pass two ticks
// later; the others fail at once, with an empty action. At 1, $vt_watch places
// a step callback and a cbAssertionSuccess callback on a1 (39.4.2) and enables
// stepping for the attempt of 15, which steps at 15, 25 and 35. Stepping for
// the attempt of 55 is enabled at 40 and disabled at 42 and again at 44, so it
// gives no step callback. Stepping for the attempt of 95 is disabled at 80
// without having been enabled, and it gives none either. Stepping for the
// attempt of 125 is disabled at 120 without having been enabled and enabled at
// 122, so it steps at 125, 135 and 145. Every disable and enable comes before
// the attempt starts. The application prints the distinct steps and the
// successes at the end, sorted. No simulator here runs the application: the
// expected output is derived from §39.5.2.

`timescale 1ns/1ns

module test_vpi_assertion_disable_step_without_effect;
  logic clk = 0, a = 0, b = 0, c = 0;

  // The values of a, b and c sampled at the ticks 5, 15, ..., 145, from left.
  localparam bit [0:14] A_AT = 15'b010001000100100;
  localparam bit [0:14] B_AT = 15'b001000100010010;
  localparam bit [0:14] C_AT = 15'b000100010001001;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##1 b ##1 c) else ;

  initial
    for (int k = 0; k < 15; k++) begin
      a = A_AT[k];
      b = B_AT[k];
      c = C_AT[k];
      #10;
    end

  initial begin
    #1 $vt_watch;                  // 1, enables stepping for 15
    #39 $vt_step("enable", 55);    // 40
    #2 $vt_step("disable", 55);    // 42
    #2 $vt_step("disable", 55);    // 44
    #36 $vt_step("disable", 95);   // 80
    #40 $vt_step("disable", 125);  // 120
    #2 $vt_step("enable", 125);    // 122
    #28 $vt_report;                // 150
    $finish;
  end
endmodule

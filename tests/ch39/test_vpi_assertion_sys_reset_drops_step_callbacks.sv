/*
:name: test_vpi_assertion_sys_reset_drops_step_callbacks
:description: vpiAssertionSysReset discards the attempts in progress and removes the step callbacks, so stepping enabled afterwards reports nothing, while the start and success callbacks stay and report the later attempts (IEEE 1800-2023 Section 39.5.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_sys_reset_drops_step_callbacks.c
:expected_stdout: @test_vpi_assertion_sys_reset_drops_step_callbacks.expected
*/
// IEEE 1800-2023 §39.5.1: vpi_control(vpiAssertionSysReset, NULL) discards the
// attempts in progress of all assertions and removes the step callbacks placed
// before it; all other assertion callbacks remain.
// The clock rises at 5, 15, 25 and so on; a1 needs a, b and c on three ticks in
// a row. a is 1 at 5, 25 and 55, b at 15, 35 and 65, and c at 25, 45 and 75;
// the other attempts fail at their first tick, with an empty action. At 1,
// $vt_watch places cbAssertionStart, cbAssertionSuccess and a step callback on
// a1 (39.4.2), and enables stepping for the attempt of 5 with
// vpiAssertionClockSteps (39.5.2), which steps at 5, 15 and 25 and passes at
// 25. The attempt of 25 is running at 30, where $vt_reset resets the assertion
// system, so it does not pass at 45. At 40, $vt_step(55) enables stepping for
// the attempt of 55, which passes at 75 but gives no step callback, since the
// step callback is gone. The start and success callbacks still report every
// attempt and the success at 75. The application prints the start times, the
// successes and the distinct times of the steps at the end, sorted. No
// simulator here runs the application: the expected output is derived from
// §39.5.1.

`timescale 1ns/1ns

module test_vpi_assertion_sys_reset_drops_step_callbacks;
  logic clk = 0, a = 0, b = 0, c = 0;

  // The values of a, b and c sampled at the ticks 5, 15, ..., 75, from left.
  localparam bit [0:7] A_AT = 8'b10100100;
  localparam bit [0:7] B_AT = 8'b01010010;
  localparam bit [0:7] C_AT = 8'b00101001;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a ##1 b ##1 c) else ;

  initial
    for (int k = 0; k < 8; k++) begin
      a = A_AT[k];
      b = B_AT[k];
      c = C_AT[k];
      #10;
    end

  initial begin
    #1 $vt_watch;          // 1
    #29 $vt_reset;         // 30
    #10 $vt_step(55);      // 40
    #40 $vt_report;        // 80
    $finish;
  end
endmodule

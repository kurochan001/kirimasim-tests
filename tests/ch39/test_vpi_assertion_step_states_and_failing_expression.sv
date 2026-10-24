/*
:name: test_vpi_assertion_step_states_and_failing_expression
:description: The step information of an attempt starts at the origin state 0, passes through intermediate states that are neither 0 nor 1, and ends a successful attempt in the accepting state 1; each step names the expression it matched, and the last expression of a failing step is the one that failed (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_step_states_and_failing_expression.c
:expected_stdout: @test_vpi_assertion_step_states_and_failing_expression.expected
*/
// IEEE 1800-2023 §39.4.2: the step information of a step callback names the
// state the step leaves and the state it reaches: 0 is the origin state, 1 an
// accepting state, and any other number an intermediate point of the
// assertion. The step also gives the expressions matched in the step; for a
// failing transition, the last of them is the expression where the transition
// failed.
// The clock rises at 5, 15, 25 and so on; a1 needs a, b and c on three ticks in
// a row. The attempt of 15 gets them and passes at 35; the attempt of 45 gets a
// and b and fails at 65, where c is 0. The other attempts fail at once, with an
// empty action. At 1, $vt_watch places a step callback on a1 and enables
// stepping with vpiAssertionClockSteps for the attempts of 15 and 45 (39.5.2).
// The callback records, for each step, the attempt, whether it fails, the two
// states and the name of the last matched expression. At the end the
// application prints the distinct steps of each attempt, sorted, with their
// states as origin (0), accepting (1) or intermediate, and the name of their
// last expression: a, b and c in turn, and c for the failing step. No simulator
// here runs the application: the expected output is derived from §39.4.2.

`timescale 1ns/1ns

module test_vpi_assertion_step_states_and_failing_expression;
  logic clk = 0, a = 0, b = 0, c = 0;

  // The values of a, b and c sampled at the ticks 5, 15, ..., 75, from left.
  localparam bit [0:7] A_AT = 8'b01001000;
  localparam bit [0:7] B_AT = 8'b00100100;
  localparam bit [0:7] C_AT = 8'b00010000;

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
    #1 $vt_watch;     // 1
    #79 $vt_report;   // 80
    $finish;
  end
endmodule

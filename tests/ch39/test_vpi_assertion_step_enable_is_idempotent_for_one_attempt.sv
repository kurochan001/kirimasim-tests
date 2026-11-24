/*
:name: test_vpi_assertion_step_enable_is_idempotent_for_one_attempt
:description: Repeated step enable calls before and during one attempt preserve its callbacks and leave other attempts off
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_step_enable_is_idempotent_for_one_attempt.expected
:vpi_c: @test_vpi_assertion_step_enable_is_idempotent_for_one_attempt.c
*/
`timescale 1ns/1ns

module test_vpi_assertion_step_enable_is_idempotent_for_one_attempt;
  logic clk = 0, request = 0, response = 0, done = 0;
  always #5 clk = ~clk;

  path: assert property (@(posedge clk) request ##1 response ##1 done) else ;
  peer: assert property (@(posedge clk) request ##1 response ##1 done) else ;

  initial begin
    #1 $vt_arm_first;
    #9 request = 1;
    #10;
    request = 0;
    response = 1;
    $vt_repeat_arm;

    #10;
    response = 0;
    done = 1;
    $vt_repeat_arm;

    #10 done = 0;
    request = 1;
    #10 request = 0;
    response = 1;
    #10 response = 0;
    done = 1;

    #10 $vt_report_steps;
    $finish;
  end
endmodule

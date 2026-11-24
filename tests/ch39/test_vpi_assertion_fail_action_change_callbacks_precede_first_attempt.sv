/*
:name: test_vpi_assertion_fail_action_change_callbacks_precede_first_attempt
:description: Fail-action enable and disable callbacks run before any assertion attempt
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.1 39.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_fail_action_change_callbacks_precede_first_attempt.expected
:vpi_c: @test_vpi_assertion_system_fail_action_controls_respect_scope.c
*/
`timescale 1ns/1ns
module test_vpi_assertion_fail_action_change_callbacks_precede_first_attempt;
  bit clk;
  int failures = 0;
  failing_check: assert property (@(posedge clk) 1'b0) else failures++;

  initial begin
    #1 $vt_fail_action_control(2);
    #2 $vt_fail_action_control(3);
    #1 $display("before first attempt failures=%0d", failures);
    #1 clk = 1;
    #1 $display("after first attempt failures=%0d", failures);
  end
endmodule

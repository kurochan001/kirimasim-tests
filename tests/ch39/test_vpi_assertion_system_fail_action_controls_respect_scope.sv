/*
:name: test_vpi_assertion_system_fail_action_controls_respect_scope
:description: Assertion fail-action controls use the selected scope or all scopes when null
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1 39.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_system_fail_action_controls_respect_scope.expected
:vpi_c: @test_vpi_assertion_system_fail_action_controls_respect_scope.c
*/
`timescale 1ns/1ns
module fail_action_leaf(input bit clk, output int failures);
  initial failures = 0;
  failed_check: assert property (@(posedge clk) 1'b0) else failures++;
endmodule

module test_vpi_assertion_system_fail_action_controls_respect_scope;
  bit clk;
  int left_failures, right_failures;
  fail_action_leaf left(clk, left_failures);
  fail_action_leaf right(clk, right_failures);

  initial begin
    #1 $vt_fail_action_control(0);
    #4 clk = 1;
    #1 $display("after scope disable=%0d,%0d", left_failures, right_failures);
    #2 $vt_fail_action_control(1);
    #2 clk = 0;
    #5 clk = 1;
    #1 $display("after scope enable=%0d,%0d", left_failures, right_failures);
    #2 $vt_fail_action_control(2);
    #2 clk = 0;
    #5 clk = 1;
    #1 $display("after global disable=%0d,%0d", left_failures, right_failures);
  end
endmodule

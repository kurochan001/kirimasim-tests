/*
:name: test_vpi_assertion_system_notifications_follow_lifecycle
:description: The assertion system initializes before its default activation and first attempt
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.1 39.5.1 36.10.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_system_notifications_follow_lifecycle.expected
:vpi_c: @test_vpi_assertion_system_notifications_follow_lifecycle.c
*/
`timescale 1ns/1ns
module test_vpi_assertion_system_notifications_follow_lifecycle;
  bit clk;
  int passed = 0;
  property always_true;
    @(posedge clk) 1'b1;
  endproperty
  check_activation: assert property (always_true) passed++;

  initial begin
    #5 clk = 1;
    #1 $display("startup passes=%0d", passed);
    $vt_report_lifecycle;
  end
endmodule

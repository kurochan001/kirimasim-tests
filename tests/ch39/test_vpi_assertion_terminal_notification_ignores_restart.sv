/*
:name: test_vpi_assertion_terminal_notification_ignores_restart
:description: Assertion system termination emits one notification and refuses another start
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.1 39.5.1 36.10.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_terminal_notification_ignores_restart.expected
:vpi_c: @test_vpi_assertion_system_notifications_follow_lifecycle.c
*/
`timescale 1ns/1ns
module test_vpi_assertion_terminal_notification_ignores_restart;
  bit clk;
  int passed = 0;
  check_end: assert property (@(posedge clk) 1'b1) passed++;

  initial begin
    #5 clk = 1;
    #1 $display("before end passes=%0d", passed);
    $vt_end_system;
    $vt_report_end;
    #4 clk = 0;
    #5 clk = 1;
    #1 $display("after end passes=%0d", passed);
    $vt_end_system;
    $vt_report_end;
  end
endmodule

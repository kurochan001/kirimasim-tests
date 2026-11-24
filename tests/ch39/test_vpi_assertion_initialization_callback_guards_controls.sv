/*
:name: test_vpi_assertion_initialization_callback_guards_controls
:description: Assertion-specific control takes effect only after the initialization callback returns
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.1 39.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_assertion_initialization_callback_guards_controls.expected
:vpi_c: @test_vpi_assertion_initialization_callback_guards_controls.c
*/
`timescale 1ns/1ns

module test_vpi_assertion_initialization_callback_guards_controls;
  logic clk = 0;

  early_target: assert property (@(posedge clk) 1'b1);
  ready_target: assert property (@(posedge clk) 1'b1);

  initial begin
    #1 $vt_watch_ready_assertions;
    #4 clk = 1;
    #5 clk = 0;
    $vt_disable_ready_assertion;
    #5 clk = 1;
    #5 $vt_init_report;
    $finish;
  end
endmodule

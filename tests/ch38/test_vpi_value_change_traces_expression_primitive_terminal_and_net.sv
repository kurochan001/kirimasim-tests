/*
:name: test_vpi_value_change_traces_expression_primitive_terminal_and_net
:description: Value-change callbacks follow a computed expression and a primitive input terminal as well as the expression's output net
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_value_change_traces_expression_primitive_terminal_and_net.expected
:vpi_c: @test_vpi_value_change_traces_expression_primitive_terminal_and_net.c
*/
`timescale 1ns/1ns

module test_vpi_value_change_traces_expression_primitive_terminal_and_net;
  logic [1:0] inputs = 2'b00;
  wire parity, inverted;

  assign parity = ^inputs;
  not input_gate(inverted, inputs[0]);

  task automatic snapshot();
    $display("at %0d parity=%b input=%b inverted=%b", $time, parity, inputs[0], inverted);
  endtask

  initial begin
    #1 $vt_watch_value_targets;
    #4 inputs = 2'b11;
    #1 snapshot();
    #4 inputs = 2'b10;
    #1 snapshot();
    #4 inputs = 2'b01;
    #1 snapshot();
    #4 inputs = 2'b00;
    #1 snapshot();
    #4 $vt_report_value_targets;
  end
endmodule

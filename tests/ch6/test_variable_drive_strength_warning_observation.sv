/*
:name: test_variable_drive_strength_warning_observation
:description: A variable driven continuously loses drive strength in a resolved network
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_drive_strength_warning_observation.expected
*/
`timescale 1ns/1ns
module test_variable_drive_strength_warning_observation;
  logic stimulus = 0;
  wire strength_net;
  logic value;
  wire resolved_variable, resolved_net;
  assign (pull1, weak0) strength_net = stimulus;
`ifdef OBSERVE_STRENGTH
  assign (pull1, weak0) value = stimulus;
`else
  assign value = strength_net;
`endif
  assign (pull1, pull0) resolved_variable = 1'b1;
  assign resolved_variable = value;
  assign (pull1, pull0) resolved_net = 1'b1;
  assign (pull1, weak0) resolved_net = stimulus;

  initial begin
    #1 $display("zero value=%b variable path=%b net path=%b",
                value, resolved_variable, resolved_net);
    #1 stimulus = 1;
    #1 $display("one value=%b variable path=%b net path=%b",
                value, resolved_variable, resolved_net);
    $finish(0);
  end
endmodule

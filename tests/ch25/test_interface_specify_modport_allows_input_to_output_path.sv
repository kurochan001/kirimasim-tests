/*
:name: test_interface_specify_modport_allows_input_to_output_path
:description: A specify path propagates changes from a modport input to its output with the selected delay
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_interface_specify_modport_allows_input_to_output_path.expected
*/
`timescale 1ns/1ns
interface directional_terminals;
  wire source, sink;
  modport model(input source, output sink);
endinterface

module directional_terminal_model(directional_terminals.model pins);
  assign pins.sink = ~pins.source;

  specify
    (pins.source => pins.sink) = 4;
  endspecify
endmodule

module test_interface_specify_modport_allows_input_to_output_path;
  bit source;
  directional_terminals pins();
  directional_terminal_model model(pins);
  assign pins.source = source;

  initial begin
    #10 source = 1;
    #3 $display("before path delay=%b", pins.sink);
    #2 $display("after path delay=%b", pins.sink);
  end
endmodule

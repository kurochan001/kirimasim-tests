/*
:name: test_interface_specify_paths_treat_unqualified_signals_as_terminals
:description: Specify paths use interface input and output signals under default directions
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_interface_specify_paths_treat_unqualified_signals_as_terminals.expected
*/
`timescale 1ns/1ns
interface direct_terminals;
  wire source, sink;
endinterface

module direct_terminal_model(direct_terminals pins);
  assign pins.sink = pins.source;

  specify
    (pins.source => pins.sink) = (3, 2);
  endspecify
endmodule

module test_interface_specify_paths_treat_unqualified_signals_as_terminals;
  bit source;
  direct_terminals pins();
  direct_terminal_model model(pins);
  assign pins.source = source;

  initial begin
    #10 source = 1;
    #2 $display("before rise=%b", pins.sink);
    #2 $display("after rise=%b", pins.sink);
    #6 source = 0;
    #1 $display("before fall=%b", pins.sink);
    #2 $display("after fall=%b", pins.sink);
  end
endmodule

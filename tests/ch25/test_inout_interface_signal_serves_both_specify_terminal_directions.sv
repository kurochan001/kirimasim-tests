/*
:name: test_inout_interface_signal_serves_both_specify_terminal_directions
:description: A modport inout signal serves as both a specify path output and a specify path input
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.6 30.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inout_interface_signal_serves_both_specify_terminal_directions.expected
*/
`timescale 1ns/1ns
interface timing_channel;
  wire source, link;
  modport model(input source, inout link);
endinterface
module path_writer(timing_channel.model channel);
  assign channel.link = channel.source;
  specify
    (channel.source => channel.link) = 2;
  endspecify
endmodule
module path_reader(timing_channel.model channel, output wire result);
  assign result = channel.link;
  specify
    (channel.link => result) = 3;
  endspecify
endmodule
module test_inout_interface_signal_serves_both_specify_terminal_directions;
  timing_channel channel();
  reg drive = 0;
  wire result;
  assign channel.source = drive;
  path_writer first(channel);
  path_reader second(channel, result);

  initial begin
    #10 drive = 1;
    #1 $display("at11=%b%b", channel.link, result);
    #2 $display("at13=%b%b", channel.link, result);
    #3 $display("at16=%b%b", channel.link, result);
  end
endmodule

/*
:name: test_interconnect_single_delay_on_inferred_net
:description: A single interconnect delay applies to both transitions after endpoints determine the net type
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_single_delay_on_inferred_net.expected
*/
`timescale 1ns/1ns
module interconnect_source(input bit drive, output wire signal_value);
  assign signal_value = drive;
endmodule
module interconnect_sink(input wire signal_value, output wire observed);
  assign observed = signal_value;
endmodule
module test_interconnect_single_delay_on_inferred_net;
  bit drive;
  wire direct_result, delayed_result;
  interconnect direct_link;
  interconnect #2 delayed_link;
  interconnect_source direct_source(drive, direct_link);
  interconnect_source delayed_source(drive, delayed_link);
  interconnect_sink direct_sink(direct_link, direct_result);
  interconnect_sink delayed_sink(delayed_link, delayed_result);

  initial begin
    #10 drive = 1;
    #1 $display("early rise=%b%b", direct_result, delayed_result);
    #2 $display("late rise=%b%b", direct_result, delayed_result);
    #7 drive = 0;
    #1 $display("early fall=%b%b", direct_result, delayed_result);
    #2 $display("late fall=%b%b", direct_result, delayed_result);
  end
endmodule

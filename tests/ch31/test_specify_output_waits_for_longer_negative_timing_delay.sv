/*
:name: test_specify_output_waits_for_longer_negative_timing_delay
:description: A module path waits for its delayed clock when a negative setup shift exceeds the specified propagation delay
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.4 30.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_output_waits_for_longer_negative_timing_delay.expected
*/
// The expected results require negative timing checks to be enabled.
`timescale 1ns/1ns
module checked_clock #(parameter int POS_SETUP = -5, NEG_SETUP = -2)
                     (input wire clk, data, output wire q);
  wire delayed_clk, delayed_data;
  assign q = clk;
  specify
    (clk => q) = 3;
    $setuphold(posedge clk, posedge data, POS_SETUP, 10, , , , delayed_clk, delayed_data);
    $setuphold(posedge clk, negedge data, NEG_SETUP, 7, , , , delayed_clk, delayed_data);
  endspecify
endmodule
module test_specify_output_waits_for_longer_negative_timing_delay;
  bit clk, data;
  wire shifted_out, control_out;
  checked_clock #(-5, -2) shifted(clk, data, shifted_out);
  checked_clock #(2, 1) control(clk, data, control_out);
  time shifted_rise, control_rise;
  always @(posedge shifted_out) shifted_rise = $time;
  always @(posedge control_out) control_rise = $time;

  initial begin
    #6 data = 1;
    #3 data = 0;
    #11 clk = 1;
    #4 $display("at24 shifted=%b%b control=%b%b",
                shifted.delayed_clk, shifted_out, control.delayed_clk, control_out);
    #3 $display("at27 shifted=%b%b control=%b%b",
                shifted.delayed_clk, shifted_out, control.delayed_clk, control_out);
    $display("output edges shifted=%0d control=%0d", shifted_rise, control_rise);
  end
endmodule

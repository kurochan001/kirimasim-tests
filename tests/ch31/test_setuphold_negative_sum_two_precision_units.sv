/*
:name: test_setuphold_negative_sum_two_precision_units
:description: A setuphold limit sum of two simulation precision units is allowed with a negative hold limit
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_setuphold_negative_sum_two_precision_units.expected
*/
`timescale 1ns/1ns
module test_setuphold_negative_sum_two_precision_units;
  reg clk = 0, data = 0, notifier = 0;
  specify
    $setuphold(posedge clk, posedge data, 5, -3, notifier);
  endspecify
  initial begin
    #10 data = 1;
    #4 clk = 1;
    #1 $display("notifier=%b", notifier);
  end
endmodule

/*
:name: test_setuphold_positive_limits_isolate_each_window
:description: Positive setuphold limits report data before the reference and data after the reference separately
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_setuphold_positive_limits_isolate_each_window.expected
*/
`timescale 1ns/1ns
module role_check(input wire clock, input wire sample);
  reg notifier = 0;
  specify
    $setuphold(posedge clock, posedge sample, 5, 3, notifier);
  endspecify
endmodule

module test_setuphold_positive_limits_isolate_each_window;
  bit clock, before_sample, after_sample, safe_sample;
  role_check before_edge(clock, before_sample);
  role_check after_edge(clock, after_sample);
  role_check outside(clock, safe_sample);

  initial begin
    #12 safe_sample = 1;
    #5 before_sample = 1;
    #3 clock = 1;
    #1 $display("at21 before=%b after=%b safe=%b", before_edge.notifier,
                after_edge.notifier, outside.notifier);
    #1 after_sample = 1;
    #1 $display("at23 before=%b after=%b safe=%b", before_edge.notifier,
                after_edge.notifier, outside.notifier);
  end
endmodule

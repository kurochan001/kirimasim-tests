/*
:name: test_negative_setuphold_has_exclusive_window_endpoints
:description: A negative setup or hold limit tests only changes strictly inside each timing window
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_setuphold_has_exclusive_window_endpoints.expected
*/
`timescale 1ns/1ns
module checked_path #(parameter int SETUP = -3, HOLD = 8)
                     (input wire clock, data, output reg notifier = 0);
  specify
    $setuphold(posedge clock, posedge data, SETUP, HOLD, notifier);
  endspecify
endmodule

module test_negative_setuphold_has_exclusive_window_endpoints;
  bit clock;
  bit [5:0] before_edge, after_edge;
  wire [5:0] negative_setup, negative_hold;

  for (genvar idx = 0; idx < 6; idx++) begin : checks
    checked_path #(-3, 8) setup_window(clock, after_edge[idx], negative_setup[idx]);
    checked_path #(8, -3) hold_window(clock, before_edge[idx], negative_hold[idx]);
  end

  initial begin
    #11 before_edge[0] = 1;
    #1 before_edge[1] = 1;
    #1 before_edge[2] = 1;
    #3 before_edge[3] = 1;
    #1 before_edge[4] = 1;
    #1 before_edge[5] = 1;
    #2 clock = 1;
    #2 after_edge[0] = 1;
    #1 after_edge[1] = 1;
    #1 after_edge[2] = 1;
    #3 after_edge[3] = 1;
    #1 after_edge[4] = 1;
    #1 after_edge[5] = 1;
    #5 $display("negative setup=%b negative hold=%b", negative_setup, negative_hold);
  end
endmodule
